import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/onboarding/onboarding_gate.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            leading: _isConnected(snapshot)
                ? Image.asset('assets/images/parents_in_love_logo.png')
                : null,
            actions: _isConnected(snapshot)
                ? [
                    IconButton(
                      onPressed: FirebaseAuth.instance.signOut,
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ]
                : null,
            elevation: 10,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
              snapshot.hasError
                  ? Text('Failed to get login status !')
                  : !snapshot.hasData
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spacingSM,
                        0,
                        AppConstants.spacingSM,
                        AppConstants.spacingMD,
                      ),
                      child: Material(
                        elevation: 5,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SignInScreen(
                          providers: [EmailAuthProvider()],
                          headerBuilder: (context, constraints, shrinkOffset) =>
                              Image.asset(
                                'assets/images/parents_in_love_logo.png',
                              ),
                        ),
                      ),
                    )
                  : OnboardingGate(),
            ],
          ),
        );
      },
    );
  }

  bool _isConnected(AsyncSnapshot<User?> snapshot) =>
      !snapshot.hasError && snapshot.hasData;
}
