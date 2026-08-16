import 'package:firebase_blog/data/login_utils.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Login")),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Firebase Blog App",
                  style: TextTheme.of(
                    context,
                  ).headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Image.network(
                  'https://img.icons8.com/color/1200/firebase.jpg',
                  height: 200,
                ),
                SizedBox(height: 8),
                SignInButton(
                  Buttons.google,
                  onPressed: () async {
                    await signInWithGoogle();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
