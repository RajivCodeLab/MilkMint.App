import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/customer/customer.dart';

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
    var filtered = customers;

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
  CustomerNotifier() : super(CustomerState());

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for development
      final mockCustomers = _generateMockCustomers();
      
      state = state.copyWith(
        customers: mockCustomers,
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedCustomers = [...state.customers, customer];
      state = state.copyWith(customers: updatedCustomers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedCustomers = state.customers.map((c) {
        return c.customerId == customer.customerId ? customer : c;
      }).toList();
      
      state = state.copyWith(customers: updatedCustomers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
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

  List<Customer> _generateMockCustomers() {
    return [
      Customer(
        customerId: '1',
        vendorId: 'vendor1',
        name: 'Rajesh Kumar',
        phone: '+919876543210',
        address: 'House 101, MG Road, Bangalore',
        quantity: 2.0,
        rate: 50.0,
        frequency: 'daily',
        active: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Customer(
        customerId: '2',
        vendorId: 'vendor1',
        name: 'Priya Sharma',
        phone: '+919876543211',
        address: 'Flat 205, Green Valley, Bangalore',
        quantity: 1.5,
        rate: 50.0,
        frequency: 'daily',
        active: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Customer(
        customerId: '3',
        vendorId: 'vendor1',
        name: 'Amit Patel',
        phone: '+919876543212',
        address: 'Villa 15, Palm Grove, Bangalore',
        quantity: 3.0,
        rate: 50.0,
        frequency: 'daily',
        active: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Customer(
        customerId: '4',
        vendorId: 'vendor1',
        name: 'Sneha Reddy',
        phone: '+919876543213',
        address: 'Apartment 302, Sunrise Towers, Bangalore',
        quantity: 1.0,
        rate: 50.0,
        frequency: 'alternate',
        active: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Customer(
        customerId: '5',
        vendorId: 'vendor1',
        name: 'Vikram Singh',
        phone: '+919876543214',
        address: 'House 45, Lakeside Layout, Bangalore',
        quantity: 2.5,
        rate: 50.0,
        frequency: 'daily',
        active: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}

/// Providers
final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) => CustomerNotifier(),
);

final filteredCustomersProvider = Provider<List<Customer>>((ref) {
  final state = ref.watch(customerProvider);
  return state.filteredCustomers;
});
