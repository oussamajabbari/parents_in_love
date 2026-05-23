import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AskName extends StatefulWidget {
  const AskName({super.key});

  @override
  AskNameState createState() {
    return AskNameState();
  }
}

class AskNameState extends State<AskName> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  bool enableNextButton = false;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance
        .collection('users_parameters')
        .doc(userUid);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Quel est votre prénom ?'),
            TextFormField(
              controller: myController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir votre prénom';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  enableNextButton =
                      _formKey.currentState != null &&
                      _formKey.currentState!.validate();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    userDoc.set({
                      'onboarding_stage': 'ask_age',
                    }, SetOptions(merge: true));
                  },
                  child: Text('Précédent'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: enableNextButton
                      ? () {
                          var name = myController.text;
                          userDoc.set({
                            'name': name,
                            'onboarding_stage': 'ask_age',
                          }, SetOptions(merge: true));
                        }
                      : null,
                  child: const Text('Suivant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
