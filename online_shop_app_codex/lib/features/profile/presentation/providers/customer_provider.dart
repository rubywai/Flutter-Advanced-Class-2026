import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/customer.dart';
import '../../data/services/customer_service.dart';
import '../../../../core/network/dio_provider.dart';

final customerServiceProvider = Provider<CustomerService>(
  (ref) => CustomerService(ref.watch(dioProvider)),
);

final customerProvider = AsyncNotifierProvider<CustomerNotifier, Customer?>(
  CustomerNotifier.new,
);

class CustomerNotifier extends AsyncNotifier<Customer?> {
  @override
  Future<Customer?> build() async {
    final auth = ref.watch(authProvider);
    final id = auth.value?.userId;
    if (auth.isLoading || !auth.hasValue || !auth.value!.isAuthenticated) {
      return null;
    }
    if (id == null) {
      throw const CustomerException(
        'Your login session has no customer ID. Please log in again.',
      );
    }
    return ref.read(customerServiceProvider).getCustomer(id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = ref.read(authProvider).value?.userId;
      if (id == null) {
        throw const CustomerException(
          'Your login session has no customer ID. Please log in again.',
        );
      }
      return ref.read(customerServiceProvider).getCustomer(id);
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(customerServiceProvider).updateCustomer(customer),
    );
  }
}
