import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/trip_model.dart';

class DatabaseHelper {
  static const String _tripBoxName = 'trips';

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(TripAdapter());
    await Hive.openBox<Trip>(_tripBoxName);
  }

  Future<void> addTrip(Trip trip) async {
    final box = Hive.box<Trip>(_tripBoxName);
    await box.add(trip);
  }

  Future<List<Trip>> getTrips() async {
    final box = Hive.box<Trip>(_tripBoxName);
    return box.values.toList();
  }

  Future<void> updateTrip(Trip trip) async {
    await trip.save();
  }

  Future<void> deleteTrip(Trip trip) async {
    await trip.delete();
  }
}
