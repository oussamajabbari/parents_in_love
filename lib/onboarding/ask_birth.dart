import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parents_in_love/theme/app_constants.dart';
import 'package:parents_in_love/models/user_profile.dart';

class AskBirth extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskBirth({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskBirthState createState() {
    return AskBirthState();
  }
}

class AskBirthState extends State<AskBirth> {
  bool enableNextButton = false;
  final Stream<DocumentSnapshot<UserProfile>> _currentUserStream =
      UserProfile.snapshots();
  bool initDone = false;
  DateTime? birthDate;

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
                    currentUser.birthDate != null &&
                    birthDate == null) {
                  birthDate = currentUser.birthDate;
                }
                initDone = true;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Quelle est votre date de naissance ?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(0),
                      child: CalendarDatePicker2(
                        config: CalendarDatePicker2Config(),
                        value: [birthDate],
                        onValueChanged: (dates) => {
                          setState(() {
                            birthDate = dates[0];
                          }),
                        },
                      ),
                    ),
                    birthDate != null
                        ? Text(
                            DateFormat.yMMMMEEEEd(
                              Localizations.localeOf(context).languageCode,
                            ).format(birthDate!),
                          )
                        : Container(),
                    currentUser.isMinor()
                        ? const Text(
                            'Age minimum 18 ans',
                            style: TextStyle(color: Colors.red),
                          )
                        : Container(),
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
                          onPressed: birthDate == null || currentUser.isMinor()
                              ? null
                              : () async {
                                  currentUser.birthDate = birthDate;
                                  currentUser.save();
                                  widget.onNextPressed();
                                },
                          child: const Text('Suivant'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
        ),
      ),
    );
  }
}
