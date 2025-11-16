import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../data_sources/remote/customer_remote_ds.dart';
import '../data_sources/remote/delivery_log_remote_ds.dart';
import '../data_sources/remote/holiday_remote_ds.dart';
import '../data_sources/remote/invoice_remote_ds.dart';
import '../data_sources/remote/payment_remote_ds.dart';
import '../data_sources/remote/notification_remote_ds.dart';

/// Provider for Customer Remote Data Source
final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerRemoteDataSource(apiClient);
});

/// Provider for Delivery Log Remote Data Source
final deliveryLogRemoteDataSourceProvider = Provider<DeliveryLogRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DeliveryLogRemoteDataSource(apiClient);
});

/// Provider for Holiday Remote Data Source
final holidayRemoteDataSourceProvider = Provider<HolidayRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HolidayRemoteDataSource(apiClient);
});

/// Provider for Invoice Remote Data Source
final invoiceRemoteDataSourceProvider = Provider<InvoiceRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InvoiceRemoteDataSource(apiClient);
});

/// Provider for Payment Remote Data Source
final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRemoteDataSource(apiClient);
});

/// Provider for Notification Remote Data Source
final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRemoteDataSource(apiClient);
});
