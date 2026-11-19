import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/models/user_profile.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AskDescription extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskDescription({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskDescriptionState createState() {
    return AskDescriptionState();
  }
}

class AskDescriptionState extends State<AskDescription> {
  final Stream<DocumentSnapshot<UserProfile>> _currentUserStream =
      UserProfile.snapshots();
  bool initDone = false;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

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
                if (!initDone &&
                    currentUser.description != null &&
                    _descriptionController.text == '') {
                  _descriptionController.text = currentUser.description!;
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
                            'Pour finir, souhaitez-vous ajouter une petite description ?',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),

                          TextField(
                            controller: _descriptionController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
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
                          onPressed: () async {
                            currentUser.description =
                                _descriptionController.text;
                            // This is the last step, mark onboarding as done
                            currentUser.onboardingDone = true;
                            currentUser.save();
                            widget.onNextPressed();
                          },
                          child: const Text("C'est parti ! 🚀"),
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
