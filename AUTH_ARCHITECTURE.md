# Authentication Architecture - Complete Implementation

## 📂 Files Created

### Data Transfer Objects
- **`lib/data/dto/auth_dto.dart`**
  - `LoginRequestDto` - Firebase ID token request
  - `LoginResponseDto` - User + backend token response
  - `SendOtpRequestDto` - Phone number for OTP
  - `VerifyOtpRequestDto` - Verification ID + OTP code

### Data Sources

#### Local (Hive Storage)
- **`lib/data/data_sources/local/auth_local_ds.dart`**
  - `saveUser()` - Store user in Hive
  - `getUser()` - Retrieve current user
  - `saveToken()` - Store auth token
  - `getToken()` - Get auth token
  - `clearAuth()` - Logout cleanup
  - `isLoggedIn()` - Check auth status

#### Remote (API)
- **`lib/data/data_sources/remote/auth_remote_ds.dart`**
  - `login()` - POST /auth/login with Firebase token
  - `checkPhoneExists()` - GET /auth/check-phone
  - `getUserProfile()` - GET /auth/profile/:uid
  - `updateFcmToken()` - POST /auth/fcm-token

### Repository Layer
- **`lib/data/repositories/auth_repository.dart`**
  - **Interface**: `AuthRepository` (abstract class)
  - **Implementation**: `AuthRepositoryImpl`
  
  **Methods**:
  - `sendOtp()` - Send OTP via Firebase
  - `verifyOtp()` - Verify OTP and get UserCredential
  - `loginWithFirebase()` - Login with backend, get user role
  - `getCurrentUser()` - Get user from local storage
  - `getAuthToken()` - Get auth token
  - `isLoggedIn()` - Check login status
  - `logout()` - Sign out and clear data
  - `updateFcmToken()` - Update FCM token

### Application Layer (Riverpod)

#### State
- **`lib/features/auth/application/auth_state.dart`** (Freezed)
  - `initial()` - Checking auth status
  - `unauthenticated()` - Not logged in
  - `sendingOtp()` - Sending OTP
  - `otpSent(verificationId)` - OTP sent, ready for verification
  - `verifyingOtp()` - Verifying OTP
  - `authenticating()` - Calling backend
  - `authenticated(user)` - Logged in with user data
  - `error(message)` - Authentication error

#### Notifier
- **`lib/features/auth/application/auth_notifier.dart`**
  - `sendOtp(phoneNumber)` - Initiate OTP flow
  - `verifyOtp(otp)` - Complete OTP verification
  - `resendOtp(phoneNumber)` - Resend OTP
  - `logout()` - Sign out
  - `updateFcmToken(token)` - Update FCM token
  - `resetToUnauthenticated()` - Reset state

#### Providers
- **`lib/features/auth/application/auth_provider.dart`**
  - `authServiceProvider` - Firebase AuthService
  - `firebaseAuthProvider` - FirebaseAuth instance
  - `authLocalDataSourceProvider` - Hive data source
  - `authRemoteDataSourceProvider` - API data source
  - `authRepositoryProvider` - Auth repository
  - `authProvider` - StateNotifier for auth state
  - `currentUserProvider` - Current user (computed)
  - `userRoleProvider` - User role (computed)
  - `isAuthenticatedProvider` - Auth status (computed)
  - `isAuthLoadingProvider` - Loading state (computed)

## 🔄 Authentication Flow

### 1. Send OTP
```dart
// User enters phone number
final authNotifier = ref.read(authProvider.notifier);
await authNotifier.sendOtp('+919876543210');

// State progression:
// unauthenticated → sendingOtp → otpSent(verificationId)
```

### 2. Verify OTP
```dart
// User enters OTP code
await authNotifier.verifyOtp('123456');

// State progression:
// otpSent → verifyingOtp → authenticating → authenticated(user)

// Internal flow:
// 1. Verify OTP with Firebase → UserCredential
// 2. Get Firebase ID token
// 3. Call backend POST /auth/login with token
// 4. Backend validates token, checks user in DB
// 5. Backend returns user with role (vendor/customer)
// 6. Save user + token to Hive
// 7. Update state to authenticated
```

