import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AskName extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskName({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskNameState createState() {
    return AskNameState();
  }
}

class AskNameState extends State<AskName>
    with AutomaticKeepAliveClientMixin<AskName> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  bool enableNextButton = false;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                'Quel est votre prénom ?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
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
                      FocusManager.instance.primaryFocus?.unfocus();
                      widget.onPreviousPressed();
                    },
                    child: const Text('Précédent'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: enableNextButton
                        ? () {
                            FocusManager.instance.primaryFocus?.unfocus();
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
