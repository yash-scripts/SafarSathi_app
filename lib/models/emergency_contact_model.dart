import 'package:flutter_contacts/contact.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory EmergencyContact.fromContact(Contact contact) {
    return EmergencyContact(
      id: contact.id,
      name: contact.displayName,
      phone: contact.phones.isNotEmpty ? contact.phones.first.number : '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
    );
  }
}
