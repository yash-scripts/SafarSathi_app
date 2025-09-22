import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/emergency_contact_model.dart';
import '../services/emergency_contact_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final EmergencyContactService _emergencyContactService =
      EmergencyContactService();
  List<EmergencyContact> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    final emergencyContacts =
        await _emergencyContactService.getEmergencyContacts();
    setState(() {
      _emergencyContacts = emergencyContacts;
    });
  }

  Future<void> _addEmergencyContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        if (contact.phones.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected contact does not have a phone number.'),
            ),
          );
          return;
        }

        final newContact = EmergencyContact.fromContact(contact);

        if (_emergencyContacts.any((c) => c.id == newContact.id)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This contact is already in your emergency list.'),
            ),
          );
          return;
        }

        setState(() {
          _emergencyContacts.add(newContact);
        });
        await _emergencyContactService.saveEmergencyContacts(_emergencyContacts);
      }
    }
  }

  Future<void> _removeEmergencyContact(EmergencyContact contact) async {
    setState(() {
      _emergencyContacts.remove(contact);
    });
    await _emergencyContactService.saveEmergencyContacts(_emergencyContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: ListView.builder(
        itemCount: _emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = _emergencyContacts[index];
          return _ContactListItem(
            contact: contact,
            onDelete: () => _removeEmergencyContact(contact),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEmergencyContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ContactListItem extends StatelessWidget {
  const _ContactListItem({
    required this.contact,
    required this.onDelete,
  });

  final EmergencyContact contact;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.name),
      subtitle: Text(contact.phone),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
