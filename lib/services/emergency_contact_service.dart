import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactService {
  static const _emergencyContactsKey = 'emergency_contacts';

  Future<void> saveEmergencyContacts(
      List<EmergencyContact> emergencyContacts) async {
    final prefs = await SharedPreferences.getInstance();
    final emergencyContactsJson = jsonEncode(
      emergencyContacts.map((contact) => contact.toMap()).toList(),
    );
    await prefs.setString(_emergencyContactsKey, emergencyContactsJson);
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final emergencyContactsJson = prefs.getString(_emergencyContactsKey);
    if (emergencyContactsJson != null) {
      final emergencyContactsList = jsonDecode(emergencyContactsJson) as List;
      return emergencyContactsList
          .map((contactMap) => EmergencyContact.fromMap(contactMap))
          .toList();
    }
    return [];
  }
}
