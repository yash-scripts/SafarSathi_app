import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bill_model.dart';

class BillService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'bills';

  Future<void> addBill(Bill bill) {
    return _firestore.collection(_collectionPath).add(bill.toJson());
  }
}
