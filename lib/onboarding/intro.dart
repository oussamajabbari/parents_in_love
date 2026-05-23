import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  IntroState createState() {
    return IntroState();
  }
}

class IntroState extends State<Intro> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Avant de commencer, faisons connaissance en répondant à quelques question :-), promis ça sera rapide ;)',
            ),
            ElevatedButton(
              onPressed: () {
                final String userUid = FirebaseAuth.instance.currentUser!.uid;
                final userDoc = FirebaseFirestore.instance
                    .collection('users_parameters')
                    .doc(userUid);
                userDoc.set({
                  'onboarding_stage': 'ask_age',
                }, SetOptions(merge: true));
              },
              child: const Text('Suivant'),
            ),
            OutlinedButton(
              onPressed: FirebaseAuth.instance.signOut,
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
