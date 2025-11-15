# MilkBill - Complete Project Structure

## Architecture Overview
Following **Clean Architecture** + **Feature-First** organization with clear layer separation:
- **Presentation Layer**: UI (screens, widgets)
- **Application Layer**: Business logic (providers, controllers, use cases)
- **Data Layer**: Data access (repositories, API clients, models)
- **Core**: Shared utilities, constants, theme

## Complete Folder Structure

```
lib/
├── main.dart                           # App entry point
├── firebase_options.dart               # Auto-generated Firebase config
│
├── core/                               # ✅ Shared/common code
│   ├── api/                            # ✅ HTTP client setup
│   │   ├── api_client.dart             # ✅ Dio client with interceptors
│   │   ├── api_exception.dart          # API error handling
│   │   └── api_endpoints.dart          # API endpoint constants
│   │
│   ├── auth/                           # ✅ Authentication services
│   │   ├── auth_service.dart           # ✅ Firebase Phone OTP
│   │   └── firebase_service.dart       # ✅ Firebase & FCM init
│   │
│   ├── constants/                      # ✅ App constants
│   │   ├── app_constants.dart          # ✅ General constants
│   │   ├── storage_keys.dart           # Storage key constants
│   │   └── route_paths.dart            # Route path constants
│   │
│   ├── offline/                        # ✅ Offline storage
│   │   ├── hive_service.dart           # ✅ Hive initialization
│   │   ├── offline_queue_manager.dart  # ✅ Sync queue
│   │   └── sync_service.dart           # Background sync logic
│   │
│   ├── router/                         # Routing configuration
│   │   ├── app_router.dart             # GoRouter setup
│   │   ├── route_guards.dart           # Auth guards
│   │   └── router_provider.dart        # Router provider
│   │
│   ├── theme/                          # ✅ App theming
│   │   ├── app_colors.dart             # ✅ Color palette
│   │   ├── app_text_styles.dart        # ✅ Typography
│   │   └── app_theme.dart              # ✅ Theme config
│   │
│   ├── utils/                          # Utility functions
│   │   ├── validators.dart             # Form validators
│   │   ├── formatters.dart             # Text formatters
│   │   ├── date_utils.dart             # Date utilities
│   │   ├── connectivity_checker.dart   # Network status
│   │   └── logger.dart                 # Logging utility
│   │
│   └── widgets/                        # Reusable widgets
│       ├── custom_button.dart          # Custom button styles
│       ├── custom_text_field.dart      # Custom input fields
│       ├── loading_indicator.dart      # Loading states
│       ├── error_widget.dart           # Error displays
│       └── empty_state.dart            # Empty state widget
│
├── l10n/                               # ✅ Localization
│   ├── localization_service.dart       # ✅ i18n service
│   └── language_provider.dart          # ✅ Language state
│
├── models/                             # ✅ Data models
│   ├── user/
│   │   ├── user_role.dart              # ✅ User & UserRole models
│   │   ├── user_role.freezed.dart      # ✅ Generated
│   │   └── user_role.g.dart            # ✅ Generated
│   │
│   ├── vendor/
│   │   ├── vendor.dart                 # Vendor model
│   │   ├── vendor.freezed.dart
│   │   └── vendor.g.dart
│   │
│   ├── customer/
│   │   ├── customer.dart               # Customer model
│   │   ├── customer.freezed.dart
│   │   └── customer.g.dart
│   │
│   ├── delivery/
│   │   ├── delivery_log.dart           # Delivery log model
│   │   ├── delivery_log.freezed.dart
│   │   └── delivery_log.g.dart
│   │
│   ├── invoice/
│   │   ├── invoice.dart                # Invoice model
│   │   ├── invoice.freezed.dart
│   │   └── invoice.g.dart
│   │
│   ├── payment/
│   │   ├── payment.dart                # Payment model
│   │   ├── payment.freezed.dart
│   │   └── payment.g.dart
│   │
│   └── holiday/
│       ├── holiday.dart                # Holiday request model
│       ├── holiday.freezed.dart
│       └── holiday.g.dart
│
├── data/                               # Data layer
│   ├── repositories/                   # Repository implementations
│   │   ├── auth_repository.dart        # Auth operations
│   │   ├── vendor_repository.dart      # Vendor data operations
│   │   ├── customer_repository.dart    # Customer CRUD
│   │   ├── delivery_repository.dart    # Delivery logging
│   │   ├── invoice_repository.dart     # Invoice operations
│   │   ├── payment_repository.dart     # Payment operations
│   │   └── holiday_repository.dart     # Holiday requests
│   │
│   ├── data_sources/                   # Data sources
│   │   ├── local/                      # Local data sources
│   │   │   ├── customer_local_ds.dart  # Local customer data
│   │   │   ├── delivery_local_ds.dart  # Local delivery logs
│   │   │   └── user_local_ds.dart      # Local user data
│   │   │
│   │   └── remote/                     # Remote data sources
│   │       ├── auth_remote_ds.dart     # Auth API calls
│   │       ├── customer_remote_ds.dart # Customer API
│   │       ├── delivery_remote_ds.dart # Delivery API
│   │       ├── invoice_remote_ds.dart  # Invoice API
│   │       ├── payment_remote_ds.dart  # Payment API
│   │       └── holiday_remote_ds.dart  # Holiday API
│   │
│   └── dto/                            # Data Transfer Objects
│       ├── auth_dto.dart               # Auth request/response
│       ├── customer_dto.dart           # Customer DTO
│       ├── delivery_dto.dart           # Delivery DTO
│       ├── invoice_dto.dart            # Invoice DTO
│       └── payment_dto.dart            # Payment DTO
│
├── features/                           # Feature modules
│   │
│   ├── auth/                           # Authentication feature
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── language_selection_screen.dart
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── otp_verification_screen.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── phone_input_field.dart
│   │   │       ├── otp_input_field.dart
│   │   │       └── language_selector.dart
│   │   │
│   │   ├── application/
│   │   │   ├── auth_state.dart         # Auth state (freezed)
│   │   │   ├── auth_notifier.dart      # Auth state notifier
│   │   │   └── auth_provider.dart      # Auth providers
│   │   │
│   │   └── domain/
│   │       └── use_cases/
│   │           ├── send_otp_use_case.dart
│   │           ├── verify_otp_use_case.dart
│   │           └── get_user_role_use_case.dart
│   │
│   ├── vendor/                         # Vendor feature module
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── vendor_home_screen.dart
│   │   │   │   ├── customer_list_screen.dart
│   │   │   │   ├── customer_form_screen.dart
│   │   │   │   ├── delivery_logging_screen.dart
│   │   │   │   ├── delivery_calendar_screen.dart
│   │   │   │   ├── billing_screen.dart
│   │   │   │   ├── invoice_list_screen.dart
│   │   │   │   ├── invoice_detail_screen.dart
│   │   │   │   ├── payment_screen.dart
│   │   │   │   ├── payment_history_screen.dart
│   │   │   │   ├── reports_screen.dart
│   │   │   │   └── vendor_settings_screen.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── customer_card.dart
│   │   │       ├── delivery_item.dart
│   │   │       ├── delivery_calendar.dart
│   │   │       ├── invoice_card.dart
│   │   │       ├── payment_card.dart
│   │   │       ├── stats_card.dart
│   │   │       └── vendor_bottom_nav.dart
│   │   │
│   │   ├── application/
│   │   │   ├── customer/
│   │   │   │   ├── customer_state.dart
│   │   │   │   ├── customer_notifier.dart
│   │   │   │   └── customer_provider.dart
│   │   │   │
│   │   │   ├── delivery/
│   │   │   │   ├── delivery_state.dart
│   │   │   │   ├── delivery_notifier.dart
│   │   │   │   └── delivery_provider.dart
│   │   │   │
│   │   │   ├── billing/
│   │   │   │   ├── billing_state.dart
│   │   │   │   ├── billing_notifier.dart
│   │   │   │   └── billing_provider.dart
│   │   │   │
│   │   │   └── payment/
│   │   │       ├── payment_state.dart
│   │   │       ├── payment_notifier.dart
│   │   │       └── payment_provider.dart
│   │   │
│   │   └── domain/
│   │       └── use_cases/
│   │           ├── customer/
│   │           │   ├── add_customer_use_case.dart
│   │           │   ├── update_customer_use_case.dart
│   │           │   ├── delete_customer_use_case.dart
│   │           │   └── get_customers_use_case.dart
│   │           │
│   │           ├── delivery/
│   │           │   ├── log_delivery_use_case.dart
│   │           │   ├── get_deliveries_use_case.dart
│   │           │   └── sync_deliveries_use_case.dart
│   │           │
│   │           ├── billing/
│   │           │   ├── generate_invoice_use_case.dart
│   │           │   ├── get_invoice_use_case.dart
│   │           │   └── share_invoice_use_case.dart
│   │           │
│   │           └── payment/
│   │               ├── record_payment_use_case.dart
│   │               └── get_payments_use_case.dart
│   │
│   ├── customer/                       # Customer feature module
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── customer_home_screen.dart
│   │   │   │   ├── bill_detail_screen.dart
│   │   │   │   ├── delivery_history_screen.dart
│   │   │   │   ├── holiday_request_screen.dart
│   │   │   │   ├── payment_screen.dart
│   │   │   │   └── customer_profile_screen.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── bill_card.dart
│   │   │       ├── delivery_history_item.dart
│   │   │       ├── holiday_card.dart
│   │   │       └── customer_bottom_nav.dart
│   │   │
│   │   ├── application/
│   │   │   ├── bill/
│   │   │   │   ├── bill_state.dart
│   │   │   │   ├── bill_notifier.dart
│   │   │   │   └── bill_provider.dart
│   │   │   │
│   │   │   └── holiday/
│   │   │       ├── holiday_state.dart
│   │   │       ├── holiday_notifier.dart
│   │   │       └── holiday_provider.dart
│   │   │
│   │   └── domain/
│   │       └── use_cases/
│   │           ├── get_current_bill_use_case.dart
│   │           ├── get_delivery_history_use_case.dart
│   │           ├── request_holiday_use_case.dart
│   │           └── make_payment_use_case.dart
│   │
│   ├── shared/                         # Shared widgets/features
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   └── error_screen.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── app_bar_widget.dart
│   │   │       ├── drawer_widget.dart
│   │   │       └── notification_badge.dart
│   │   │
│   │   └── application/
│   │       ├── connectivity/
│   │       │   ├── connectivity_state.dart
│   │       │   ├── connectivity_notifier.dart
│   │       │   └── connectivity_provider.dart
│   │       │
│   │       └── sync/
│   │           ├── sync_state.dart
│   │           ├── sync_notifier.dart
│   │           └── sync_provider.dart
│   │
│   └── settings/                       # Settings feature
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── settings_screen.dart
│       │   │   ├── language_settings_screen.dart
│       │   │   ├── theme_settings_screen.dart
│       │   │   ├── business_info_screen.dart
│       │   │   ├── subscription_screen.dart
│       │   │   └── about_screen.dart
│       │   │
│       │   └── widgets/
│       │       ├── settings_tile.dart
│       │       └── settings_section.dart
│       │
│       └── application/
│           ├── settings_state.dart
│           ├── settings_notifier.dart
│           └── settings_provider.dart
│
└── test/                               # Tests
    ├── unit/
    │   ├── models/
    │   ├── repositories/
    │   └── use_cases/
    │
    ├── widget/
    │   └── screens/
    │
    └── integration/
        └── auth_flow_test.dart

assets/
├── images/                             # ✅ Image assets
│   ├── logo.png
│   ├── placeholder.png
│   └── icons/
│       ├── milk.png
│       ├── delivery.png
│       └── invoice.png
│
└── i18n/                               # ✅ Translations
    ├── en.json                         # ✅ English
    ├── hi.json                         # ✅ Hindi
    └── kn.json                         # ✅ Kannada
```

