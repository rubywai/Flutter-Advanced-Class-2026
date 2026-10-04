import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../data/order_summary.dart';
import 'orders_provider.dart';
import 'widgets/order_card.dart';

const _filters = <String?>[null, 'pending', 'processing', 'completed'];
const _labels = ['All', 'Pending', 'Processing', 'Completed'];

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.createdOrderId});
  final int? createdOrderId;
  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    appBar: AppBar(
      title: const Text('My Orders'),
      actions: [
        IconButton(
          tooltip: 'Refresh orders',
          onPressed: () => refreshOrders(ref, status: _filters[_tabs.index]),
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Log out',
          onPressed: () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      bottom: TabBar(
        controller: _tabs,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [for (final label in _labels) Tab(text: label)],
      ),
    ),
    body: Column(
      children: [
        if (widget.createdOrderId != null)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.secondaryContainer,
            padding: const EdgeInsets.all(16),
            child: Text('Order #${widget.createdOrderId} created.'),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              for (var i = 0; i < _filters.length; i++)
                _OrdersTab(
                  status: _filters[i],
                  label: _labels[i],
                  createdOrderId: widget.createdOrderId,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab({
    required this.status,
    required this.label,
    this.createdOrderId,
  });
  final String? status;
  final String label;
  final int? createdOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider(status));
    return RefreshIndicator(
      onRefresh: () => refreshOrders(ref, status: status),
      child: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              error is OrdersException
                  ? error.message
                  : 'Could not load orders. Please try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: FilledButton(
                onPressed: () => refreshOrders(ref, status: status),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
        data: (items) => ListView(
          key: PageStorageKey('orders-${status ?? 'all'}'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 64,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      status == null
                          ? 'You have no orders yet.'
                          : 'No $status orders yet.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            if (status == null &&
                createdOrderId != null &&
                !items.any((order) => order.id == createdOrderId)) ...[
              const Text(
                'Your new order is not in this list yet. Refresh to check again.',
              ),
              TextButton(
                onPressed: () => refreshOrders(ref),
                child: const Text('Refresh orders'),
              ),
            ],
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status == null ? 'Your purchases' : '$label orders',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${items.length} ${items.length == 1 ? 'order' : 'orders'} · Most recent first',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            for (final order in items) OrderCard(order: order),
          ],
        ),
      ),
    );
  }
}
