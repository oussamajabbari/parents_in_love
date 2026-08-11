import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parents_in_love/theme/app_constants.dart';

enum RepeatBase {
  day(value: 'day'),
  week(value: 'week');

  const RepeatBase({required this.value});

  final String value;
}

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

  Map<String, dynamic> toSerializableMap() {
    return {
      'startDate': startDate,
      'repeatEvery': repeatEvery,
      'repeatBase': repeatBase.value,
      'endDateExcluded': endDateExcluded,
    };
  }
}

class Custodies {
  static List<RecurrentCustody> reccurentCustodies = [];
  static List<DateTime> exceptionalCustodies = [];
  static List<DateTime> exceptionalNoCustodies = [];

  static bool _doesDayMatchRecurrentCustodyDefinition(
    DateTime date,
    RecurrentCustody reccurentCustody,
  ) {
    if (date.isBefore(reccurentCustody.startDate)) {
      return false;
    }

    if (reccurentCustody.endDateExcluded != null) {
      if (date.isAtSameMomentAs(reccurentCustody.endDateExcluded!) ||
          date.isAfter(reccurentCustody.endDateExcluded!)) {
        return false;
      }
    }

    var delta = date.difference(reccurentCustody.startDate);
    if (reccurentCustody.repeatBase == RepeatBase.day) {
      if (delta.inDays % reccurentCustody.repeatEvery == 0) {
        return true;
      }
    } else {
      final deltaWeeks = delta.inDays / 7;
      final deltaWeeksRemainder = delta.inDays % 7;
      if (deltaWeeksRemainder == 0 &&
          deltaWeeks % reccurentCustody.repeatEvery == 0) {
        return true;
      }
    }

    return false;
  }

  static CustodyStatus getCustodyStatusForDate(DateTime date) {
    if (exceptionalCustodies.contains(date)) {
      return .exceptionalCustody;
    }
    if (exceptionalNoCustodies.contains(date)) {
      return .exceptionalNoCustody;
    }

    for (var reccurentCustody in reccurentCustodies) {
      if (Custodies._doesDayMatchRecurrentCustodyDefinition(
        date,
        reccurentCustody,
      )) {
        return .recurrentCustody;
      } else {
        continue;
      }
    }

    return .noCustody;
  }

  static Iterable<RecurrentCustody> getMatchingReccurentCustodiesForDate(
    DateTime date,
  ) {
    return Custodies.reccurentCustodies.where(
      (reccurentCustody) => Custodies._doesDayMatchRecurrentCustodyDefinition(
        date,
        reccurentCustody,
      ),
    );
  }

  static bool isEmpty() {
    return Custodies.reccurentCustodies.isEmpty &&
        Custodies.exceptionalCustodies.isEmpty &&
        Custodies.exceptionalNoCustodies.isEmpty;
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
  bool? previousDeleteAllReccurence;

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
            Column(
              children: [
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
                                return Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        date.day.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              case .recurrentCustody:
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                    child: Center(
                                      child: Text(
                                        date.day.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              case .exceptionalNoCustody:
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: Center(
                                      child: Text(date.day.toString()),
                                    ),
                                  ),
                                );
                              default:
                                // Remove today outline that is misleading with "exceptional no custody"
                                if (isToday != null && isToday) {
                                  return Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: textStyle,
                                    ),
                                  );
                                }
                                return null;
                            }
                          },
                    ),
                    value: [],
                    onValueChanged: (dates) async {
                      switch (Custodies.getCustodyStatusForDate(dates[0])) {
                        case .noCustody:
                          final result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                AddCustodyDaysDialog(
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
                        case .recurrentCustody:
                          final result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                DeleteReccurentCustodyDayDialogState(
                                  dateToDelete: dates[0],
                                  previousDeleteAllReccurence:
                                      previousDeleteAllReccurence,
                                ),
                          );
                          final (
                            :doDelete as bool,
                            :deleteAllReccurence as bool?,
                            :dateToDelete as DateTime?,
                          ) = result;
                          if (doDelete) {
                            if (deleteAllReccurence!) {
                              for (var reccurentCustody
                                  in Custodies.getMatchingReccurentCustodiesForDate(
                                    dateToDelete!,
                                  )) {
                                reccurentCustody.endDateExcluded = dateToDelete;
                              }
                            } else {
                              Custodies.exceptionalNoCustodies.add(
                                dateToDelete!,
                              );
                            }
                            previousDeleteAllReccurence = deleteAllReccurence;
                            // Re-trigger the drawing
                            setState(() {});
                          }
                        case .exceptionalCustody:
                          final result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                DeleteExceptionalCustodyDayDialog(
                                  dateToDelete: dates[0],
                                ),
                          );
                          if (result is DateTime) {
                            Custodies.exceptionalCustodies.remove(result);
                            // Re-trigger the drawing
                            setState(() {});
                          }
                        case .exceptionalNoCustody:
                          final result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                DeleteExceptionalNoCustodyDayDialog(
                                  dateToDelete: dates[0],
                                ),
                          );
                          if (result is DateTime) {
                            Custodies.exceptionalNoCustodies.remove(result);
                            // Re-trigger the drawing
                            setState(() {});
                          }
                      }
                      if (Custodies.getCustodyStatusForDate(dates[0]) ==
                          .noCustody) {}
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: .end,
                  children: [
                    TextButton.icon(
                      label: const Text('Effacer'),
                      iconAlignment: .end,
                      onPressed: Custodies.isEmpty()
                          ? null
                          : () async {
                              final result = await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Tout supprimer'),
                                  content: const Text(
                                    'Etes-vous sûr de vouloir supprimer tous les jours de garde déjà configurés ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'cancel'),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'confirm'),
                                      child: const Text(
                                        'Supprimer',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (result == 'confirm') {
                                setState(() {
                                  Custodies.reccurentCustodies = [];
                                  Custodies.exceptionalCustodies = [];
                                  Custodies.exceptionalNoCustodies = [];
                                });
                              }
                            },
                      icon: const Icon(Icons.clear),
                      //label: const Text('Effacer'),
                      //iconAlignment: .end,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () => widget.onPreviousPressed(),
                  child: const Text('Précédent'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (Custodies.isEmpty()) {
                      final result = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Calendrier vide'),
                          content: const Text(
                            "Vous n'avez pas saisi de jours de garde, confirmer et continuer quand même ?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'cancel'),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, 'confirm'),
                              child: const Text('Confirmer'),
                            ),
                          ],
                        ),
                      );
                      if (result == 'confirm') {
                        saveCustodies(userDoc);
                        widget.onNextPressed();
                      }
                    } else {
                      saveCustodies(userDoc);
                      widget.onNextPressed();
                    }
                  },
                  child: const Text('Suivant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void saveCustodies(DocumentReference<Map<String, dynamic>> userDoc) {
    userDoc.set({
      'custodies': {
        'reccurentCustodies': Custodies.reccurentCustodies
            .map((r) => r.toSerializableMap())
            .toList(),
        'exceptionalCustodies': Custodies.exceptionalCustodies,
        'exceptionalNoCustodies': Custodies.exceptionalNoCustodies,
      },
    }, SetOptions(merge: true));
  }
}

