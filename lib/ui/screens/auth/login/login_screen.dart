import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/ui/screens/auth/login/login_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/button_widget.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(AuthService()),
      child: Consumer<LoginViewModel>(builder: (context, modal, _) {
        return Scaffold(
          body: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                40.verticalSpace,
                Text("Login", style: h),
                5.verticalSpace,
                const Text("Login your account"),
                30.verticalSpace,
                CustomTextField(
                  hintText: "Enter email",
                  onChanged: modal.setEmail,
                ),
                20.verticalSpace,
                CustomTextField(
                  hintText: "Enter password",
                  onChanged: modal.setPassword,
                  isPassword: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      final TextEditingController emailController =
                          TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Reset Password'),
                            content: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  String email = emailController.text.trim();
                                  Navigator.of(context).pop();
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(email: email);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Password reset email sent to $email')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}')),
                                    );
                                  }
                                },
                                child: Text('Submit'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: body.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                30.verticalSpace,
                CustomButton(
                  loading: modal.state == ViewState.loading,
                  onPressed: modal.state == ViewState.loading
                      ? null
                      : () async {
                          try {
                            await modal.login();
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Provider.of<UserProvider>(context, listen: false)
                                  .loadUser(user.uid);
                            }
                            context.showSnackBar("Login successfully");
                            Navigator.pushNamed(context, home);
                          } on FirebaseAuthException catch (e) {
                            context.showSnackBar(e.toString());
                          } catch (e) {
                            context.showSnackBar(e.toString());
                          }
                        },
                  text: "Log In",
                ),
                20.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: body.copyWith(color: grey)),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, emailEntry);
                      },
                      child: Text("Sign Up",
                          style: body.copyWith(fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
