import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'customer_provider.dart';
import 'delivery_log_provider.dart';

/// Dashboard statistics state
class DashboardStats {
  final int totalCustomers;
  final int activeCustomers;
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final double completionPercentage;
  final double totalDailyQuantity;
  final double totalMonthlyRevenue;

  DashboardStats({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.pendingDeliveries,
    required this.completionPercentage,
    required this.totalDailyQuantity,
    required this.totalMonthlyRevenue,
  });
}

/// Provider for dashboard statistics
final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final customerState = ref.watch(customerProvider);
  final deliveryLogState = ref.watch(deliveryLogProvider);
  
  final totalCustomers = customerState.customers.length;
  final activeCustomers = customerState.activeCount;
  final totalDailyQuantity = customerState.totalDailyQuantity;
  
  // Calculate total deliveries (active customers only)
  final totalDeliveries = activeCustomers;
  
  // Get actual delivery completion data from delivery logs
  final completedDeliveries = deliveryLogState.deliveredCount;
  final pendingDeliveries = totalDeliveries - completedDeliveries;
  
  final completionPercentage = totalDeliveries > 0 
      ? (completedDeliveries / totalDeliveries) * 100 
      : 0.0;
  
  // Calculate monthly revenue estimate (30 days * daily quantity * average rate)
  double totalMonthlyRevenue = 0;
  for (final customer in customerState.customers) {
    if (customer.active) {
      totalMonthlyRevenue += customer.quantity * customer.rate * 30;
    }
  }
  
  return DashboardStats(
    totalCustomers: totalCustomers,
    activeCustomers: activeCustomers,
    totalDeliveries: totalDeliveries,
    completedDeliveries: completedDeliveries,
    pendingDeliveries: pendingDeliveries,
    completionPercentage: completionPercentage,
    totalDailyQuantity: totalDailyQuantity,
    totalMonthlyRevenue: totalMonthlyRevenue,
  );
});

/// Provider for today's date
final todayDateProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider for greeting message
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  
  if (hour < 12) {
    return 'Good Morning';
  } else if (hour < 17) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
});

/// Provider for greeting icon
final greetingIconProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  
  if (hour < 12) {
    return 'morning';
  } else if (hour < 17) {
    return 'afternoon';
  } else {
    return 'evening';
  }
});
