import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/database_helper.dart';
import '../models/trip_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class TripService {
  static const double _tripEndSpeed = 1.0 / 3.6; // 1 km/hr in m/s
  static const int _tripEndTimeout = 60; // seconds
  static const double _minTripDistance = 100; // meters

  bool _isMoving = false;
  bool _isManualTrip = false;
  Timer? _tripEndTimer;
  DateTime? _tripStartTime;
  Position? _lastPosition;
  double _totalDistance = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> start() async {
    await _dbHelper.init();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    _syncTrips(); // Attempt to sync on start
  }

  void dispose() {
    _positionSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _tripEndTimer?.cancel();
  }

  void _startGpsTracking() {
    if (_positionSubscription != null) return;
    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(_onPositionUpdate);
    } catch (e) {
      // Handle location permission denied or other errors
    }
  }

  void _stopGpsTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _onPositionUpdate(Position position) {
    if (_isManualTrip) return;

    final speed = position.speed;

    if (speed > _tripEndSpeed && !_isMoving) {
      _startTrip();
    } else if (speed < _tripEndSpeed && _isMoving) {
      _resetTripEndTimer();
    }

    if (_isMoving) {
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
  }

  Future<void> manualStartTrip() async {
    if (_isMoving) return;
    _isManualTrip = true;
    _startGpsTracking();
    _startTrip();
  }

  Future<void> manualEndTrip() async {
    if (!_isMoving || !_isManualTrip) return;
    _tripEndTimer?.cancel();
    await _endTrip();
    _isManualTrip = false;
    _stopGpsTracking();
  }

  Future<void> addManualTrip(DateTime startTime, DateTime endTime, double distance, double avgSpeed) async {
    final trip = Trip(
      startTime: startTime,
      endTime: endTime,
      distance: distance,
      avgSpeed: avgSpeed,
    );
    await _dbHelper.addTrip(trip);
    _syncTrips();
  }

  void _startTrip() {
    _isMoving = true;
    _tripStartTime = DateTime.now();
    _totalDistance = 0;
  }

  void _resetTripEndTimer() {
    _tripEndTimer?.cancel();
    _tripEndTimer = Timer(const Duration(seconds: _tripEndTimeout), _endTrip);
  }

  Future<void> _endTrip() async {
    if (!_isMoving) return;

    if (_tripStartTime != null && _totalDistance > _minTripDistance) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_tripStartTime!).inSeconds;
      final avgSpeed = duration > 0 ? _totalDistance / duration : 0;

      final trip = Trip(
        startTime: _tripStartTime!,
        endTime: endTime,
        distance: _totalDistance,
        avgSpeed: avgSpeed.toDouble(),
      );

      await _dbHelper.addTrip(trip);
      _syncTrips();
    }

    _isMoving = false;
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
    if (user == null) return;

    final allTrips = await _dbHelper.getTrips();
    final unsyncedTrips = allTrips.where((trip) => !trip.isSynced).toList();

    for (final trip in unsyncedTrips) {
      try {
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
          await _dbHelper.updateTrip(trip);
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