## Layer Responsibilities

### 📱 Presentation Layer (`features/*/presentation/`)
- **Screens**: Full-page views
- **Widgets**: Reusable UI components
- **Responsibilities**:
  - Display UI
  - Handle user interactions
  - Observe application state
  - Navigate between screens

### 🎯 Application Layer (`features/*/application/`)
- **State**: Freezed state classes
- **Notifiers**: StateNotifier/AsyncNotifier classes
- **Providers**: Riverpod providers
- **Responsibilities**:
  - Manage UI state
  - Execute use cases
  - Handle business logic
  - Coordinate data flow

### 💾 Data Layer (`data/`)
- **Repositories**: Abstract data operations
- **Data Sources**: Local (Hive) & Remote (API)
- **DTOs**: Data transfer objects
- **Responsibilities**:
  - Fetch/store data
  - Cache management
  - Offline-first logic
  - API communication

### 🏗️ Domain Layer (`features/*/domain/`)
- **Use Cases**: Single-responsibility business logic
- **Responsibilities**:
  - Execute specific business operations
  - Coordinate repository calls
  - Transform data between layers

### 🔧 Core Layer (`core/`)
- **Shared utilities, constants, services**
- **Responsibilities**:
  - Provide reusable functionality
  - Define app-wide constants
  - Configure services

