
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class SampleDataGenerator {
  static Future<void> generateSampleTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not logged in
      return;
    }

    final url =
        'https://travelapp-3c6b6-default-rtdb.firebaseio.com/trips/${user.uid}.json';

    final sampleTrips = [
      {
        'startTime': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
        'endTime': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'distance': 15000.0,
        'avgSpeed': 25.0,
      },
      {
        'startTime': DateTime.now().subtract(const Duration(days: 2, hours: 4)).toIso8601String(),
        'endTime': DateTime.now().subtract(const Duration(days: 2, hours: 1)).toIso8601String(),
        'distance': 45000.0,
        'avgSpeed': 40.0,
      },
      {
        'startTime': DateTime.now().subtract(const Duration(days: 3, hours: 1)).toIso8601String(),
        'endTime': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'distance': 5000.0,
        'avgSpeed': 10.0,
      }
    ];

    for (final trip in sampleTrips) {
      try {
        await http.post(
          Uri.parse(url),
          body: json.encode(trip),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('Error sending sample trip: $e');
      }
    }
  }

  static Future<void> generateDetailedTrip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not logged in
      return;
    }

    final url =
        'https://travelapp-3c6b6-default-rtdb.firebaseio.com/trips/${user.uid}.json';

    final startTime = DateTime.now().subtract(const Duration(hours: 1));
    final endTime = DateTime.now();

    final detailedTrip = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distance': 6000.0, // Approx distance in meters
      'avgSpeed': 15.0,
      'locations': [
        {
          'latitude': 10.0269,
          'longitude': 76.3082,
          'timestamp': startTime.add(const Duration(minutes: 5)).toIso8601String(),
        },
        {
          'latitude': 10.0213,
          'longitude': 76.3095,
          'timestamp': startTime.add(const Duration(minutes: 10)).toIso8601String(),
        },
        {
          'latitude': 10.0125,
          'longitude': 76.3112,
          'timestamp': startTime.add(const Duration(minutes: 15)).toIso8601String(),
        },
        {
          'latitude': 10.0051,
          'longitude': 76.3125,
          'timestamp': startTime.add(const Duration(minutes: 20)).toIso8601String(),
        },
        {
          'latitude': 9.9982,
          'longitude': 76.3138,
          'timestamp': startTime.add(const Duration(minutes: 25)).toIso8601String(),
        },
        {
          'latitude': 9.9739,
          'longitude': 76.3150,
          'timestamp': endTime.toIso8601String(),
        },
      ]
    };

    try {
      await http.post(
        Uri.parse(url),
        body: json.encode(detailedTrip),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error sending detailed trip: $e');
    }
  }
}
