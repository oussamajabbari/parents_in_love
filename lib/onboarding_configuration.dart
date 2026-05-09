import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingConfiguration extends StatelessWidget {
  const OnboardingConfiguration({super.key});

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
          if (usersParameters == null) {
            return AskAgeForm();
          }
          return Text(snapshot.data!.data().toString());
        }
      },
    );
  }
}

class AskAgeForm extends StatefulWidget {
  const AskAgeForm({super.key});

  @override
  AskAgeFormState createState() {
    return AskAgeFormState();
  }
}

class AskAgeFormState extends State<AskAgeForm> {
  final _formKey = GlobalKey<FormState>();
  bool enableNextButton = false;

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
            Text('Quel âge avez-vous ?'),
            TextFormField(
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
            ElevatedButton(
              onPressed: enableNextButton
                  ? () {
                      print('next');
                    }
                  : null,
              child: const Text('Suivant'),
            ),
          ],
        ),
      ),
    );
  }
}
