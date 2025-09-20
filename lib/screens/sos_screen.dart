
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  String? _emergencyContactNumber;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContact();
  }

  Future<void> _loadEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emergencyContactNumber = prefs.getString('emergency_contact');
    });
  }

  Future<void> _addEmergencyContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        if (contact.phones.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('emergency_contact', contact.phones.first.number);
          _loadEmergencyContact();
        }
      }
    }
  }

  Future<void> _makeSosCall() async {
    if (_emergencyContactNumber != null) {
      final Uri emergencyUri = Uri(scheme: 'tel', path: _emergencyContactNumber);
      await launchUrl(emergencyUri);
      final Uri generalEmergencyUri = Uri(scheme: 'tel', path: '112');
      await launchUrl(generalEmergencyUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add an emergency contact first.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addEmergencyContact,
              child: const Text('Add Emergency Contact'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makeSosCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Make SOS Call'),
            ),
            if (_emergencyContactNumber != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text('Emergency Contact: $_emergencyContactNumber'),
              ),
          ],
        ),
      ),
    );
  }
}
