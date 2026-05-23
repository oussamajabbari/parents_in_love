import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/onboarding/onboarding.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Auth stream error !');
        } else if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingXL,
              horizontal: AppConstants.spacingMD,
            ),
            child: SignInScreen(
              providers: [EmailAuthProvider()],
              headerBuilder: (context, constraints, shrinkOffset) =>
                  Image.asset('assets/parents_in_love_logo.png'),
            ),
          );
        } else {
          return Onboarding();
        }
      },
    );
  }
}
