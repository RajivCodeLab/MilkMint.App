# Data Models - MongoDB Schema Mapping

## Generated Models

All models use **Freezed** for immutability and **json_serializable** for JSON mapping.

### ✅ User Model
**File**: `lib/models/user_role.dart`

```dart
User(
  id: String?,              // MongoDB _id
  uid: String,              // Firebase UID
  phone: String,
  role: UserRole,           // enum: vendor, customer, delivery_agent
  vendorId: String?,        // Reference to vendor
  language: String,         // Default: 'en'
  fcmTokens: List<String>,
  createdAt: DateTime?,
  updatedAt: DateTime?,
)
```

### ✅ Vendor Model
**File**: `lib/models/vendor/vendor.dart`

```dart
Vendor(
  id: String?,              // MongoDB _id
  vendorId: String,         // Unique vendor ID
  name: String,
  phone: String,
  address: String,
  subscriptionPlan: String,
  trialEnd: DateTime?,
  active: bool,             // Default: true
  createdAt: DateTime?,
  updatedAt: DateTime?,
)
```

### ✅ Customer Model
**File**: `lib/models/customer/customer.dart`

```dart
Customer(
  id: String?,              // MongoDB _id
  customerId: String,       // Unique customer ID
  vendorId: String,
  name: String,
  phone: String,
  address: String,
  quantity: double,         // Liters per day (default: 1.0)
  rate: double,             // Price per liter
  frequency: String,        // 'daily', 'alternate', 'custom' (default: 'daily')
  active: bool,             // Default: true
  createdAt: DateTime?,
  updatedAt: DateTime?,
)
```

### ✅ DeliveryLog Model
**File**: `lib/models/delivery/delivery_log.dart`

```dart
DeliveryLog(
  id: String?,              // MongoDB _id
  vendorId: String,
  customerId: String,
  date: DateTime,           // Delivery date
  delivered: bool,          // Default: true
  quantityDelivered: double?,
  notes: String?,
  timestamp: DateTime,      // When log was created
  synced: bool,             // Offline tracking (default: false)
  syncedAt: DateTime?,
)
```

### ✅ Invoice Model
**File**: `lib/models/invoice/invoice.dart`

```dart
Invoice(
  id: String?,              // MongoDB _id
  invoiceId: String,        // Unique invoice ID
  vendorId: String,
  customerId: String,
  month: String,            // Format: "YYYY-MM" (e.g., "2025-01")
  year: int,
  totalLiters: double,
  amount: double,
  pdfUrl: String?,          // Cloud storage URL
  paid: bool,               // Default: false
  paidAt: DateTime?,
  generatedAt: DateTime?,
  createdAt: DateTime?,
  updatedAt: DateTime?,
)
```

### ✅ Payment Model
**File**: `lib/models/payment/payment.dart`

```dart
Payment(
  id: String?,              // MongoDB _id
  paymentId: String,        // Unique payment ID
  vendorId: String,
  customerId: String,
  invoiceId: String?,       // Optional: link to invoice
  amount: double,
  mode: String,             // 'cash', 'upi', 'bank_transfer', 'other' (default: 'cash')
  transactionId: String?,   // For digital payments
  notes: String?,
  timestamp: DateTime,
  createdAt: DateTime?,
  updatedAt: DateTime?,
)
```

### ✅ Holiday Model
**File**: `lib/models/holiday/holiday.dart`

```dart
Holiday(
  id: String?,              // MongoDB _id
  customerId: String,
  vendorId: String,
  startDate: DateTime,
  endDate: DateTime,
  reason: String?,
  status: String,           // 'pending', 'approved', 'rejected' (default: 'pending')
  createdAt: DateTime?,
  updatedAt: DateTime?,
)
```

## JSON Serialization

### From MongoDB to Dart
```dart
// MongoDB document has _id field
final mongoDoc = {
  '_id': '507f1f77bcf86cd799439011',
  'customerId': 'CUST001',
  'name': 'Ramesh Kumar',
  // ... other fields
};

// Deserialize
final customer = Customer.fromJson(mongoDoc);
print(customer.id); // '507f1f77bcf86cd799439011'
```

