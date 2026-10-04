import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/customer.dart';
import 'providers/customer_provider.dart';

class CustomerEditScreen extends ConsumerStatefulWidget {
  const CustomerEditScreen({required this.customer, super.key});
  final Customer customer;
  @override
  ConsumerState<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends ConsumerState<CustomerEditScreen> {
  late final Map<String, TextEditingController> _fields;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final b = widget.customer.billing;
    final s = widget.customer.shipping;
    _fields = {
      'first_name': TextEditingController(text: widget.customer.firstName),
      'last_name': TextEditingController(text: widget.customer.lastName),
      'phone': TextEditingController(text: b.phone),
      'address_1': TextEditingController(text: b.address1),
      'address_2': TextEditingController(text: b.address2),
      'city': TextEditingController(text: b.city),
      'state': TextEditingController(text: b.state),
      'postcode': TextEditingController(text: b.postcode),
      'country': TextEditingController(text: b.country),
      'shipping_first_name': TextEditingController(text: s.firstName),
      'shipping_last_name': TextEditingController(text: s.lastName),
      'shipping_address_1': TextEditingController(text: s.address1),
      'shipping_address_2': TextEditingController(text: s.address2),
      'shipping_city': TextEditingController(text: s.city),
      'shipping_state': TextEditingController(text: s.state),
      'shipping_postcode': TextEditingController(text: s.postcode),
      'shipping_country': TextEditingController(text: s.country),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _value(String key) => _fields[key]!.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.customer;
    final billing = CustomerAddress(
      firstName: _value('first_name'),
      lastName: _value('last_name'),
      email: old.email,
      phone: _value('phone'),
      address1: _value('address_1'),
      address2: _value('address_2'),
      city: _value('city'),
      state: _value('state'),
      postcode: _value('postcode'),
      country: _value('country'),
    );
    final shipping = CustomerAddress(
      firstName: _value('shipping_first_name'),
      lastName: _value('shipping_last_name'),
      address1: _value('shipping_address_1'),
      address2: _value('shipping_address_2'),
      city: _value('shipping_city'),
      state: _value('shipping_state'),
      postcode: _value('shipping_postcode'),
      country: _value('shipping_country'),
    );
    await ref
        .read(customerProvider.notifier)
        .updateCustomer(
          Customer(
            id: old.id,
            email: old.email,
            firstName: _value('first_name'),
            lastName: _value('last_name'),
            username: old.username,
            billing: billing,
            shipping: shipping,
            avatarUrl: old.avatarUrl,
          ),
        );
    if (!mounted) return;
    final result = ref.read(customerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${result.error}')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(customerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _text('first_name', 'First name', required: true),
            _text('last_name', 'Last name', required: true),
            const SizedBox(height: 12),
            Text(
              'Billing address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _text('phone', 'Phone'),
            _text('address_1', 'Address line 1'),
            _text('address_2', 'Address line 2'),
            _text('city', 'City'),
            _text('state', 'State / region'),
            _text('postcode', 'Postcode'),
            _text('country', 'Country'),
            const SizedBox(height: 12),
            Text(
              'Shipping address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _text('shipping_first_name', 'First name'),
            _text('shipping_last_name', 'Last name'),
            _text('shipping_address_1', 'Address line 1'),
            _text('shipping_address_2', 'Address line 2'),
            _text('shipping_city', 'City'),
            _text('shipping_state', 'State / region'),
            _text('shipping_postcode', 'Postcode'),
            _text('shipping_country', 'Country'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(String key, String label, {bool required = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: _fields[key],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? '$label is required.'
                : null
          : null,
    ),
  );
}