## Naming Conventions

### Files
- Snake case: `customer_list_screen.dart`
- Suffixes:
  - `_screen.dart` - Full screens
  - `_widget.dart` - Reusable widgets
  - `_state.dart` - State classes
  - `_notifier.dart` - State notifiers
  - `_provider.dart` - Riverpod providers
  - `_repository.dart` - Repository classes
  - `_use_case.dart` - Use case classes
  - `_dto.dart` - Data transfer objects

### Classes
- Pascal case: `CustomerListScreen`
- Suffixes:
  - `Screen` - Screen widgets
  - `Widget` - Reusable widgets
  - `State` - State classes
  - `Notifier` - Notifiers
  - `Repository` - Repositories
  - `UseCase` - Use cases
  - `Dto` - DTOs

## Key Architectural Patterns

### 1. State Management (Riverpod)
```dart
// State
@freezed
class CustomerState with _$CustomerState {
  factory CustomerState.initial() = _Initial;
  factory CustomerState.loading() = _Loading;
  factory CustomerState.loaded(List<Customer> customers) = _Loaded;
  factory CustomerState.error(String message) = _Error;
}

// Notifier
class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier(this._repository) : super(CustomerState.initial());
  
  final CustomerRepository _repository;
  
  Future<void> loadCustomers() async {
    state = CustomerState.loading();
    try {
      final customers = await _repository.getCustomers();
      state = CustomerState.loaded(customers);
    } catch (e) {
      state = CustomerState.error(e.toString());
    }
  }
}

// Provider
final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) => CustomerNotifier(ref.watch(customerRepositoryProvider)),
);
```

