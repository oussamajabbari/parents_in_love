import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AskAge extends StatefulWidget {
  const AskAge({super.key});

  @override
  AskAgeState createState() {
    return AskAgeState();
  }
}

class AskAgeState extends State<AskAge> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController(text: '64');
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
            Text('Quel âge avez-vous ?'),
            TextFormField(
              controller: myController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir votre âge';
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
                      'onboarding_stage': 'intro',
                    }, SetOptions(merge: true));
                  },
                  child: Text('Précédent'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: enableNextButton
                      ? () {
                          var age = myController.text;
                          userDoc.set({
                            'age': age,
                            'onboarding_stage': 'ask_name',
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
