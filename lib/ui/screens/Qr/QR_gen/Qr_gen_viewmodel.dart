// import 'package:flutter/material.dart';
// import 'dart:convert';


// class QRGenerateViewModel extends ChangeNotifier {
//   String qrData = '';
//   bool isLoading = false;

//   Future<void> loadUserDataAndGenerateQR() async {
//     isLoading = true;
//     notifyListeners();

//     final repo = Repository();
//     final User? user = await repo.getLoggedInUser();

//     if (user != null) {
//       qrData = jsonEncode({
//         'uuid': user.uuid,
//         'email': user.email,
//         'name': user.name,
//       });
//     } else {
//       qrData = jsonEncode({'error': 'No user logged in'});
//     }

//     isLoading = false;
//     notifyListeners();
//   }
// }