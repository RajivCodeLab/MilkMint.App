import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/holiday_repository.dart';
import '../../../data/providers/remote_data_source_providers.dart';
import '../../../models/holiday/holiday.dart';

/// Holiday repository provider
final holidayRepositoryProvider = Provider<HolidayRepository>((ref) {
  final remoteDataSource = ref.watch(holidayRemoteDataSourceProvider);
  return HolidayRepositoryImpl(remoteDataSource);
});

/// Holiday list provider
final holidayListProvider = StateNotifierProvider<HolidayNotifier, AsyncValue<List<Holiday>>>((ref) {
  final repository = ref.watch(holidayRepositoryProvider);
  return HolidayNotifier(repository);
});

/// Upcoming holidays provider
final upcomingHolidaysProvider = FutureProvider<List<Holiday>>((ref) async {
  final repository = ref.watch(holidayRepositoryProvider);
  return await repository.getUpcomingHolidays();
});

/// Customer holidays provider
final customerHolidaysProvider = FutureProvider.family<List<Holiday>, String>((ref, customerId) async {
  final repository = ref.watch(holidayRepositoryProvider);
  return await repository.getCustomerHolidays(customerId);
});

/// Holiday notifier
class HolidayNotifier extends StateNotifier<AsyncValue<List<Holiday>>> {
  final HolidayRepository _repository;

  HolidayNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadHolidays();
  }

  /// Load all holidays
  Future<void> loadHolidays({
    int page = 1,
    int limit = 100,
    String? status,
    String? customerId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final holidays = await _repository.getHolidays(
        page: page,
        limit: limit,
        status: status,
        customerId: customerId,
      );
      state = AsyncValue.data(holidays);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Create holiday request
  Future<void> createHoliday({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    try {
      final newHoliday = await _repository.createHoliday(
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      // Add to current list
      state.whenData((holidays) {
        state = AsyncValue.data([newHoliday, ...holidays]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update holiday status (vendor only)
  Future<void> updateHolidayStatus(
    String id, {
    required String status,
    String? vendorNotes,
  }) async {
    try {
      final updatedHoliday = await _repository.updateHolidayStatus(
        id,
        status: status,
        vendorNotes: vendorNotes,
      );

      // Update in current list
      state.whenData((holidays) {
        final updatedList = holidays.map((h) {
          return h.id == id ? updatedHoliday : h;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Cancel holiday
  Future<void> cancelHoliday(String id) async {
    try {
      await _repository.cancelHoliday(id);

      // Remove from current list
      state.whenData((holidays) {
        final updatedList = holidays.where((h) => h.id != id).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Refresh holidays
  Future<void> refresh() async {
    await loadHolidays();
  }
}
