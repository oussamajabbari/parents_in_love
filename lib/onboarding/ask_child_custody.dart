import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parents_in_love/theme/app_constants.dart';

enum RepeatBase { day, week }

enum CustodyStatus {
  noCustody,
  recurrentCustody,
  exceptionalCustody,
  exceptionalNoCustody,
}

class RecurrentCustody {
  final DateTime startDate;
  int repeatEvery;
  RepeatBase repeatBase;
  DateTime? endDateExcluded;

  RecurrentCustody({
    required this.startDate,
    required this.repeatEvery,
    required this.repeatBase,
  });
}

class Custodies {
  static List<RecurrentCustody> reccurentCustodies = [];
  static List<DateTime> exceptionalCustodies = [];
  static List<DateTime> exceptionalNoCustodies = [];

  static CustodyStatus getCustodyStatusForDate(DateTime date) {
    if (exceptionalCustodies.contains(date)) {
      return .exceptionalCustody;
    }
    if (exceptionalNoCustodies.contains(date)) {
      return .exceptionalNoCustody;
    }

    for (var reccurentCustody in reccurentCustodies) {
      if (date.isBefore(reccurentCustody.startDate)) {
        continue;
      }

      if (reccurentCustody.endDateExcluded != null) {
        if (date.isAtSameMomentAs(reccurentCustody.endDateExcluded!) ||
            date.isAfter(reccurentCustody.endDateExcluded!)) {
          continue;
        }
      }

      var delta = date.difference(reccurentCustody.startDate);
      if (reccurentCustody.repeatBase == RepeatBase.day) {
        if (delta.inDays % reccurentCustody.repeatEvery == 0) {
          return .recurrentCustody;
        }
      } else {
        final deltaWeeks = delta.inDays / 7;
        final deltaWeeksRemainder = delta.inDays % 7;
        if (deltaWeeksRemainder == 0 &&
            deltaWeeks % reccurentCustody.repeatEvery == 0) {
          return .recurrentCustody;
        }
      }
    }

    return .noCustody;
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

class AskChildCustodyState extends State<AskChildCustody>
    with AutomaticKeepAliveClientMixin<AskChildCustody> {
  @override
  bool get wantKeepAlive => true;
  bool? previousIsReccurent;
  int? previousRepeatEvery;
  RepeatBase? previousRepeatBase;

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
                        switch (Custodies.getCustodyStatusForDate(date)) {
                          case .exceptionalCustody:
                            return const Center(
                              child: Text('<3', style: TextStyle(fontSize: 18)),
                            );
                          case .recurrentCustody:
                            return const Center(
                              child: Text(
                                '👶🏼',
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          default:
                            return null;
                        }
                      },
                ),
                value: [],
                onValueChanged: (dates) async {
                  if (Custodies.getCustodyStatusForDate(dates[0]) ==
                      .noCustody) {
                    final result = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => AddCustodyDaysDialog(
                        startDate: dates[0],
                        previousIsReccurent: previousIsReccurent,
                        previousRepeatEvery: previousRepeatEvery,
                        previousRepeatBase: previousRepeatBase,
                      ),
                    );
                    if (result is! String) {
                      final (
                        :startDate as DateTime,
                        :isReccurent as bool,
                        :repeatEvery as int?,
                        :repeatBase as RepeatBase,
                      ) = result;
                      if (isReccurent) {
                        Custodies.reccurentCustodies.add(
                          RecurrentCustody(
                            startDate: startDate,
                            repeatEvery: repeatEvery!,
                            repeatBase: repeatBase,
                          ),
                        );
                      } else {
                        Custodies.exceptionalCustodies.add(startDate);
                      }
                      previousIsReccurent = isReccurent;
                      previousRepeatEvery = repeatEvery;
                      previousRepeatBase = repeatBase;
                    }
                    // Re-trigger the drawing
                    setState(() {});
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                Custodies.reccurentCustodies = [];
                Custodies.exceptionalCustodies = [];
                Custodies.exceptionalNoCustodies = [];
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
  const AddCustodyDaysDialog({
    super.key,
    required this.startDate,
    this.previousIsReccurent,
    this.previousRepeatEvery,
    this.previousRepeatBase,
  });

  final DateTime startDate;
  final bool? previousIsReccurent;
  final int? previousRepeatEvery;
  final RepeatBase? previousRepeatBase;

  @override
  State<AddCustodyDaysDialog> createState() => _AddCustodyDaysDialogState();
}

class _AddCustodyDaysDialogState extends State<AddCustodyDaysDialog> {
  late bool isReccurent;
  late int? repeatEvery;
  late RepeatBase repeatBase;

  @override
  void initState() {
    super.initState();

    isReccurent = widget.previousIsReccurent ?? true;
    repeatEvery = widget.previousRepeatEvery ?? 2;
    repeatBase = widget.previousRepeatBase ?? .week;
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
            ).format(widget.startDate),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          RadioGroup<bool>(
            groupValue: isReccurent,
            onChanged: (bool? value) {
              setState(() {
                isReccurent = value!;
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
                  enabled: isReccurent,
                  initialValue: repeatEvery.toString(),
                  decoration: const InputDecoration(labelText: "nombre"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                  ],
                  onChanged: (value) => setState(() {
                    if (value == '') {
                      repeatEvery = null;
                    } else {
                      repeatEvery = int.parse(value);
                    }
                  }), // Only positive numbers can be entered
                ),
              ),
              const SizedBox(width: 20),
              DropdownButton<RepeatBase>(
                value: repeatBase,
                items: [
                  const DropdownMenuItem(value: .day, child: Text('jours(s)')),
                  const DropdownMenuItem(
                    value: .week,
                    child: Text('semaine(s)'),
                  ),
                ],
                onChanged: isReccurent
                    ? (RepeatBase? value) {
                        setState(() {
                          repeatBase = value!;
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
          onPressed: isReccurent && (repeatEvery == null || repeatEvery == 0)
              ? null
              : () => Navigator.pop(context, (
                  startDate: widget.startDate,
                  isReccurent: isReccurent,
                  repeatEvery: repeatEvery,
                  repeatBase: repeatBase,
                )),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
