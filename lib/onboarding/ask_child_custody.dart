import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum OnlyOnceOrRepeat { onlyOnce, repeat }

enum ReccurenceUnity { day, week }

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
            const Text(
              'À présent, définissons vos jours de garde et vos jours sans les enfants. 👶🏼',
            ),
            Card(
              margin: const EdgeInsets.all(0), 
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
                          return const Center(
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
                      builder: (BuildContext context) =>
                          AddCustodyDaysDialog(addedDate: addedDate!),
                    );
                    setState(() {
                      currentDates = newDates;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // String getWeekDayFirstLetter(DateTime day) {
  //   return DateFormat.EEEE(
  //     Localizations.localeOf(context).languageCode,
  //   ).dateSymbols.NARROWWEEKDAYS[day.weekday % 7];
  // }

  // Iterable<DateTime> getLocalWeekDaysFromDateTime(
  //   BuildContext context,
  //   DateTime date,
  // ) {
  //   return [0, 1, 2, 3, 4, 5, 6].map((i) {
  //     var deltaToDate =
  //         -date.weekday +
  //         MaterialLocalizations.of(context).firstDayOfWeekIndex +
  //         i;

  //     if (deltaToDate < 0) {
  //       return date.subtract(Duration(days: deltaToDate.abs()));
  //     } else {
  //       return date.add(Duration(days: deltaToDate));
  //     }
  //   });
  // }
}

class AddCustodyDaysDialog extends StatefulWidget {
  const AddCustodyDaysDialog({super.key, required this.addedDate});

  final DateTime addedDate;

  @override
  State<AddCustodyDaysDialog> createState() => _AddCustodyDaysDialogState();
}

class _AddCustodyDaysDialogState extends State<AddCustodyDaysDialog> {
  OnlyOnceOrRepeat? onlyOnceOrRepeat = .onlyOnce;
  int repeatEvery = 2;
  ReccurenceUnity _reccurenceUnity = .week;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajoût de jours de garde'),
      content: Column(
        children: [
          Text(
            DateFormat.yMMMMEEEEd(
              Localizations.localeOf(context).languageCode,
            ).format(widget.addedDate),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          RadioGroup<OnlyOnceOrRepeat>(
            groupValue: onlyOnceOrRepeat,
            onChanged: (OnlyOnceOrRepeat? value) {
              setState(() {
                onlyOnceOrRepeat = value;
              });
            },
            child: const Column(
              children: <Widget>[
                RadioListTile(
                  title: Text('Uniquement ce jour'),
                  value: OnlyOnceOrRepeat.onlyOnce,
                ),
                RadioListTile(
                  title: Text('Répêter tous les:'),
                  value: OnlyOnceOrRepeat.repeat,
                ),
                Text('miaou'),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Enter your number"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ], // Only numbers can be entered
                ),
              ),
              DropdownButton<ReccurenceUnity>(
                value: _reccurenceUnity,
                items: [
                  const DropdownMenuItem(value: .day, child: Text('jours(s)')),
                  const DropdownMenuItem(value: .week, child: Text('semaine(s)')),
                ],
                onChanged: (ReccurenceUnity? value) {
                  setState(() {
                    print('############################### $value');
                    _reccurenceUnity = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, widget.addedDate),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

// AlertDialog(
//                         title: Text('Ajouter des jours de garde'),
//                         insetPadding: EdgeInsets.all(10),
//                         content: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: weekDates
//                                   .map(
//                                     (day) => SizedBox(
//                                       width: 40,
//                                       height: 40,
//                                       child: TextButton(
//                                         style: TextButton.styleFrom(
//                                           shape: CircleBorder(),
//                                           side: BorderSide(),
//                                           fixedSize: Size.fromRadius(10),
//                                           padding: EdgeInsets.all(0),
//                                           backgroundColor:
//                                               addedDate!.weekday == day.weekday
//                                               ? Theme.of(
//                                                   context,
//                                                 ).colorScheme.primary
//                                               : null,
//                                           foregroundColor:
//                                               addedDate!.weekday == day.weekday
//                                               ? Theme.of(
//                                                   context,
//                                                 ).colorScheme.onPrimary
//                                               : null,
//                                         ),
//                                         onPressed: () => print('yagadaaaa'),
//                                         child: Text(getWeekDayFirstLetter(day)),
//                                       ),
//                                     ),
//                                   )
//                                   .toList(),
//                             ),
//                           ],
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context, 'cancel'),
//                             child: Text('Annuler'),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.pop(context, addedDate),
//                             child: Text('Valider'),
//                           ),
//                         ],
//                       )
