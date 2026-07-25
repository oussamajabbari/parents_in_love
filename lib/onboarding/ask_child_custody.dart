import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parents_in_love/theme/app_constants.dart';

enum RepeatBase { day, week }

class CustodyDayDefinition {
  final DateTime startDate;
  bool isRepeated;
  int repeatEvery;
  RepeatBase repeatBase;

  CustodyDayDefinition({
    required this.startDate,
    required this.isRepeated,
    required this.repeatEvery,
    required this.repeatBase,
  });

  @override
  String toString() {
    return '$startDate, isRepeated: $isRepeated, repeatEvery: $repeatEvery, repeatBase: $repeatBase';
  }
}

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

enum CustodyDayStatus {
  noCustody,
  recurrentCustody,
  exceptionalCustody,
  exceptionalNoCustody,
}

class AskChildCustodyState extends State<AskChildCustody>
    with AutomaticKeepAliveClientMixin<AskChildCustody> {
  List<DateTime> currentDates = [];
  DateTime? addedDate;
  DateTime? removedDate;
  List<CustodyDayDefinition> custodies = [];

  @override
  bool get wantKeepAlive => true;

  CustodyDayStatus isCustodyDay(DateTime date) {
    // First look for exceptional custodies
    for (var custody in custodies) {
      if (!custody.isRepeated) {
        if (date == custody.startDate) {
          return CustodyDayStatus.exceptionalCustody;
        }
      }
    }

    for (var custody in custodies) {
      var delta = date.difference(custody.startDate);
      if (delta.inDays < 0) {
        continue;
      }
      if (custody.repeatBase == RepeatBase.day) {
        if (delta.inDays % custody.repeatEvery == 0) {
          return CustodyDayStatus.recurrentCustody;
        }
      } else {
        final deltaWeeks = delta.inDays / 7;
        final deltaWeeksRemainder = delta.inDays % 7;
        if (deltaWeeksRemainder == 0 && deltaWeeks % custody.repeatEvery == 0) {
          return CustodyDayStatus.recurrentCustody;
        }
      }
    }

    return CustodyDayStatus.noCustody;
  }

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
                  dayBuilder:
                      ({
                        required DateTime date,
                        BoxDecoration? decoration,
                        bool? isDisabled,
                        bool? isSelected,
                        bool? isToday,
                        TextStyle? textStyle,
                      }) {
                        if (isCustodyDay(date) ==
                            CustodyDayStatus.recurrentCustody) {
                          return const Center(
                            child: Text('👶🏼', style: TextStyle(fontSize: 18)),
                          );
                        } else {
                          return null;
                        }
                      },
                ),
                value: [],
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
                    if (result is CustodyDayDefinition) {
                      custodies.add(result);
                    }
                    // Re-trigger the drawing
                    setState(() {});
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                custodies = [];
              }),
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCustodyDaysDialog extends StatefulWidget {
  const AddCustodyDaysDialog({super.key, required this.addedDate});

  final DateTime addedDate;

  @override
  State<AddCustodyDaysDialog> createState() => _AddCustodyDaysDialogState();
}

class _AddCustodyDaysDialogState extends State<AddCustodyDaysDialog> {
  late final CustodyDayDefinition custodyDayDefinition;

  @override
  void initState() {
    super.initState();

    custodyDayDefinition = .new(
      startDate: widget.addedDate,
      isRepeated: true,
      repeatEvery: 2,
      repeatBase: .week,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      title: const Text('Ajoût de jours de garde'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat.yMMMMEEEEd(
              Localizations.localeOf(context).languageCode,
            ).format(widget.addedDate),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          RadioGroup<bool>(
            groupValue: custodyDayDefinition.isRepeated,
            onChanged: (bool? value) {
              setState(() {
                custodyDayDefinition.isRepeated = value!;
              });
            },
            child: const Column(
              children: <Widget>[
                RadioListTile(title: Text('Uniquement ce jour'), value: false),
                RadioListTile(
                  title: Text('Répêter tou(te)s les:'),
                  value: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextFormField(
                  enabled: custodyDayDefinition.isRepeated,
                  initialValue: custodyDayDefinition.repeatEvery.toString(),
                  decoration: const InputDecoration(labelText: "nombre"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => setState(() {
                    if (value != '') {
                      custodyDayDefinition.repeatEvery = int.parse(value);
                    }
                  }), // Only numbers can be entered
                ),
              ),
              const SizedBox(width: 20),
              DropdownButton<RepeatBase>(
                value: custodyDayDefinition.repeatBase,
                items: [
                  const DropdownMenuItem(value: .day, child: Text('jours(s)')),
                  const DropdownMenuItem(
                    value: .week,
                    child: Text('semaine(s)'),
                  ),
                ],
                onChanged: custodyDayDefinition.isRepeated
                    ? (RepeatBase? value) {
                        setState(() {
                          custodyDayDefinition.repeatBase = value!;
                        });
                      }
                    : null,
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
          onPressed: () => Navigator.pop(context, custodyDayDefinition),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
