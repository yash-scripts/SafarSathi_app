import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import '../models/emergency_contact_model.dart';
import 'emergency_contact_service.dart';

class SosService {
  final EmergencyContactService _emergencyContactService =
      EmergencyContactService();

  Future<void> sendSms() async {
    List<EmergencyContact> emergencyContacts =
        await _emergencyContactService.getEmergencyContacts();
    if (emergencyContacts.isEmpty) {
      print('No emergency contacts found.');
      return;
    }

    try {
      Position position = await _determinePosition();
      String message =
          'I need help! This is my current location: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      List<String> recipients =
          emergencyContacts.map((contact) => contact.phone).toList();
      await _sendSMS(message, recipients);
    } catch (e) {
      print('Error sending SOS message: $e');
    }
  }

  Future<void> _sendSMS(String message, List<String> recipients) async {
    try {
      String result = await sendSMS(message: message, recipients: recipients, sendDirect: true);
      print(result);
    } catch (error) {
      print(error.toString());
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
}