import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../cart/data/models/cart_item.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../profile/data/models/customer.dart';
import '../../profile/data/services/customer_service.dart';
import '../../profile/presentation/providers/customer_provider.dart';
import '../data/checkout_models.dart';
import '../../orders/presentation/orders_provider.dart';
import 'checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  final _shipping = _AddressFields();
  final _billing = _AddressFields();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  bool _initialized = false, _sameAddress = true;
  int? _methodId;
  bool _navigatedToOrders = false;

  @override
  void dispose() {
    _shipping.dispose();
    _billing.dispose();
    _email.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit(List<CartItem> items, ShippingMethod method) async {
    if (!_form.currentState!.validate()) return;
    if (ref.read(checkoutProvider).uncertain) {
      final retry = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Retry order submission?'),
          content: const Text(
            'The previous order may already exist. Retrying can create a duplicate order. Only retry after checking with the shop.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Retry anyway'),
            ),
          ],
        ),
      );
      if (retry != true || !mounted) return;
    }
    await ref
        .read(checkoutProvider.notifier)
        .submit(
          OrderRequest(
            items: items,
            shipping: _shipping.address(),
            billing: (_sameAddress ? _shipping : _billing).address(
              email: _email.text.trim(),
              phone: _phone.text.trim(),
            ),
            method: method,
            note: _note.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(checkoutProvider, (previous, next) {
      if (!_navigatedToOrders &&
          next.result != null &&
          !next.busy &&
          !next.cleanupPending) {
        _navigatedToOrders = true;
        invalidateOrders(ref);
        context.goNamed(
          AppRoutes.ordersName,
          queryParameters: {'createdOrderId': next.result!.id.toString()},
        );
      }
    });
    final checkout = ref.watch(checkoutProvider);
    final customer = ref.watch(customerProvider);
    final cart = ref.watch(cartProvider);
    final methods = ref.watch(shippingMethodsProvider);
    final result = checkout.result;
    return PopScope(
      canPop: !checkout.busy && !checkout.cleanupPending,
      child: Scaffold(
        appBar: AppBar(
          title: Text(result == null ? 'Checkout' : 'Order created'),
          automaticallyImplyLeading: !checkout.busy && !checkout.cleanupPending,
          actions: [
            if (result == null)
              TextButton.icon(
                onPressed: checkout.busy
                    ? null
                    : () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
          ],
        ),
        body: result != null
            ? _confirmation(checkout)
            : customer.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _retry(
                  error is CustomerException
                      ? error.message
                      : 'Could not load your customer information.',
                  () => ref.read(customerProvider.notifier).refresh(),
                ),
                data: (value) {
                  if (value == null) {
                    return const Center(
                      child: Text('Please log in to continue.'),
                    );
                  }
                  if (!_initialized) {
                    final shipping = value.shipping.address1.trim().isEmpty
                        ? value.billing
                        : value.shipping;
                    _shipping.fill(shipping, value);
                    _billing.fill(value.billing, value);
                    _email.text = value.billing.email.isEmpty
                        ? value.email
                        : value.billing.email;
                    _phone.text = value.billing.phone;
                    _initialized = true;
                  }
                  return cart.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => _retry(
                      'Could not load cart.',
                      () => ref.read(cartProvider.notifier).reload(),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return const Center(child: Text('Your cart is empty.'));
                      }
                      final subtotal = items.fold(
                        CartMoney.zero,
                        (sum, item) => sum + item.total,
                      );
                      ShippingMethod? selected;
                      for (final method
                          in methods.value ?? <ShippingMethod>[]) {
                        if (method.id == _methodId && method.cost != null) {
                          selected = method;
                        }
                      }
                      final chosen = selected;
                      return AbsorbPointer(
                        absorbing: checkout.busy,
                        child: Form(
                          key: _form,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              if (checkout.busy)
                                const LinearProgressIndicator(),
                              _heading('Shipping address'),
                              ..._shipping.widgets(),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Billing address same as shipping',
                                ),
                                value: _sameAddress,
                                onChanged: (value) => setState(
                                  () => _sameAddress = value ?? true,
                                ),
                              ),
                              if (!_sameAddress) ...[
                                _heading('Billing address'),
                                ..._billing.widgets(),
                              ],
                              TextFormField(
                                controller: _email,
                                decoration: const InputDecoration(
                                  labelText: 'Billing email',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) =>
                                    RegExp(
                                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                    ).hasMatch(value?.trim() ?? '')
                                    ? null
                                    : 'Enter a valid email.',
                              ),
                              TextFormField(
                                controller: _phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                ),
                                keyboardType: TextInputType.phone,
                                validator: _required,
                              ),
                              _heading('Shipping method'),
                              methods.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (error, stack) => _retry(
                                  'Could not load shipping methods.',
                                  () => ref.invalidate(shippingMethodsProvider),
                                ),
                                data: (available) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!available.any((m) => m.cost != null))
                                      const Text(
                                        'No available shipping methods.',
                                      ),
                                    for (final method in available)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: OutlinedButton.icon(
                                          onPressed: method.cost == null
                                              ? null
                                              : () => setState(
                                                  () => _methodId = method.id,
                                                ),
                                          icon: Icon(
                                            method.id == _methodId
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked,
                                          ),
                                          label: Text(
                                            '${method.title} · ${method.cost == null ? 'Unavailable' : '${method.cost} Ks'}',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              _heading('Products'),
                              for (final item in items)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.name),
                                  subtitle: Text(
                                    [
                                      'Quantity: ${item.quantity} · ${item.unitPrice} Ks',
                                      if (item.options.isNotEmpty)
                                        item.options.entries
                                            .map((e) => '${e.key}: ${e.value}')
                                            .join(' · '),
                                    ].join('\n'),
                                  ),
                                  trailing: Text('${item.total} Ks'),
                                ),
                              const Divider(),
                              Text('Subtotal: $subtotal Ks'),
                              Text(
                                'Shipping: ${chosen == null ? 'Select a method' : '${chosen.cost} Ks'}',
                              ),
                              if (chosen != null)
                                Text(
                                  'Estimated total: ${subtotal + chosen.cost!} Ks',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              const SizedBox(height: 8),
                              const Text('Payment: Cash on Delivery'),
                              TextFormField(
                                controller: _note,
                                decoration: const InputDecoration(
                                  labelText: 'Customer note (optional)',
                                ),
                                minLines: 2,
                                maxLines: 4,
                              ),
                              if (checkout.error != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    checkout.error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: checkout.busy || chosen == null
                                    ? null
                                    : () => _submit(items, chosen),
                                child: Text(
                                  checkout.busy
                                      ? 'Placing order…'
                                      : checkout.uncertain
                                      ? 'Retry order'
                                      : 'Place order',
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
  Widget _retry(String text, VoidCallback action) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        TextButton(onPressed: action, child: const Text('Retry')),
      ],
    ),
  );
  Widget _confirmation(CheckoutState state) {
    final order = state.result!;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.check_circle_outline, size: 64),
        _heading('Order #${order.id} created'),
        Text('Status: ${order.status}'),
        Text('Subtotal: ${order.subtotal} ${order.currency}'),
        Text('Shipping: ${order.shippingTotal} ${order.currency}'),
        Text('Total: ${order.total} ${order.currency}'),
        const Text('Payment: Cash on Delivery'),
        if (state.busy) const LinearProgressIndicator(),
        if (state.error != null) ...[
          const SizedBox(height: 16),
          Text(state.error!),
        ],
        if (state.cleanupPending)
          TextButton(
            onPressed: state.busy
                ? null
                : () => ref.read(checkoutProvider.notifier).cleanup(),
            child: const Text('Retry cart cleanup'),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: state.busy || state.cleanupPending
              ? null
              : () => context.go(AppRoutes.home),
          child: const Text('Continue shopping'),
        ),
      ],
    );
  }
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required.' : null;

class _AddressFields {
  final fields = {
    for (final key in [
      'first_name',
      'last_name',
      'address_1',
      'address_2',
      'city',
      'state',
      'postcode',
    ])
      key: TextEditingController(),
  };
  void fill(CustomerAddress address, Customer customer) {
    final values = address.toShippingJson();
    for (final entry in fields.entries) {
      entry.value.text = values[entry.key] ?? '';
    }
    if (fields['first_name']!.text.isEmpty) {
      fields['first_name']!.text = customer.firstName;
    }
    if (fields['last_name']!.text.isEmpty) {
      fields['last_name']!.text = customer.lastName;
    }
  }

  CustomerAddress address({String email = '', String phone = ''}) {
    String text(String key) => fields[key]!.text.trim();
    return CustomerAddress(
      firstName: text('first_name'),
      lastName: text('last_name'),
      address1: text('address_1'),
      address2: text('address_2'),
      city: text('city'),
      state: text('state'),
      postcode: text('postcode'),
      country: 'MM',
      email: email,
      phone: phone,
    );
  }

  List<Widget> widgets() => [
    for (final entry in fields.entries)
      TextFormField(
        controller: entry.value,
        decoration: InputDecoration(
          labelText: const {
            'first_name': 'First name',
            'last_name': 'Last name',
            'address_1': 'Street address',
            'address_2': 'Address line 2 (optional)',
            'city': 'City',
            'state': 'State / region',
            'postcode': 'Postcode (optional)',
          }[entry.key],
        ),
        validator: ['address_2', 'postcode'].contains(entry.key)
            ? null
            : _required,
      ),
    const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text('Country: Myanmar (MM)'),
    ),
  ];
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
  }
}
