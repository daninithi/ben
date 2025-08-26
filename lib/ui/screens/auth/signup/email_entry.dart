import 'package:flutter/material.dart';
import 'package:chat_app/core/services/email_service.dart';
import 'package:chat_app/ui/screens/auth/signup/email_verify.dart';

class EmailEntryScreen extends StatefulWidget {
  @override
  _EmailEntryScreenState createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends State<EmailEntryScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final otp = EmailService.generateOtp();
    final sent = await EmailService.sendOtpEmail(email, otp);
    setState(() => _loading = false);
    if (sent) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerifyScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendOtp,
                    child: Text('Send OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}
