# Push Notifications System

## Overview
MilkBill uses Firebase Cloud Messaging (FCM) for real-time push notifications. The notification system supports background/foreground handling, payload-based navigation, and topic subscriptions for targeted notifications.

## Architecture

### NotificationService
Location: `lib/core/services/notification_service.dart`

**Key Features:**
- FCM token registration and refresh
- Background and foreground message handling
- Payload-based navigation routing
- Topic subscriptions (user-specific, role-based, vendor-specific)
- Automatic cleanup on logout

### Notification Flow

#### 1. **Initialization** (on app start)
```dart
// In main.dart
final notificationService = ref.read(notificationServiceProvider);
await notificationService.initialize(navigatorKey: _navigatorKey);
```

#### 2. **Login** (automatic topic subscription)
When user logs in, `AuthNotifier` automatically subscribes to relevant topics:
- `user_{userId}` - User-specific notifications
- `vendors` / `customers` / `delivery_agents` - Role-based
- `vendor_{vendorId}` - Vendor-specific (if customer/agent)
- `vendor_{vendorId}_customers` - Vendor's customers (if customer)
- `vendor_{vendorId}_agents` - Vendor's delivery agents (if agent)

#### 3. **Notification Handling**

**Foreground (app open):**
- Shows in-app SnackBar with notification content
- "View" button navigates to relevant screen

**Background (app minimized):**
- System notification shown automatically
- Tap navigates to relevant screen

**Terminated (app killed):**
- System notification shown automatically
- Tap launches app and navigates to relevant screen
- Pending navigation handled after app initialization

#### 4. **Logout** (automatic cleanup)
- Unsubscribes from all topics
- Deletes FCM token from device
- Backend should remove token from database

## Notification Types & Routing

### Payload Structure
```json
{
  "notification": {
    "title": "New Invoice",
    "body": "Your bill for March is ready"
  },
  "data": {
    "type": "invoice",
    "route": "/billing",
    "customerId": "123",
    "invoiceId": "INV-001"
  }
}
```

### Supported Types

| Type | Route | Data Fields | Use Case |
|------|-------|-------------|----------|
| `invoice` | `/billing` | `customerId`, `invoiceId` | New monthly bill generated |
| `payment` | `/payments` | `customerId`, `paymentId` | Payment received/confirmed |
| `delivery` | `/delivery-log` | `customerId`, `date` | Delivery status update |
| `holiday` | `/holiday-request` | `customerId`, `requestId` | Holiday request approved/rejected |
| `customer` | `/edit-customer` | `customerId` | Customer profile updated |
| `general` | `/` (home) | - | General announcements |

## Topic Subscription Strategy

### User Topics
- **Format:** `user_{userId}`
- **Purpose:** Personal notifications (your invoice, your payment)
- **Auto-subscribe:** On login

### Role Topics
- **Vendors:** `vendors`
- **Customers:** `customers`
- **Delivery Agents:** `delivery_agents`
- **Purpose:** Role-wide announcements (new feature, maintenance)

### Vendor-Specific Topics
- **Vendor:** `vendor_{vendorId}`
- **Vendor's Customers:** `vendor_{vendorId}_customers`
- **Vendor's Agents:** `vendor_{vendorId}_agents`
- **Purpose:** Vendor-level updates (vendor offline, bulk notifications)

## Backend Integration

### 1. FCM Token Registration
**Endpoint:** `POST /users/fcm-token`

**Request:**
```json
{
  "token": "fcm_device_token_here",
  "deviceId": "device_unique_id",
  "platform": "android" // or "ios"
}
```

**Response:**
```json
{
  "success": true,
  "message": "FCM token registered"
}
```

**Backend Logic:**
- Extract userId from Firebase Auth token (Authorization header)
- Update user document: `users.fcmTokens.push(token)`
- If token already exists for this device, update it
- On logout, remove token from array

### 2. Sending Notifications

#### To Single User
```javascript
// Using Firebase Admin SDK
const message = {
  notification: {
    title: 'New Invoice',
    body: 'Your bill for March is ready'
  },
  data: {
    type: 'invoice',
    route: '/billing',
    customerId: '123',
    invoiceId: 'INV-001'
  },
  token: userFcmToken // from users.fcmTokens[]
};

await admin.messaging().send(message);
```

