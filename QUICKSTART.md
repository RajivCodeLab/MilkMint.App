# MilkBill - Quick Reference

## ✅ What's Been Completed

### Core Infrastructure
- [x] Dependencies installed (Riverpod, Firebase, Hive, Dio, GoRouter, i18n)
- [x] Project folder structure created
- [x] Theme system (light/dark with Material 3, no inline CSS)
- [x] Multi-language support (English, Hindi, Kannada)
- [x] Firebase configured (Auth, FCM, all platforms)
- [x] Hive offline storage initialized
- [x] API client with auth interceptors
- [x] Authentication service (Firebase Phone OTP)
- [x] Offline queue manager for sync
- [x] App constants and configuration
- [x] User model with Freezed
- [x] Code analysis passed ✅

### Key Files Created
```
lib/
├── core/
│   ├── api/api_client.dart           # Dio HTTP client with interceptors
│   ├── auth/
│   │   ├── auth_service.dart         # Firebase OTP authentication
│   │   └── firebase_service.dart     # Firebase & FCM initialization
│   ├── constants/app_constants.dart  # App-wide constants
│   ├── offline/
│   │   ├── hive_service.dart         # Hive database service
│   │   └── offline_queue_manager.dart # Offline sync queue
│   └── theme/
│       ├── app_colors.dart           # Centralized color palette
│       ├── app_text_styles.dart      # Typography system
│       └── app_theme.dart            # Theme configuration
├── l10n/
│   ├── language_provider.dart        # Language state management
│   └── localization_service.dart     # i18n service
├── models/user_role.dart             # User & UserRole models
├── firebase_options.dart             # Auto-generated Firebase config
└── main.dart                         # App entry point
```

### Assets
```
assets/
├── i18n/
│   ├── en.json   # English translations
│   ├── hi.json   # Hindi translations (हिन्दी)
│   └── kn.json   # Kannada translations (ಕನ್ನಡ)
└── images/       # Ready for app assets
```

## 🚀 How to Run

### First Time Setup
```powershell
# 1. Install dependencies
flutter pub get

# 2. Generate code for Freezed models
dart run build_runner build --delete-conflicting-outputs

# 3. Enable Phone Authentication in Firebase Console
# Go to: Firebase Console > Authentication > Sign-in method > Phone
```

### Run the App
```powershell
# Debug mode
flutter run

# Release build
flutter build apk --release
```

## 📦 Key Packages & Versions

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.6.1 | State management |
| firebase_core | ^3.8.1 | Firebase SDK |
| firebase_auth | ^5.3.4 | Phone OTP authentication |
| firebase_messaging | ^15.1.5 | Push notifications |
| hive_flutter | ^1.1.0 | Offline storage |
| dio | ^5.7.0 | HTTP client |
| go_router | ^14.6.2 | Navigation |
| freezed | ^2.5.7 | Immutable models |

## 🎨 Theme Usage

```dart
// Use theme colors (NO hardcoded colors!)
Container(
  color: Theme.of(context).colorScheme.primary,
  // OR
  color: AppColors.primary,
)

// Use theme text styles (NO hardcoded text styles!)
Text(
  'Hello',
  style: Theme.of(context).textTheme.headlineMedium,
  // OR
  style: AppTextStyles.headlineMedium,
)
```

## 🌍 i18n Usage

```dart
// Use context extension for translations
Text(context.t('auth.login'))
Text(context.t('vendor.customers'))
Text(context.t('common.save'))

// With parameters
context.t('validation.minLength', params: {'count': 8})
```

## 🔥 Firebase Services

### Initialize (Already done in main.dart)
```dart
await FirebaseService.initialize();
```

### Send OTP
```dart
final authService = ref.read(authServiceProvider);
await authService.sendOTP(
  phoneNumber: '+919876543210',
  onCodeSent: (verificationId) {
    // Show OTP input screen
  },
  onError: (error) {
    // Show error message
  },
);
```

### Verify OTP
```dart
final user = await authService.verifyOTP(
  verificationId: verificationId,
  otp: '123456',
);
```

### Get Firebase ID Token
```dart
final token = await authService.getIdToken();
// Automatically added to API requests via interceptor
```

## 💾 Offline Storage

### Save Data
```dart
final box = await HiveService.getCustomerBox();
await box.put('customer_123', customerData);
```

### Queue Offline Action
```dart
await OfflineQueueManager.queueAction(
  actionType: OfflineQueueManager.actionTypeDelivery,
  data: {'customerId': '123', 'delivered': true},
  entityId: 'delivery_456',
);
```

## 🌐 API Client

```dart
// GET request
final response = await ref.read(apiClientProvider).get('/customers');

// POST request
final response = await ref.read(apiClientProvider).post(
  '/delivery-logs',
  data: {'customerId': '123', 'delivered': true},
);

// Firebase token automatically added to headers
// Error handling automatically done
```

## 🎯 Next Steps

### Phase 1: Authentication UI (Recommended Next)
1. Create login screen (phone input)
2. Create OTP verification screen
3. Implement role detection (call backend after OTP verify)
4. Store user role and navigate based on role

### Phase 2: Routing
1. Setup GoRouter with routes
2. Add auth guards (redirect if not authenticated)
3. Role-based navigation (Vendor vs Customer)
4. Deep linking for invoice sharing

### Phase 3: Vendor Dashboard
1. Customer list screen
2. Add/Edit customer form
3. Daily delivery logging screen
4. Delivery calendar view

### Phase 4: Billing
1. Billing calculation logic
2. Invoice generation (PDF)
3. WhatsApp sharing
4. Payment recording

## 📝 Important Conventions

### ❌ DON'T DO
```dart
// DON'T hardcode colors
Container(color: Color(0xFF2196F3))

// DON'T hardcode text styles
Text('Hello', style: TextStyle(fontSize: 16))

// DON'T hardcode strings
Text('Login')

// DON'T assume online connectivity
saveToBackendOnly(); // Will fail offline
```

### ✅ DO THIS
```dart
// USE theme colors
Container(color: AppColors.primary)

// USE theme text styles
Text('Hello', style: AppTextStyles.bodyMedium)

// USE i18n translations
Text(context.t('auth.login'))

// IMPLEMENT offline-first
await saveLocally();
await queueForSync();
trySync(); // Background sync
```

## 🔧 Common Commands

```powershell
# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Clean build
flutter clean

# Regenerate code (after model changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on save)
dart run build_runner watch
```

## 📂 Backend API Endpoints (To be implemented)

```
POST /auth/login                    # Verify Firebase token, get user role
GET  /customers                     # Get vendor's customers
POST /customers                     # Add customer
PUT  /customers/:id                 # Update customer
DELETE /customers/:id               # Delete customer
POST /delivery-logs                 # Log delivery
GET  /delivery-logs                 # Get delivery history
POST /invoices/generate             # Generate invoice
GET  /invoices/:month               # Get invoices
POST /payments                      # Record payment
GET  /payments                      # Get payment history
POST /holidays                      # Request holiday
```

## 🐛 Troubleshooting

### "Target of URI doesn't exist" errors
```powershell
dart run build_runner build --delete-conflicting-outputs
```

### Firebase initialization errors
- Make sure you've enabled Phone Authentication in Firebase Console
- Check `firebase_options.dart` is generated correctly

### Hive errors
```powershell
# Clear Hive boxes
flutter clean
flutter pub get
```

### Build errors
```powershell
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

**Last Updated**: November 15, 2025  
**Status**: ✅ Core infrastructure complete, ready for feature development
