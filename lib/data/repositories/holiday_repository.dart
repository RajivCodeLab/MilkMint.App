import '../../models/holiday/holiday.dart';
import '../data_sources/remote/holiday_remote_ds.dart';

/// Holiday repository interface
abstract class HolidayRepository {
  Future<Holiday> createHoliday({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  });
  
  Future<List<Holiday>> getHolidays({
    int page = 1,
    int limit = 20,
    String? status,
    String? customerId,
  });
  
  Future<List<Holiday>> getUpcomingHolidays();
  Future<List<Holiday>> getCustomerHolidays(String customerId);
  Future<Holiday> getHolidayById(String id);
  Future<Holiday> updateHolidayStatus(
    String id, {
    required String status,
    String? vendorNotes,
  });
  Future<void> cancelHoliday(String id);
}

/// Holiday repository implementation
class HolidayRepositoryImpl implements HolidayRepository {
  final HolidayRemoteDataSource _remoteDataSource;

  HolidayRepositoryImpl(this._remoteDataSource);

  @override
  Future<Holiday> createHoliday({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    return await _remoteDataSource.createHoliday(
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  @override
  Future<List<Holiday>> getHolidays({
    int page = 1,
    int limit = 20,
    String? status,
    String? customerId,
  }) async {
    return await _remoteDataSource.getHolidays(
      page: page,
      limit: limit,
      status: status,
      customerId: customerId,
    );
  }

  @override
  Future<List<Holiday>> getUpcomingHolidays() async {
    return await _remoteDataSource.getUpcomingHolidays();
  }

  @override
  Future<List<Holiday>> getCustomerHolidays(String customerId) async {
    return await _remoteDataSource.getCustomerHolidays(customerId);
  }

  @override
  Future<Holiday> getHolidayById(String id) async {
    return await _remoteDataSource.getHolidayById(id);
  }

  @override
  Future<Holiday> updateHolidayStatus(
    String id, {
    required String status,
    String? vendorNotes,
  }) async {
    return await _remoteDataSource.updateHolidayStatus(
      id,
      status: status,
      vendorNotes: vendorNotes,
    );
  }

  @override
  Future<void> cancelHoliday(String id) async {
    return await _remoteDataSource.cancelHoliday(id);
  }
}
