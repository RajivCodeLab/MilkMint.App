/// App constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MilkMint';
  static const String appVersion = '0.1.0';

  // API Configuration
  static const String baseUrl =
      'http://192.168.1.10:3000/api/v1'; // Updated to match backend route
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String userRoleKey = 'user_role';
  static const String vendorIdKey = 'vendor_id';
  static const String userIdKey = 'user_id';
  static const String authTokenKey = 'auth_token';
  static const String fcmTokenKey = 'fcm_token';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  // Hive Box Names
  static const String userBoxName = 'user_box';
  static const String customerBoxName = 'customer_box';
  static const String deliveryBoxName = 'delivery_box';
  static const String invoiceBoxName = 'invoice_box';
  static const String paymentBoxName = 'payment_box';
  static const String pendingActionsBoxName = 'pending_actions_box';

  // Firebase Collections (for reference, used by backend)
  static const String usersCollection = 'users';
  static const String vendorsCollection = 'vendors';
  static const String customersCollection = 'customers';
  static const String deliveryLogsCollection = 'delivery_logs';
  static const String invoicesCollection = 'invoices';
  static const String paymentsCollection = 'payments';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Delivery Frequency
  static const String frequencyDaily = 'daily';
  static const String frequencyAlternate = 'alternate';
  static const String frequencyCustom = 'custom';

  // Payment Modes
  static const String paymentCash = 'cash';
  static const String paymentUPI = 'upi';
  static const String paymentOnline = 'online';

  // Delivery Status
  static const String delivered = 'delivered';
  static const String notDelivered = 'not_delivered';

  // Invoice Status
  static const String invoicePaid = 'paid';
  static const String invoiceUnpaid = 'unpaid';
  static const String invoicePending = 'pending';

  // Performance Targets (from PRD)
  static const Duration appLoadTarget = Duration(seconds: 2);
  static const Duration deliveryActionTarget = Duration(milliseconds: 300);
  static const Duration invoiceGenerationTarget = Duration(seconds: 2);

  // WhatsApp URL Template
  static String whatsAppShareUrl(String message) =>
      'whatsapp://send?text=${Uri.encodeComponent(message)}';

  // Regex Patterns
  static final RegExp phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Default Values
  static const double defaultQuantity = 1.0;
  static const double defaultRate = 50.0;
  static const int otpLength = 6;
  static const int otpTimeout = 60; // seconds
}