### 3. Auto-Login (App Restart)
```dart
// AuthNotifier._checkAuthStatus() runs on init
// 1. Check if user exists in Hive
// 2. Check if token exists
// 3. If both exist → authenticated(user)
// 4. Else → unauthenticated
```

### 4. Logout
```dart
await authNotifier.logout();

// Flow:
// 1. Sign out from Firebase
// 2. Clear user from Hive
// 3. Clear token from Hive
// 4. State → unauthenticated
```

## 🗄️ Local Storage Schema (Hive)

**Box**: `user_box`

| Key | Type | Description |
|-----|------|-------------|
| `current_user` | JSON | User model serialized |
| `auth_token` | String | Backend auth token or Firebase ID token |

## 🌐 Backend API Integration

### POST /auth/login
**Request**:
```json
{
  "firebaseIdToken": "eyJhbGciOiJSUzI1..."
}
```

**Response**:
```json
{
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "uid": "firebase_uid_123",
    "phone": "+919876543210",
    "role": "vendor",
    "vendorId": null,
    "language": "en",
    "fcmTokens": [],
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  },
  "token": "jwt_backend_token_xyz"
}
```

### Fallback Behavior
If backend is unavailable:
- Create default `User` with role = `vendor`
- Use Firebase ID token as auth token
- Save to Hive
- User can still use app (offline-first)

## 🎯 Usage Examples

### In Screens
```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      initial: () => SplashScreen(),
      unauthenticated: () => PhoneInputScreen(),
      sendingOtp: () => LoadingIndicator('Sending OTP...'),
      otpSent: (verificationId) => OtpInputScreen(verificationId),
      verifyingOtp: () => LoadingIndicator('Verifying...'),
      authenticating: () => LoadingIndicator('Logging in...'),
      authenticated: (user) {
        // Navigate based on role
        if (user.role == UserRole.vendor) {
          return VendorHomeScreen();
        } else {
          return CustomerHomeScreen();
        }
      },
      error: (message) => ErrorScreen(message),
    );
  }
}
```

### Check Current User
```dart
final user = ref.watch(currentUserProvider);
if (user != null) {
  print('Logged in as: ${user.phone}, Role: ${user.role}');
}
```

### Check Auth Status
```dart
final isAuthenticated = ref.watch(isAuthenticatedProvider);
if (isAuthenticated) {
  // Show authenticated UI
}
```

### Role-Based UI
```dart
final userRole = ref.watch(userRoleProvider);

if (userRole == UserRole.vendor) {
  return VendorDashboard();
} else if (userRole == UserRole.customer) {
  return CustomerDashboard();
}
```

## 🔐 Security Features

1. **Firebase Authentication**
   - Phone OTP via Firebase Auth
   - Automatic token refresh
   - Secure credential handling

2. **Backend Validation**
   - Firebase ID token verified on backend
   - Role assignment based on phone number
   - JWT token for subsequent API calls

3. **Offline Security**
   - Hive encrypted storage (can be enabled)
   - Token stored locally for offline access
   - Auto-refresh on 401 errors

4. **API Security**
   - All API calls include auth token in header
   - Automatic retry on token expiration
   - Error handling for network failures

## 📊 State Management Architecture

```
AuthNotifier (StateNotifier)
    ↓
AuthRepository (Business Logic)
    ↓
    ├─→ AuthService (Firebase OTP)
    ├─→ AuthLocalDataSource (Hive Storage)
    └─→ AuthRemoteDataSource (Backend API)
```

## 🚀 Next Steps

1. **Create Login UI**
   - Phone input screen
   - OTP verification screen
   - Loading states
   - Error handling

2. **Role-Based Routing**
   - GoRouter setup
   - Auth guards
   - Role-based navigation

3. **FCM Token Sync**
   - Update FCM token on login
   - Send to backend for notifications

4. **Backend Integration**
   - Implement POST /auth/login endpoint
   - User role detection logic
   - JWT token generation

---

**Status**: ✅ Authentication architecture complete and verified  
**Warnings**: 21 duplicate_ignore warnings in generated Freezed files (safe to ignore)
