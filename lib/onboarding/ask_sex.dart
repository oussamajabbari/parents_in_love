import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AskSex extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskSex({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskSexState createState() {
    return AskSexState();
  }
}

enum Sex { woman, man }

class AskSexState extends State<AskSex> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  bool enableNextButton = false;
  Sex? _sex;

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
                'Quel est votre sexe ?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              RadioGroup<Sex>(
                groupValue: _sex,
                onChanged: (Sex? value) {
                  setState(() {
                    _sex = value;
                  });
                },
                child: const Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('Femme'),
                      leading: Radio<Sex>(value: Sex.woman),
                    ),
                    ListTile(
                      title: Text('Homme'),
                      leading: Radio<Sex>(value: Sex.man),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      widget.onPreviousPressed();
                    },
                    child: Text('Précédent'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: enableNextButton
                        ? () {
                            var name = myController.text.trim();
                            userDoc.set({
                              'name': name,
                            }, SetOptions(merge: true));
                            widget.onNextPressed();
                          }
                        : null,
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
