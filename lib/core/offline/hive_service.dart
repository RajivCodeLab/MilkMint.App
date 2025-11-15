import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Hive storage service for offline data
class HiveService {
  HiveService._();

  static bool _isInitialized = false;

  /// Initialize Hive
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Hive already initialized');
      return;
    }

    try {
      await Hive.initFlutter();

      // Register adapters here when models are created
      // Example: Hive.registerAdapter(CustomerAdapter());

      debugPrint('Hive initialized successfully');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Hive initialization error: $e');
      rethrow;
    }
  }

  /// Open a box
  static Future<Box<T>> openBox<T>(String boxName) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('Error opening box $boxName: $e');
      rethrow;
    }
  }

  /// Get user box
  static Future<Box> getUserBox() async {
    return await openBox(AppConstants.userBoxName);
  }

  /// Get customer box
  static Future<Box> getCustomerBox() async {
    return await openBox(AppConstants.customerBoxName);
  }

  /// Get delivery box
  static Future<Box> getDeliveryBox() async {
    return await openBox(AppConstants.deliveryBoxName);
  }

  /// Get invoice box
  static Future<Box> getInvoiceBox() async {
    return await openBox(AppConstants.invoiceBoxName);
  }

  /// Get payment box
  static Future<Box> getPaymentBox() async {
    return await openBox(AppConstants.paymentBoxName);
  }

  /// Get pending actions box (for offline queue)
  static Future<Box> getPendingActionsBox() async {
    return await openBox(AppConstants.pendingActionsBoxName);
  }

  /// Clear all boxes (for logout/reset)
  static Future<void> clearAllBoxes() async {
    try {
      await Hive.deleteBoxFromDisk(AppConstants.userBoxName);
      await Hive.deleteBoxFromDisk(AppConstants.customerBoxName);
      await Hive.deleteBoxFromDisk(AppConstants.deliveryBoxName);
      await Hive.deleteBoxFromDisk(AppConstants.invoiceBoxName);
      await Hive.deleteBoxFromDisk(AppConstants.paymentBoxName);
      await Hive.deleteBoxFromDisk(AppConstants.pendingActionsBoxName);
      debugPrint('All Hive boxes cleared');
    } catch (e) {
      debugPrint('Error clearing boxes: $e');
    }
  }

  /// Close all boxes
  static Future<void> closeAllBoxes() async {
    try {
      await Hive.close();
      debugPrint('All Hive boxes closed');
    } catch (e) {
      debugPrint('Error closing boxes: $e');
    }
  }
}