### From Dart to MongoDB
```dart
final customer = Customer(
  customerId: 'CUST001',
  vendorId: 'VEND001',
  name: 'Ramesh Kumar',
  phone: '+919876543210',
  address: 'MG Road, Bangalore',
  rate: 50.0,
);

// Serialize
final json = customer.toJson();
// Result: { '_id': null, 'customerId': 'CUST001', ... }
```

## Code Generation

### Run build_runner
```powershell
# Generate all .freezed.dart and .g.dart files
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Generated Files
For each model (e.g., `customer.dart`), you get:
- `customer.freezed.dart` - Freezed boilerplate (copyWith, equality, etc.)
- `customer.g.dart` - JSON serialization code

## Usage Examples

### Creating a new customer
```dart
final customer = Customer(
  customerId: 'CUST_${DateTime.now().millisecondsSinceEpoch}',
  vendorId: currentUser.vendorId!,
  name: 'Amit Sharma',
  phone: '+919876543210',
  address: 'Jayanagar 4th Block',
  quantity: 2.0,
  rate: 55.0,
  frequency: 'daily',
);

// Save to backend
await customerRepository.addCustomer(customer);
```

### Logging a delivery
```dart
final log = DeliveryLog(
  vendorId: vendor.vendorId,
  customerId: customer.customerId,
  date: DateTime.now(),
  delivered: true,
  quantityDelivered: customer.quantity,
  timestamp: DateTime.now(),
);

// Save offline-first
await deliveryRepository.logDelivery(log);
```

### Generating an invoice
```dart
final invoice = Invoice(
  invoiceId: 'INV_${vendor.vendorId}_202501',
  vendorId: vendor.vendorId,
  customerId: customer.customerId,
  month: '2025-01',
  year: 2025,
  totalLiters: 60.0,
  amount: 3300.0, // 60 liters × ₹55
  generatedAt: DateTime.now(),
);

await invoiceRepository.generateInvoice(invoice);
```

### Recording a payment
```dart
final payment = Payment(
  paymentId: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
  vendorId: vendor.vendorId,
  customerId: customer.customerId,
  invoiceId: invoice.invoiceId,
  amount: 3300.0,
  mode: 'upi',
  transactionId: 'UPI123456789',
  timestamp: DateTime.now(),
);

await paymentRepository.recordPayment(payment);
```

## MongoDB Schema Alignment

| Dart Model | MongoDB Collection | Key Fields |
|------------|-------------------|------------|
| `User` | `users` | `uid`, `phone`, `role`, `vendorId` |
| `Vendor` | `vendors` | `vendorId`, `name`, `subscriptionPlan` |
| `Customer` | `customers` | `customerId`, `vendorId`, `quantity`, `rate` |
| `DeliveryLog` | `delivery_logs` | `vendorId`, `customerId`, `date`, `delivered` |
| `Invoice` | `invoices` | `invoiceId`, `vendorId`, `customerId`, `month` |
| `Payment` | `payments` | `paymentId`, `vendorId`, `customerId`, `amount` |
| `Holiday` | `holidays` | `customerId`, `startDate`, `endDate`, `status` |

## Analysis Warnings (Expected)

The `flutter analyze` command shows warnings for `@JsonKey` annotations:
```
warning - The annotation 'JsonKey.new' can only be used on fields or getters
```

**This is a known Freezed limitation and can be safely ignored.** The generated code works correctly at runtime. The `_id` field properly maps to MongoDB's `_id` field.

## Next Steps

1. ✅ Models generated with Freezed + json_serializable
2. 📋 Create repository interfaces
3. 📋 Implement data sources (local Hive + remote API)
4. 📋 Build repositories with offline-first logic
5. 📋 Create Riverpod providers for each model

---

**Status**: All 7 models generated and verified with code generation
