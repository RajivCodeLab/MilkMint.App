# Offline Sync Service - Technical Documentation

## Overview
The OfflineSyncService provides a robust offline-first architecture for the MilkBill app, ensuring that delivery logs and other critical data are never lost, even in areas with poor connectivity.

## Architecture

### Core Components

1. **OfflineSyncService** (`lib/core/offline/offline_sync_service.dart`)
   - Main service managing offline queue and synchronization
   - Handles connectivity changes automatically
   - Implements retry logic with exponential backoff
   - Provides real-time sync status updates

2. **Hive Queue** (via `HiveService`)
   - Persistent local storage for pending actions
   - Survives app restarts
   - JSON-serialized action format

3. **Connectivity Integration**
   - Listens to network state changes via `connectivity_plus`
   - Auto-triggers sync when connection restored
   - Periodic auto-sync every 5 minutes when online

## Key Features

### 1. Automatic Queueing
```dart
// Queue delivery log for offline sync
await syncService.queueDeliveryLog(deliveryLog);
```

**Queue Structure:**
```json
{
  "id": "unique_log_id",
  "actionType": "delivery_log",
  "data": { ...deliveryLog.toJson() },
  "timestamp": "2025-11-16T10:30:00.000Z",
  "retryCount": 0,
  "lastRetryAt": null
}
```

### 2. Auto-Sync on Connectivity
- Service listens to `connectivity_plus` stream
- When connection restored → triggers `syncAll()`
- Handles WiFi, mobile data, and ethernet

### 3. Timestamp-Based Conflict Resolution
When backend returns 409 (conflict):
```dart
// Compare local vs server timestamps
if (localLog.timestamp > serverLog.timestamp) {
  // Local is newer → force update to server
  PUT /delivery-logs/:id with forceUpdate: true
} else {
  // Server is newer → accept server version
  // Remove from queue
}
```

### 4. Retry Logic
- **Max Attempts:** 3 retries per action
- **Retry Delay:** 30 seconds between attempts
- **Retry on:**
  - Network timeouts
  - Server errors (500, 502, 503)
  - Temporary connection issues
- **Do NOT retry on:**
  - Client errors (400, 404)
  - Validation failures

### 5. Error Handling
```dart
try {
  await syncService.syncDeliveryLogs();
} on ApiException catch (e) {
  if (e.type == ApiExceptionType.noInternet) {
    // Will auto-retry when online
  } else if (e.type == ApiExceptionType.badRequest) {
    // Remove from queue (invalid data)
  }
}
```

## Sync Status Stream

Real-time updates via `StreamProvider`:
```dart
@freezed
class SyncStatus {
  bool isSyncing;          // Currently syncing
  int pendingCount;        // Items in queue
  int syncedCount;         // Successfully synced
  int failedCount;         // Failed this session
  DateTime? lastSyncTime;  // Last successful sync
  String? error;           // Error message if any
}
```

**Usage in UI:**
```dart
final syncStatus = ref.watch(syncStatusProvider);

syncStatus.when(
  data: (status) => SyncStatusBadge(status),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => ErrorWidget(e),
);
```

## API Integration

### Required Backend Endpoints

1. **Create Delivery Log**
   ```
   POST /delivery-logs
   Body: DeliveryLog JSON
   Returns: 201 Created, 409 Conflict
   ```

2. **Update Delivery Log** (for conflict resolution)
   ```
   PUT /delivery-logs/:id
   Body: { ...log, forceUpdate: true, conflictResolution: 'timestamp' }
   Returns: 200 OK
   ```

3. **Expected Conflict Response**
   ```json
   {
     "statusCode": 409,
     "message": "Log already exists",
     "data": { ...serverLog }
   }
   ```

## Integration in Features

### Vendor Delivery Logging
```dart
// In DeliveryLogProvider
final syncService = ref.watch(offlineSyncServiceProvider);

// Mark delivery
await syncService.queueDeliveryLog(deliveryLog);

// Sync service automatically:
// 1. Adds to Hive queue
// 2. Attempts immediate sync if online
// 3. Retries on failure
// 4. Updates status stream
```

### UI Integration
```dart
// In DeliveryLogScreen AppBar
AppBarSyncIndicator()  // Shows pending count badge

// In Dashboard
SyncStatusBadge(showDetails: true)  // Full status card
```

