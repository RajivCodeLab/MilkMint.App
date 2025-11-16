import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../application/auth_provider.dart';
import '../../../../models/user_role.dart' as models;

/// Splash screen with authentication check
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Navigate after animation and auth check
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Wait for auth state to be determined (not initial)
    var authState = ref.read(authProvider);
    var attempts = 0;
    debugPrint('🚀 Splash: Starting auth check...');
    
    while (attempts < 20) {
      final isInitial = authState.maybeWhen(
        initial: () => true,
        orElse: () => false,
      );
      
      if (!isInitial) {
        debugPrint('🚀 Splash: Auth state determined after ${attempts * 100}ms');
        break;
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      authState = ref.read(authProvider);
      attempts++;
    }

    if (!mounted) return;

    debugPrint('🚀 Splash: Final auth state: ${authState.toString()}');
    
    authState.when(
      initial: () {
        debugPrint('🚀 Splash: Still initial, going to language selection');
        // Fallback if auth check takes too long
        Navigator.pushReplacementNamed(context, AppRoutes.languageSelection);
      },
      unauthenticated: () {
        debugPrint('🚀 Splash: Unauthenticated, going to language selection');
        Navigator.pushReplacementNamed(context, AppRoutes.languageSelection);
      },
      authenticated: (user) {
        debugPrint('🚀 Splash: Authenticated as ${user.role.name}, going to home');
        // Navigate to home based on role
        final route = _getHomeRoute(user.role);
        Navigator.pushReplacementNamed(context, route);
      },
      requiresOnboarding: (user) {
        debugPrint('🚀 Splash: Requires onboarding');
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      },
      sendingOtp: () {
        debugPrint('🚀 Splash: Sending OTP, going to login');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      otpSent: (_) {
        debugPrint('🚀 Splash: OTP sent, going to login');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      verifyingOtp: () {
        debugPrint('🚀 Splash: Verifying OTP, going to login');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      authenticating: () {
        debugPrint('🚀 Splash: Authenticating, going to login');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      error: (_) {
        debugPrint('🚀 Splash: Error, going to language selection');
        Navigator.pushReplacementNamed(context, AppRoutes.languageSelection);
      },
    );
  }

  String _getHomeRoute(models.UserRole role) {
    switch (role) {
      case models.UserRole.vendor:
        return AppRoutes.vendorHome;
      case models.UserRole.customer:
        return AppRoutes.customerHome;
      case models.UserRole.deliveryAgent:
        return AppRoutes.deliveryHome;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_drink,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App name
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'MilkMint',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Manage Your Milk Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
