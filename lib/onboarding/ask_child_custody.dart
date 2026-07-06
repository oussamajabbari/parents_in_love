import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AskChildCustody extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskChildCustody({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskChildCustodyState createState() => AskChildCustodyState();
}

class AskChildCustodyState extends State<AskChildCustody>
    with AutomaticKeepAliveClientMixin<AskChildCustody> {
  List<DateTime> currentDates = [];
  DateTime? addedDate;
  DateTime? removedDate;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
              'À présent, définissons vos jours de garde et vos jours sans les enfants. 👶🏼',
            ),
            Card(
              margin: EdgeInsets.all(0),
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  firstDayOfWeek: MaterialLocalizations.of(
                    context,
                  ).firstDayOfWeekIndex,
                  calendarType: CalendarDatePicker2Type.multi,
                  dayBuilder:
                      ({
                        required DateTime date,
                        BoxDecoration? decoration,
                        bool? isDisabled,
                        bool? isSelected,
                        bool? isToday,
                        TextStyle? textStyle,
                      }) {
                        if (isSelected != null && isSelected) {
                          return Center(
                            child: Text('👶🏼', style: TextStyle(fontSize: 18)),
                          );
                        } else {
                          return null;
                        }
                      },
                ),
                value: currentDates,
                onValueChanged: (newDates) async {
                  final currentDatesSet = {...currentDates};
                  final newDatesSet = {...newDates};

                  final addedDateSet = newDatesSet.difference(currentDatesSet);
                  final removedDateSet = currentDatesSet.difference(
                    newDatesSet,
                  );

                  addedDate = addedDateSet.firstOrNull;
                  removedDate = removedDateSet.firstOrNull;

                  if (addedDate != null) {
                    final result = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Ajouter des jours de garde'),
                        content: Row(
                          children: getWeekDaysFirstLetters(
                            context,
                          ).map((l) => Text(l)).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'cancel'),
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, addedDate),
                            child: Text('Valider'),
                          ),
                        ],
                      ),
                    );
                    setState(() {
                      currentDates = newDates;
                    });
                  }
                },
              ),
            ),
            Text('new dates: $currentDates'),
            Text('$addedDate'),
            Text('$removedDate'),
          ],
        ),
      ),
    );
  }

  Iterable<String> getWeekDaysFirstLetters(BuildContext context) {
    return [0, 1, 2, 3, 4, 5, 6].map(
      (i) =>
          DateFormat.EEEE(
            Localizations.localeOf(context).languageCode,
          ).dateSymbols.NARROWWEEKDAYS[(i +
                  MaterialLocalizations.of(context).firstDayOfWeekIndex) %
              7],
    );
  }
}
