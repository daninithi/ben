import 'package:flutter/material.dart';

class QRSystemViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? qrData;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setQRData(String data) {
    qrData = data;
    notifyListeners();
  }

  // Add QR generation and scanning logic here as needed
}