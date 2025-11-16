import 'package:hive/hive.dart';

/// Notification item model for local storage
class NotificationItem extends HiveObject {
  final String id;
  final String title;
  final String body;
  final String type; // invoice, payment, delivery, holiday, customer, general
  final String? route;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.route,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  /// Create from FCM RemoteMessage
  factory NotificationItem.fromRemoteMessage({
    required String messageId,
    required String? title,
    required String? body,
    required Map<String, dynamic> data,
  }) {
    return NotificationItem(
      id: messageId,
      title: title ?? 'Notification',
      body: body ?? '',
      type: data['type'] as String? ?? 'general',
      route: data['route'] as String?,
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );
  }

  /// Mark as read
  void markAsRead() {
    isRead = true;
    save();
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'route': route,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}

/// Hive adapter for NotificationItem
class NotificationItemAdapter extends TypeAdapter<NotificationItem> {
  @override
  final int typeId = 5;

  @override
  NotificationItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationItem(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      type: fields[3] as String,
      route: fields[4] as String?,
      data: fields[5] != null ? Map<String, dynamic>.from(fields[5] as Map) : null,
      timestamp: DateTime.parse(fields[6] as String),
      isRead: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.route)
      ..writeByte(5)
      ..write(obj.data)
      ..writeByte(6)
      ..write(obj.timestamp.toIso8601String())
      ..writeByte(7)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
