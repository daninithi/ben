import 'package:chat_app/core/models/user.dart';
import 'package:chat_app/core/others/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';

class QRScanViewModel extends BaseViewmodel {
  final DatabaseService _db = DatabaseService();
  
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  void setLoading(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  Future<UserModel?> processScanResult(String qrData) async {
    try {
      setLoading(true);

      // 1. Get the current user's UID.
      final currentUserUid = _db.getCurrentUserUid();
      if (currentUserUid == null) {
        debugPrint('Error: Current user not logged in.');
        return null;
      }
      final parts = qrData.split('_');
        if (parts.length < 2) {
          throw Exception('Invalid QR code format.');
        }
      final scannedUserId = parts[0];
      // 2. Load the scanned user's data from the database.
      final scannedUserData = await _db.loadUser(scannedUserId);
      if (scannedUserData == null) {
        debugPrint('Error: Scanned user not found in database.');
        return null;
      }
      final scannedUser = UserModel.fromMap(scannedUserData);

      // 3. Add both users to the 'temporary_chats' collection.
      await _db.createTemporaryChat(currentUserUid, scannedUserId);

      return scannedUser;

    } catch (e) {
      debugPrint('Error processing QR scan: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }
}