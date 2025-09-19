import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/trip_model.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSampleTrip() async {
    try {
      final trip = Trip(
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now(),
        distance: 25500, // in meters
        avgSpeed: 15.0, // in m/s
      );

      await _firestore.collection('trips').add(trip.toMap());
    } catch (e) {
      debugPrint('Error adding sample trip: $e');
    }
  }
}
