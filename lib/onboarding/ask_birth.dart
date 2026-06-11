import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parents_in_love/theme/app_constants.dart';

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

class AskBirthState extends State<AskBirth>
    with AutomaticKeepAliveClientMixin<AskBirth> {
  bool enableNextButton = false;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance
        .collection('users_parameters')
        .doc(userUid);

    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Quelle est votre date de naissance ?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Card(
              margin: EdgeInsets.all(0),
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 130 * 365)),
                lastDate: DateTime.now(),
                onDateChanged: (date) => {
                  setState(() {
                    selectedDate = date;
                  }),
                },
              ),
            ),
            selectedDate != null
                ? Text(
                    DateFormat.yMMMMEEEEd(
                      Localizations.localeOf(context).languageCode,
                    ).format(selectedDate!),
                  )
                : Container(),
            selectedDate != null && !isAdult()
                ? Text(
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
                  child: Text('Précédent'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: selectedDate != null && isAdult()
                      ? () {
                          userDoc.set({
                            'birthDate': Timestamp.fromDate(selectedDate!),
                          }, SetOptions(merge: true));
                          widget.onNextPressed();
                        }
                      : null,
                  child: const Text('Suivant'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool isAdult() {
    return selectedDate != null &&
        selectedDate!.isBefore(
          DateTime.now().subtract(Duration(days: 18 * 365)),
        );
  }

  @override
  bool get wantKeepAlive => true;
}
