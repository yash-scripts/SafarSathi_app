
import 'package:cloud_firestore/cloud_firestore.dart';

class OcrData {
  final String extractedText;
  final Timestamp timestamp;

  OcrData({required this.extractedText, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'extractedText': extractedText,
        'timestamp': timestamp,
      };
}