### 2. Repository Pattern
```dart
abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<Customer> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._localDs, this._remoteDs);
  
  final CustomerLocalDataSource _localDs;
  final CustomerRemoteDataSource _remoteDs;
  
  @override
  Future<List<Customer>> getCustomers() async {
    // Try local first (offline-first)
    final localCustomers = await _localDs.getCustomers();
    if (localCustomers.isNotEmpty) {
      return localCustomers;
    }
    
    // Fetch from remote and cache
    final remoteCustomers = await _remoteDs.getCustomers();
    await _localDs.saveCustomers(remoteCustomers);
    return remoteCustomers;
  }
}
```

### 3. Use Case Pattern
```dart
class AddCustomerUseCase {
  AddCustomerUseCase(this._repository);
  
  final CustomerRepository _repository;
  
  Future<Customer> call(Customer customer) async {
    // Validation
    if (customer.name.isEmpty) {
      throw ValidationException('Name is required');
    }
    
    // Business logic
    final newCustomer = await _repository.addCustomer(customer);
    
    return newCustomer;
  }
}
```

## Directory Navigation Tips

- **Working on UI?** → `features/*/presentation/screens/` or `widgets/`
- **Working on business logic?** → `features/*/application/` or `domain/use_cases/`
- **Working on data?** → `data/repositories/` or `data_sources/`
- **Need shared code?** → `core/`
- **Need models?** → `models/`
- **Need translations?** → `assets/i18n/`

## Next Steps

1. Create folder structure (directories already exist for core)
2. Generate models with Freezed
3. Implement repositories
4. Create use cases
5. Build UI screens
6. Wire everything with Riverpod providers

---

**Status**: ✅ Core infrastructure ready | 📋 Feature structure defined
