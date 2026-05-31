import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/theme/app_constants.dart';

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
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLG,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Bienvenue',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Avant de commencer, faisons connaissance en répondant à quelques questions 🙂, promis ça sera rapide 😉',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final String userUid =
                          FirebaseAuth.instance.currentUser!.uid;
                      final userDoc = FirebaseFirestore.instance
                          .collection('users_parameters')
                          .doc(userUid);
                      userDoc.set({
                        'onboarding_stage': 'ask_age',
                      }, SetOptions(merge: true));
                    },
                    child: const Text('Suivant'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
