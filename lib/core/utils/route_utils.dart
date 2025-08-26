import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/ui/screens/Qr/QR_gen/Qr_gen_screen.dart';
import 'package:chat_app/ui/screens/Qr/Qr_scan/Qr_scan_screen.dart';
import 'package:chat_app/ui/screens/Qr/qr_system/Qr_system_screen.dart';
import 'package:chat_app/core/models/user.dart';
import 'package:chat_app/ui/screens/auth/login/login_screen.dart';
import 'package:chat_app/ui/screens/auth/signup/email_entry.dart';
import 'package:chat_app/ui/screens/auth/signup/email_verify.dart';
import 'package:chat_app/ui/screens/auth/signup/signup_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigator/bottom_navigator_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigator/chat_list/chatroom/chat_screen.dart';
import 'package:chat_app/ui/screens/wrapper/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/ui/screens/splash/splash_screen.dart';

class RouteUtils {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case emailEntry:
        return MaterialPageRoute(builder: (context) => EmailEntryScreen());
      case emailVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args != null ? args['email'] as String : '';
        return MaterialPageRoute(builder: (context) => EmailVerifyScreen(email: email));
        //auth
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen()); 
      case signup:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args != null ? args['email'] as String : '';
        return MaterialPageRoute(builder: (context) => SignUpScreen(email: email));
        //home
       case home:
        return MaterialPageRoute(builder: (context) => const BottomNavigationsScreen());
      case wrapper:
        return MaterialPageRoute(builder: (context) => const Wrapper());
        //chat
      case chatroom:
        return MaterialPageRoute(builder: (context) => ChatScreen(receiver: args as UserModel,));
      case qrSystem:
        return MaterialPageRoute(builder: (context) => const QRSystemScreen());
      case qrGenerate:
        return MaterialPageRoute(builder: (context) => const QRScreen());
      case qrScan:
        return MaterialPageRoute(builder: (context) => const QRScannerScreen());
        


      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("No Route Found")),
          ),
        );
    }
  }
}