import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/onboarding/ask_age.dart';
import 'package:parents_in_love/onboarding/ask_name.dart';
import 'package:parents_in_love/onboarding/intro.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance
        .collection('users_parameters')
        .doc(userUid);
    return StreamBuilder(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Auth stream error !');
        } else if (!snapshot.hasData) {
          return Text('Waiting for user doc');
        } else {
          final usersParameters = snapshot.data!.data();
          if (usersParameters == null ||
              !usersParameters.containsKey('onboarding_stage') ||
              usersParameters['onboarding_stage'] == 'intro') {
            return Intro();
          } else if (usersParameters['onboarding_stage'] == 'ask_age') {
            return AskAge();
          } else if (usersParameters['onboarding_stage'] == 'ask_name') {
            return AskName();
          }
          return Text(snapshot.data!.data().toString());
        }
      },
    );
  }
}
