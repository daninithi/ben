import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/ui/screens/Qr/Qr_scan/Qr_scan_screen.dart';
import 'package:chat_app/ui/screens/Qr/qr_system/Qr_system_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QRSystemScreen extends StatelessWidget {
  const QRSystemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QRSystemViewModel>(
      create: (_) => QRSystemViewModel(),
      child: Consumer<QRSystemViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),

            // backgroundColor: Colors.white,
            
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      const SizedBox(height: 32),
                      const Text(
                        "QR Code System",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Generate or scan QR codes to connect\nwith friends instantly",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // QR Options
                      Column(
                        children: [
                          // Generate QR Code Button
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              child: InkWell(
                                onTap: () {
                                  model.setLoading(true);
                                  Navigator.pushNamed(context, qrGenerate);
                                  model.setLoading(false);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEA911D).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.qr_code_2_rounded,
                                          size: 40,
                                          color: Color(0xFFEA911D),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Generate QR Code',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Create your personal QR code\nfor others to scan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Scan QR Code Button
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              child: InkWell(
                                onTap: () {
                                  model.setLoading(true);
                                  Navigator.pushNamed(context, qrScan);
                                  model.setLoading(false);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEA911D).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.qr_code_scanner_rounded,
                                          size: 40,
                                          color: Color(0xFFEA911D),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Scan QR Code',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Scan someone\'s QR code\nto start chatting',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (model.isLoading)
                        const CircularProgressIndicator(
                          color: Color(0xFFEA911D),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}