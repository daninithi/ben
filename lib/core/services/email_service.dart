import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static String? _lastOtp;

  static String generateOtp() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    _lastOtp = otp;
    return otp;
  }

  static String? get lastOtp => _lastOtp;

  static Future<bool> sendOtpEmail(String email, String otp) async {
    const serviceId = 'service_jypbjj4';      
    const templateId = 'template_cnunvag';   
    const userId = 'o_YB5emFA2VrFX-u1';
    const url = 'https://api.emailjs.com/api/v1.0/email/send';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'email': email,
          'otp': otp,
        }
      }),
    );

    return response.statusCode == 200;
  }
}
