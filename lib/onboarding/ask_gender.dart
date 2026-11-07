import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/models/user_profile.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AskGender extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskGender({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskGenderState createState() {
    return AskGenderState();
  }
}

class AskGenderState extends State<AskGender> {
  final Stream<DocumentSnapshot<UserProfile>> _currentUserStream =
      UserProfile.snapshots();
  bool initDone = false;
  Gender? gender;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLG),
        child: StreamBuilder<DocumentSnapshot<UserProfile>>(
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
                if (!initDone && currentUser.gender != null && gender == null) {
                  gender = currentUser.gender;
                }
                initDone = true;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Card(
                      margin: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          const SizedBox(height: AppConstants.spacingMD),
                          Text(
                            'Quel est votre sexe ?',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          RadioGroup<Gender>(
                            groupValue: gender,
                            onChanged: (Gender? value) {
                              setState(() {
                                gender = value;
                              });
                            },
                            child: const Column(
                              children: <Widget>[
                                RadioListTile<Gender>(
                                  title: Text('Femme'),
                                  value: Gender.woman,
                                ),
                                RadioListTile<Gender>(
                                  title: Text('Homme'),
                                  value: Gender.man,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            widget.onPreviousPressed();
                          },
                          child: const Text('Précédent'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: gender != null
                              ? () async {
                                  currentUser.gender = gender;
                                  currentUser.save();
                                  widget.onNextPressed();
                                }
                              : null,
                          child: const Text('Suivant'),
                        ),
                      ],
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }
}