## Configuration

### Constants (in `OfflineSyncService`)
```dart
static const int maxRetryAttempts = 3;
static const Duration retryDelay = Duration(seconds: 30);
static const Duration autoSyncInterval = Duration(minutes: 5);
```

### Hive Box Names (in `AppConstants`)
```dart
static const String pendingActionsBoxName = 'pending_actions';
```

## Testing Offline Scenarios

### 1. Queue Delivery Offline
```dart
// Turn off WiFi/data
await syncService.queueDeliveryLog(log);
// Verify: pendingCount increases
```

### 2. Restore Connection
```dart
// Turn on WiFi/data
// Observe: syncStatus.isSyncing = true
// Wait: syncStatus.syncedCount increases
```

### 3. Conflict Resolution
```dart
// Create same log on two devices offline
// Both sync when online
// Newer timestamp wins
```

### 4. Retry Failures
```dart
// Simulate server error (500)
// Verify: retryCount increments
// After 3 attempts: failedCount increases
```

## Performance Considerations

### Memory
- Queue stored in Hive (disk, not memory)
- Minimal RAM footprint
- StreamController is broadcast (multiple listeners OK)

### Battery
- Connectivity listener is lightweight
- Auto-sync timer runs every 5 minutes
- No polling (event-driven architecture)

### Data Usage
- Only syncs when WiFi/mobile data available
- Batches delivery logs if multiple pending
- Gzip compression via Dio (if enabled)

## Future Enhancements

1. **Selective Sync**
   - User preference: WiFi-only sync
   - Background sync using WorkManager

2. **Batch Syncing**
   - Group multiple logs into single API call
   - Reduce network requests

3. **Conflict UI**
   - Show user when conflicts occur
   - Manual conflict resolution option

4. **Analytics**
   - Track sync success rate
   - Average sync time metrics
   - Network quality indicators

5. **Other Data Types**
   - Payments offline queueing
   - Customer updates
   - Holiday requests

## Troubleshooting

### Logs Won't Sync
1. Check `syncStatus.error` for details
2. Verify backend endpoint is reachable
3. Check Firebase token validity (401 errors)
4. Ensure proper JSON serialization

### Queue Growing Large
1. Check retry count (`retryCount >= 3` stops retrying)
2. Verify no client errors (400) piling up
3. Use `syncService.clearQueue()` as last resort (data loss!)

### Conflicts Not Resolving
1. Ensure `timestamp` field is present and valid
2. Backend must support `forceUpdate` flag
3. Check server logs for PUT /delivery-logs/:id errors

## Code Example: Full Flow

```dart
// 1. User marks delivery (offline)
await markDelivery(customerId: 'C123', quantity: 2.0);
  ↓
// 2. Creates DeliveryLog with synced: false
final log = DeliveryLog(
  customerId: 'C123',
  delivered: true,
  quantityDelivered: 2.0,
  timestamp: DateTime.now(),
  synced: false,
);
  ↓
// 3. Queue in OfflineSyncService
await syncService.queueDeliveryLog(log);
  ↓
// 4. Store in Hive
HiveService.getPendingActionsBox().add(jsonEncode(action));
  ↓
// 5. Update UI
syncStatus = SyncStatus(pendingCount: 1);
  ↓
// 6. Connection restored
onConnectivityChanged([ConnectivityResult.wifi]);
  ↓
// 7. Auto-sync triggered
await syncService.syncDeliveryLogs();
  ↓
// 8. POST to backend
apiClient.post('/delivery-logs', data: log.toJson());
  ↓
// 9. Success → Remove from queue
box.deleteAt(index);
  ↓
// 10. Update UI
syncStatus = SyncStatus(syncedCount: 1, lastSyncTime: now);
```

## Security Considerations

1. **Data Persistence**
   - Hive data is local to device
   - Cleared on logout via `HiveService.clearAllBoxes()`
   - Not encrypted by default (consider Hive encryption)

2. **Token Expiry**
   - ApiClient auto-refreshes Firebase token
   - Retries with new token on 401

3. **Data Integrity**
   - Timestamps ensure chronological accuracy
   - No duplicate logs (ID-based deduplication)

---

**Last Updated:** November 16, 2025  
**Version:** 1.0.0  
**Author:** MilkBill Development Team
