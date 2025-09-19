import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String title;
  final double amount;
  final DateTime date;

  Bill({required this.title, required this.amount, required this.date});

  // Add a method to convert a Bill object to a Map
  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'date': date,
      };

  // Add a factory method to create a Bill object from a DocumentSnapshot
  factory Bill.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Bill(
      title: data['title'],
      amount: data['amount'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
