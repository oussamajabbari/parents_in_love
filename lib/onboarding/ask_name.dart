import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/theme/app_constants.dart';
import 'package:parents_in_love/models/user_profile.dart';

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
  final nameController = TextEditingController();
  bool enableNextButton = false;
  bool initDone = false;
  final Stream<DocumentSnapshot<UserProfile>> _currentUserStream =
      UserProfile.snapshots();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<DocumentSnapshot<UserProfile>>(
      stream: _currentUserStream,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<UserProfile>> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final UserProfile currentUser =
                snapshot.data!.data() ?? UserProfile();
            if (!initDone &&
                currentUser.name != null &&
                currentUser.name != '' &&
                nameController.text == '') {
              nameController.text = currentUser.name!;
              enableNextButton = true;
            }
            initDone = true;

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
                      Text(enableNextButton.toString()),
                      TextFormField(
                        controller: nameController,
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
                                ? () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    var name = nameController.text.trim();
                                    currentUser.name = name;
                                    currentUser.save();
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
          },
    );
  }
}
