import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/language_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/role_resolution_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/vendor/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/screens/customer_list_screen.dart';
import '../../features/vendor/presentation/screens/add_customer_screen.dart';
import '../../features/vendor/presentation/screens/edit_customer_screen.dart';
import '../../features/vendor/presentation/screens/delivery_log_screen.dart';
import '../../features/vendor/presentation/screens/billing_screen.dart';
import '../../features/vendor/presentation/screens/payments_screen.dart';
import '../../features/vendor/presentation/screens/reports_screen.dart';
import '../../features/vendor/presentation/screens/settings_screen.dart';
import '../../features/vendor/presentation/screens/edit_profile_screen.dart';
import '../../features/common/presentation/screens/notifications_screen.dart';
import '../../features/customer/presentation/screens/customer_home_screen.dart';
import '../../features/customer/presentation/screens/holiday_request_screen.dart';
import '../../features/customer/presentation/screens/delivery_history_screen.dart';
import '../../features/auth/application/auth_provider.dart';

/// Route configuration for the app
class AppRoutes {
  static const String splash = '/';
  static const String languageSelection = '/language-selection';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String roleResolution = '/role-resolution';
  static const String onboarding = '/onboarding';
  static const String vendorHome = '/vendor-home';
  static const String customerHome = '/customer-home';
  static const String deliveryHome = '/delivery-home';
  static const String customerList = '/customers';
  static const String addCustomer = '/add-customer';
  static const String editCustomer = '/edit-customer';
  static const String deliveryLog = '/delivery-log';
  static const String billing = '/billing';
  static const String payments = '/payments';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String holidayRequest = '/holiday-request';
  static const String deliveryHistory = '/delivery-history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case languageSelection:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            verificationId: args['verificationId'] as String,
            phoneNumber: args['phoneNumber'] as String,
          ),
        );

      case roleResolution:
        return MaterialPageRoute(
          builder: (_) => const RoleResolutionScreen(),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case vendorHome:
        return MaterialPageRoute(
          builder: (_) => const VendorDashboardScreen(),
        );

      case customerList:
        return MaterialPageRoute(
          builder: (_) => const CustomerListScreen(),
        );

      case addCustomer:
        return MaterialPageRoute(
          builder: (_) => const AddCustomerScreen(),
        );

      case editCustomer:
        return MaterialPageRoute(
          builder: (_) => const EditCustomerScreen(),
          settings: settings,
        );

      case deliveryLog:
        return MaterialPageRoute(
          builder: (_) => const DeliveryLogScreen(),
        );

      case billing:
        return MaterialPageRoute(
          builder: (_) => const BillingScreen(),
        );

      case payments:
        return MaterialPageRoute(
          builder: (_) => const PaymentsScreen(),
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      case customerHome:
        return MaterialPageRoute(
          builder: (_) => const CustomerHomeScreen(),
        );

      case holidayRequest:
        return MaterialPageRoute(
          builder: (_) => const HolidayRequestScreen(),
        );

      case deliveryHistory:
        return MaterialPageRoute(
          builder: (_) => const DeliveryHistoryScreen(),
        );

      case deliveryHome:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(
            title: 'Delivery Home',
            icon: Icons.delivery_dining,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

/// Placeholder screen for home screens (to be implemented)
class _PlaceholderScreen extends ConsumerWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (user != null) ...[
              Text('Phone: ${user.phone}'),
              Text('Role: ${user.role.name}'),
              Text('Language: ${user.language}'),
            ],
            const SizedBox(height: 32),
            const Text(
              'This screen will be implemented next',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