class AddCustodyDaysDialog extends StatefulWidget {
  const AddCustodyDaysDialog({
    super.key,
    required this.startDate,
    required this.previousIsReccurent,
    required this.previousRepeatEvery,
    required this.previousRepeatBase,
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

class DeleteExceptionalCustodyDayDialog extends StatelessWidget {
  const DeleteExceptionalCustodyDayDialog({
    super.key,
    required this.dateToDelete,
  });

  final DateTime dateToDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supression de jour exceptionnel de garde'),
      content: Text(
        DateFormat.yMMMMEEEEd(
          Localizations.localeOf(context).languageCode,
        ).format(dateToDelete),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, dateToDelete),
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class DeleteReccurentCustodyDayDialogState extends StatefulWidget {
  const DeleteReccurentCustodyDayDialogState({
    super.key,
    required this.dateToDelete,
    required this.previousDeleteAllReccurence,
  });

  final DateTime dateToDelete;
  final bool? previousDeleteAllReccurence;

  @override
  State<DeleteReccurentCustodyDayDialogState> createState() =>
      _DeleteReccurentCustodyDayDialogStateState();
}

class _DeleteReccurentCustodyDayDialogStateState
    extends State<DeleteReccurentCustodyDayDialogState> {
  late bool deleteAllReccurence;

  @override
  void initState() {
    super.initState();

    deleteAllReccurence = widget.previousDeleteAllReccurence ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suppression de jours de garde'),
      content: Column(
        mainAxisSize: .min,
        children: [
          Text(
            DateFormat.yMMMMEEEEd(
              Localizations.localeOf(context).languageCode,
            ).format(widget.dateToDelete),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          RadioGroup<bool>(
            groupValue: deleteAllReccurence,
            onChanged: (bool? value) {
              setState(() {
                deleteAllReccurence = value!;
              });
            },
            child: const Column(
              children: <Widget>[
                RadioListTile(
                  title: Text('Supprimer ce jour ainsi que les suivants'),
                  value: true,
                ),
                RadioListTile(
                  title: Text('Supprimer uniquement ce jour'),
                  value: false,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, (
            doDelete: false,
            deleteAllReccurence: null,
            dateToDelete: null,
          )),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, (
            doDelete: true,
            deleteAllReccurence: deleteAllReccurence,
            dateToDelete: widget.dateToDelete,
          )),
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class DeleteExceptionalNoCustodyDayDialog extends StatelessWidget {
  const DeleteExceptionalNoCustodyDayDialog({
    super.key,
    required this.dateToDelete,
  });

  final DateTime dateToDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Supprimer cette exception et rétablir le jour de garde',
      ),
      content: Text(
        DateFormat.yMMMMEEEEd(
          Localizations.localeOf(context).languageCode,
        ).format(dateToDelete),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, dateToDelete),
          child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
