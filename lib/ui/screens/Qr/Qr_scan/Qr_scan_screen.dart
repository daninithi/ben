import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/ui/screens/Qr/Qr_scan/Qr_scan_viewmodel.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatelessWidget {
const QRScannerScreen({super.key});

@override
Widget build(BuildContext context) {
return ChangeNotifierProvider(
create: (_) => QRScanViewModel(),
child: Consumer<QRScanViewModel>(
builder: (context, model, _) {
return Scaffold(
appBar: AppBar(
title: const Text('Scan QR Code'),
leading: IconButton(
icon: const Icon(Icons.arrow_back),
onPressed: () => Navigator.pop(context),
),
),
body: Stack(
children: [
MobileScanner(
onDetect: (capture) async {
if (!model.isProcessing) {
final List<Barcode> barcodes = capture.barcodes;
if (barcodes.isNotEmpty) {
final qrData = barcodes.first.rawValue;
if (qrData != null) {
try {
final scannedUser = await model.processScanResult(qrData);
if (scannedUser != null && context.mounted) {
Navigator.pushReplacementNamed(
context,
chatroom,
arguments: scannedUser,
);
} else if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('User not found'),
backgroundColor: Primary,
),
);
}
} catch (e) {
if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error: $e'),
backgroundColor: Primary,
),
);
}
}
}
}
}
},
),
if (model.isProcessing)
Container(
color: Colors.black.withOpacity(0.3),
child: const Center(
child: CircularProgressIndicator(
valueColor: AlwaysStoppedAnimation<Color>(Primary),
),
),
),
],
),
);
},
),
);
}
}