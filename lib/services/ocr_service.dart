
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ocr_data_model.dart';

class OcrService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'ocr_data';

  Future<void> addOcrData(OcrData ocrData) {
    return _firestore.collection(_collectionPath).add(ocrData.toJson());
  }
}
