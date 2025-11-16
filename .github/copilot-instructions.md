# MilkMint - Copilot Instructions

## Project Overview
MilkMint is a **role-based Flutter mobile app** for milk delivery management. A single app serves three roles dynamically: **Vendor**, **Customer**, and **Delivery Agent** (future). See `prd.md` for full requirements.

**Key Architecture:**
- **Frontend:** Flutter (Android/iOS) with offline-first delivery logging
- **Backend:** NestJS REST APIs + MongoDB Atlas + Firebase Auth (OTP)
- **State Management:** Riverpod or Bloc (not yet implemented)
- **Offline Storage:** Hive or SQLite (not yet implemented)
- **Multi-language:** JSON i18n (`/assets/i18n/en.json`, `hi.json`, `kn.json`)

## Current Project State
**Initial setup is complete and verified.** The core infrastructure is production-ready:
- ✅ Dependencies installed and configured
- ✅ Firebase configured with FlutterFire CLI  
- ✅ Theme system implemented (light/dark with Material 3)
- ✅ Multi-language support (English, Hindi, Kannada)
- ✅ Offline storage (Hive) initialized
- ✅ API client with Firebase auth interceptors
- ✅ Code passes `flutter analyze` with no issues

**Ready to implement**: Authentication UI, routing, and feature modules.

## Critical Development Workflows

### Running the App
```powershell
# Install dependencies (already done)
flutter pub get

# Run code generation for models
dart run build_runner build --delete-conflicting-outputs

# Run on connected device/emulator
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Firebase Setup
Firebase is already configured via FlutterFire CLI. The `firebase_options.dart` file has been generated with configurations for:
- Android: `com.example.milk_manager_app`
- iOS/macOS: `com.example.milkManagerApp`
- Web & Windows apps registered

**Note**: You'll need to enable Firebase Authentication (Phone) in the Firebase Console before using OTP login.

### Testing
```powershell
flutter test
```

### Code Quality
- Uses `flutter_lints: ^5.0.0` with standard Flutter linting rules
- Follow `analysis_options.yaml` conventions

## Architecture Patterns to Implement

### 1. Role-Based UI Rendering
**Critical:** One app, multiple UIs based on user role loaded from backend after Firebase OTP auth.

```dart
// Expected pattern (not yet implemented)
enum UserRole { vendor, customer, deliveryAgent }

// Navigation structure should render different bottom nav per role:
// Vendor: Home | Customers | Deliveries | Billing | Payments | Reports | Settings
// Customer: Home | History | Payments | Holidays | Profile
```

### 2. Offline-First Delivery Logging
**Why:** Vendors work in areas with poor connectivity. Delivery actions must work offline.

**Expected pattern:**
- Queue delivery logs locally (Hive/SQLite)
- Sync to backend (`POST /delivery-logs`) when online
- Backend resolves conflicts using timestamp-based merge

### 3. Firebase Authentication Flow
**All API calls require Firebase ID token:**

```dart
// Pattern to implement
1. User enters phone → Firebase sends OTP
2. User verifies OTP → Firebase Auth signs in
3. App calls backend: POST /auth/login with Firebase ID token
4. Backend validates token, checks if phone exists in users collection
5. If new user → default role = Vendor
6. If phone in vendor's customer list → role = Customer
7. Store role + vendorId locally, attach token to all API headers
```

### 4. Monthly Billing Engine
**Automation is critical:** Vendors expect bills generated automatically on 1st of each month.

**Expected flow:**
- Backend cron job sums `delivery_logs` per customer for previous month
- Creates invoice PDF, uploads to cloud storage
- Sends WhatsApp-shareable link via FCM notification
- Pattern: `POST /invoices/generate` (vendor-triggered) + cron auto-generation

## Data Models (MongoDB Collections)

Reference these when building API integrations:

```javascript
users: { uid, phone, role, vendorId, language, fcmTokens[], createdAt }
vendors: { vendorId, name, phone, address, subscriptionPlan, trialEnd }
customers: { customerId, vendorId, name, phone, address, quantity, rate, frequency, active }
delivery_logs: { vendorId, customerId, date, delivered, quantityDelivered, timestamp }
invoices: { vendorId, customerId, month, totalLiters, amount, pdfUrl, paid }
payments: { paymentId, vendorId, customerId, amount, mode, timestamp }
```

## Key Conventions

### Multi-language Support
- **All user-facing strings** must use i18n keys (never hardcode strings)
- Language preference stored in user profile, changeable in Settings
- Supported: English, Hindi (`hi`), Kannada (`kn`)

### State Management
- **Not yet chosen** - implement using Riverpod or Bloc
- Keep business logic separate from UI
- Offline state must sync with backend state on reconnection

### API Integration
- **Base URL:** To be configured (likely Firebase Functions or NestJS on Railway/Render)
- **Auth header:** `Authorization: Bearer <FirebaseIDToken>`
- **Error handling:** Show user-friendly localized messages for network/auth failures

### External Dependencies & Integration Points

### Firebase Services (✅ Configured)
- **Firebase Auth:** Phone OTP configured via `firebase_options.dart`
- **FCM:** Push notifications setup complete - tokens managed in `FirebaseService`
- **Next Step**: Enable Phone Authentication in Firebase Console
- Store FCM tokens in MongoDB `users.fcmTokens[]`

### Payment Integration (Future)
- UPI deep linking for customers
- Razorpay SDK integration (not in MVP)

### WhatsApp Sharing
- Generate shareable invoice links
- Use WhatsApp URL scheme: `whatsapp://send?text=<invoiceUrl>`

## Common Pitfalls to Avoid

1. **Don't mix roles in one screen** - Always check `userRole` before rendering UI
2. **Don't assume online connectivity** - Delivery logging must work offline
3. **Don't hardcode strings** - Use i18n for all text (vendor speaks Hindi/Kannada)
4. **Don't skip Firebase token validation** - Backend must verify every request
5. **Don't duplicate billing logic** - Billing calculation must be server-side only

## File Structure (To Be Created)

```
lib/
  main.dart                  # App entry point with role-based routing
  core/
    auth/                    # Firebase OTP auth logic
    api/                     # HTTP client + token management
    offline/                 # Hive/SQLite queue management
  features/
    vendor/                  # Customer mgmt, delivery logging, billing
    customer/                # Bill view, holidays, payments
    shared/                  # Common widgets (language selector, etc.)
  models/                    # Data classes matching MongoDB schemas
  l10n/                      # i18n setup (or assets/i18n/*.json)
```

## Testing Strategy

- **Unit tests:** Business logic (billing calculations, offline queue)
- **Widget tests:** Role-based navigation, form validation
- **Integration tests:** Firebase auth flow, API sync after offline
- **Manual testing:** Low-end Android devices (vendors use budget phones)

## Performance Targets (from PRD)
- App load < 2 seconds
- Delivery log action < 300ms (must be instant for offline UX)
- Invoice generation < 2 seconds

---

**When in doubt, refer to `prd.md` for full feature specifications and user workflows.**
