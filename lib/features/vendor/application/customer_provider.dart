import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/customer/customer.dart';
import '../../../data/providers/remote_data_source_providers.dart';

/// Customer state management
class CustomerState {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final CustomerSortOption sortOption;

  CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.sortOption = CustomerSortOption.name,
  });

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
    String? searchQuery,
    CustomerSortOption? sortOption,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  List<Customer> get filteredCustomers {
    List<Customer> filtered = List.from(customers);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) {
        final nameLower = customer.name.toLowerCase();
        final phoneLower = customer.phone.toLowerCase();
        final queryLower = searchQuery.toLowerCase();
        return nameLower.contains(queryLower) || phoneLower.contains(queryLower);
      }).toList();
    }

    // Apply sorting
    switch (sortOption) {
      case CustomerSortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CustomerSortOption.quantity:
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case CustomerSortOption.activeFirst:
        filtered.sort((a, b) {
          if (a.active == b.active) return a.name.compareTo(b.name);
          return a.active ? -1 : 1;
        });
        break;
      case CustomerSortOption.recentlyAdded:
        filtered.sort((a, b) {
          final aCreated = a.createdAt ?? DateTime(2000);
          final bCreated = b.createdAt ?? DateTime(2000);
          return bCreated.compareTo(aCreated);
        });
        break;
    }

    return filtered;
  }

  int get activeCount => customers.where((c) => c.active).length;
  int get inactiveCount => customers.where((c) => !c.active).length;
  double get totalDailyQuantity => customers
      .where((c) => c.active)
      .fold(0.0, (sum, c) => sum + c.quantity);
}

enum CustomerSortOption {
  name,
  quantity,
  activeFirst,
  recentlyAdded,
}

/// Customer notifier for state management
class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier(this._ref) : super(CustomerState());

  final Ref _ref;

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final remoteDs = _ref.read(customerRemoteDataSourceProvider);
      final customers = await remoteDs.getCustomers();
      
      state = state.copyWith(
        customers: customers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      final remoteDs = _ref.read(customerRemoteDataSourceProvider);
      final createdCustomer = await remoteDs.createCustomer(
        name: customer.name,
        phone: customer.phone,
        address: customer.address,
        quantity: customer.quantity,
        rate: customer.rate,
        frequency: customer.frequency,
      );
      
      final updatedCustomers = [...state.customers, createdCustomer];
      state = state.copyWith(customers: updatedCustomers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      final remoteDs = _ref.read(customerRemoteDataSourceProvider);
      final updatedCustomer = await remoteDs.updateCustomer(
        customer.customerId,
        name: customer.name,
        phone: customer.phone,
        address: customer.address,
        quantity: customer.quantity,
        rate: customer.rate,
        frequency: customer.frequency,
        active: customer.active,
      );
      
      final updatedCustomers = state.customers.map((c) {
        return c.customerId == updatedCustomer.customerId ? updatedCustomer : c;
      }).toList();
      
      state = state.copyWith(customers: updatedCustomers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      final remoteDs = _ref.read(customerRemoteDataSourceProvider);
      await remoteDs.deleteCustomer(customerId);
      
      final updatedCustomers = state.customers
          .where((c) => c.customerId != customerId)
          .toList();
      
      state = state.copyWith(customers: updatedCustomers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> toggleCustomerStatus(String customerId) async {
    try {
      final customer = state.customers.firstWhere(
        (c) => c.customerId == customerId,
      );
      
      final updatedCustomer = customer.copyWith(active: !customer.active);
      await updateCustomer(updatedCustomer);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(CustomerSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Providers
final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) => CustomerNotifier(ref),
);

final filteredCustomersProvider = Provider<List<Customer>>((ref) {
  final state = ref.watch(customerProvider);
  return state.filteredCustomers;
});
