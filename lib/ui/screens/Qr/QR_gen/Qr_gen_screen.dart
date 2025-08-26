import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
   State<QRScreen> createState() => _QRScreenState();
}
class _QRScreenState extends State<QRScreen> {
  // Use a late final variable for the unique ID
  late final String uniqueChatId;

  @override
  void initState() {
    super.initState();
    // Generate a new UUID when the widget is initialized
    uniqueChatId = const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    // Check if the current user exists to avoid errors
    if (currentUser == null || currentUser.uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }
    
    // The data to encode in the QR code: a combination of the user's UID and the unique ID
    final qrData = '${currentUser.uid!}_$uniqueChatId';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My QR Code', style: h),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentUser != null) ...[
              // Display the QR code with the new unique data
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
              20.verticalSpace,
              Text(
                'Scan to chat with me',
                style: body.copyWith(color: grey),
              ),
              10.verticalSpace,
              Text(
                currentUser.name ?? '',
                style: h2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}