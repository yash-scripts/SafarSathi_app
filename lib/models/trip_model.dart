
class Trip {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // in meters
  final double avgSpeed; // in m/s
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
