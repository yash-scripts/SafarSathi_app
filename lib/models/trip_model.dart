import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final double distance; // in meters

  @HiveField(4)
  final double avgSpeed; // in m/s

  @HiveField(5)
  bool isSynced;

  Trip({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.avgSpeed,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distance': distance,
      'avgSpeed': avgSpeed,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      distance: map['distance'],
      avgSpeed: map['avgSpeed'],
      isSynced: map['isSynced'] == 1,
    );
  }
}
