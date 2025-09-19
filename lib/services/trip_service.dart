import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/database_helper.dart';
import '../models/trip_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class TripService {
  static const double _movementThreshold = 2.0; // m/s^2
  static const int _tripEndTimeout = 60; // seconds
  static const double _minTripDistance = 100; // meters

  bool _isMoving = false;
  Timer? _tripEndTimer;
  DateTime? _tripStartTime;
  Position? _lastPosition;
  double _totalDistance = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> start() async {
    _accelerometerSubscription = userAccelerometerEventStream().listen(_onAccelerometerEvent);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _positionSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _tripEndTimer?.cancel();
  }

  void _onAccelerometerEvent(UserAccelerometerEvent event) {
    final double magnitude = (event.x * event.x + event.y * event.y + event.z * event.z).abs();
    if (magnitude > _movementThreshold && !_isMoving) {
      _startTrip();
    } else if (magnitude <= _movementThreshold && _isMoving) {
      _resetTripEndTimer();
    }
  }

  void _startTrip() {
    _isMoving = true;
    _tripStartTime = DateTime.now();
    _totalDistance = 0;
    _positionSubscription = Geolocator.getPositionStream().listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    if (_lastPosition != null) {
      _totalDistance += Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
    }
    _lastPosition = position;
  }

  void _resetTripEndTimer() {
    _tripEndTimer?.cancel();
    _tripEndTimer = Timer(const Duration(seconds: _tripEndTimeout), _endTrip);
  }

  Future<void> _endTrip() async {
    _isMoving = false;
    _positionSubscription?.cancel();

    if (_tripStartTime != null && _totalDistance > _minTripDistance) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_tripStartTime!).inSeconds;
      final avgSpeed = duration > 0 ? _totalDistance / duration : 0;

      final trip = Trip(
        startTime: _tripStartTime!,
        endTime: endTime,
        distance: _totalDistance,
        avgSpeed: avgSpeed.toDouble(), // Corrected type
      );

      await _dbHelper.insert(trip);
      _syncTrips();
    }

    _tripStartTime = null;
    _lastPosition = null;
    _totalDistance = 0;
  }

  Future<void> _syncTrips() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.any((result) => result != ConnectivityResult.none)) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Don't sync if user is not logged in

    final unsyncedTrips = await _dbHelper.getUnsyncedTrips();
    for (final trip in unsyncedTrips) {
      try {
        // The URL now includes the user's unique ID
        final url = 'https://travelapp-3c6b6-default-rtdb.firebaseio.com/trips/${user.uid}.json';
        final response = await http.post(
          Uri.parse(url),
          body: json.encode({
            'startTime': trip.startTime.toIso8601String(),
            'endTime': trip.endTime.toIso8601String(),
            'distance': trip.distance,
            'avgSpeed': trip.avgSpeed,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          trip.isSynced = true;
          await _dbHelper.update(trip);
        }
      } catch (e) {
        // Handle network errors
      }
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    if (result.any((r) => r != ConnectivityResult.none)) {
      _syncTrips();
    }
  }
}