#### To Topic (Bulk)
```javascript
const message = {
  notification: {
    title: 'System Maintenance',
    body: 'App will be down for 30 minutes'
  },
  data: {
    type: 'general',
    route: '/'
  },
  topic: 'vendors' // or 'vendor_123_customers'
};

await admin.messaging().send(message);
```

### 3. Use Cases

**Invoice Generated (1st of month):**
```javascript
// Send to specific customer
topic: `user_${customerId}`
type: 'invoice'
data: { customerId, invoiceId, amount, month }
```

**Payment Received:**
```javascript
// Notify vendor
topic: `user_${vendorId}`
type: 'payment'
data: { customerId, paymentId, amount, customerName }
```

**Delivery Reminder:**
```javascript
// Remind delivery agent
topic: `vendor_${vendorId}_agents`
type: 'delivery'
data: { date, pendingCount }
```

**Holiday Request:**
```javascript
// Notify vendor of customer holiday request
topic: `user_${vendorId}`
type: 'holiday'
data: { customerId, customerName, startDate, endDate }
```

## Testing

### 1. Test FCM Token Generation
```bash
# Run app on physical device (emulator doesn't support FCM reliably)
flutter run -d <device_id>

# Check logs for:
# ✅ FCM Token: f9c8d7...
```

### 2. Send Test Notification (Firebase Console)
1. Firebase Console → Cloud Messaging → Send test message
2. Add FCM token from app logs
3. Add notification:
   - **Title:** Test Invoice
   - **Body:** Your bill is ready
4. Add data:
   ```json
   {
     "type": "invoice",
     "route": "/billing"
   }
   ```
5. Send → Verify app receives and navigates

### 3. Test States

**Foreground:**
- App open → Send notification → Should show SnackBar → Tap "View" → Navigate

**Background:**
- App minimized → Send notification → Tap system notification → Navigate

**Terminated:**
- Kill app → Send notification → Tap → App launches and navigates

### 4. Test Topics
1. Login as vendor → Check subscribed topics in Firebase Console
2. Send to `vendors` topic → Verify all vendors receive
3. Send to `vendor_123_customers` → Verify only that vendor's customers receive

## Troubleshooting

### Token Not Registered
- **Check:** Firebase Auth token in API headers
- **Check:** Backend endpoint `/users/fcm-token` exists and works
- **Fix:** Implement token registration endpoint

### Navigation Not Working
- **Check:** NavigatorKey passed to NotificationService.initialize()
- **Check:** Payload has correct `type` and `route` fields
- **Fix:** Verify payload structure matches expected format

### Background Handler Not Working
- **Check:** `firebaseMessagingBackgroundHandler` registered before `runApp()`
- **Check:** Handler is top-level function with `@pragma` annotation
- **Fix:** Ensure handler is not inside a class

### Topics Not Working
- **Check:** User logged in (topics subscribed on login)
- **Check:** Topic name format correct (`vendors`, not `Vendors`)
- **Fix:** Call `subscribeToUserTopics()` manually if needed

## Performance Considerations

### Token Refresh
- FCM tokens can expire/refresh
- `_setupTokenRefreshListener()` auto-updates backend
- Ensure backend handles token updates gracefully

### Background Limits
- iOS/Android limit background processing
- Keep background handler lightweight
- Don't perform heavy operations in `firebaseMessagingBackgroundHandler`

### Notification Limits
- FCM has rate limits (per device, per topic)
- Don't spam notifications
- Batch updates where possible (e.g., daily summary instead of per-delivery)

## Security

### Token Security
- FCM tokens are sensitive (can send notifications to device)
- Backend should validate ownership before sending
- Delete tokens on logout

### Payload Validation
- App validates payload structure before navigation
- Invalid payloads fail gracefully (navigate to home)
- Don't trust payload data blindly - validate on backend

## Future Enhancements

### 1. Local Notifications
- Install `flutter_local_notifications`
- Show rich notifications even in foreground
- Custom sounds, vibration patterns
- Notification channels (Android)

### 2. Notification Preferences
- Settings screen for notification preferences
- Toggle notifications per type (invoice, payment, delivery)
- Quiet hours configuration
- Test notification button

### 3. Notification History
- Store received notifications locally
- Notification center screen
- Mark as read/unread
- Clear all

### 4. Rich Notifications
- Images in notifications
- Action buttons (Approve/Reject holiday request)
- Inline reply
- Progress bars (delivery status)

## References
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [FCM Topic Messaging](https://firebase.google.com/docs/cloud-messaging/android/topic-messaging)
