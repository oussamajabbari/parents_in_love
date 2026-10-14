import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/foundation.dart';
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

class AskBirthState extends State<AskBirth>
    with AutomaticKeepAliveClientMixin<AskBirth> {
  bool enableNextButton = false;
  DateTime? selectedDate;

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadBirthDate() async {
    final currentUser = await UserProfile.getCurrent();
    setState(() {
      selectedDate = currentUser!.birthDate;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBirthDate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            Text(selectedDate.toString()),
            Card(
              margin: const EdgeInsets.all(0),
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(),
                value: [selectedDate],
                onValueChanged: (dates) => {
                  setState(() {
                    selectedDate = dates[0];
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
            isMinor()
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
                  onPressed: isMinor()
                      ? null
                      : () async {
                          final userProfile = await UserProfile.getCurrent();
                          userProfile!.birthDate = selectedDate;
                          userProfile.save();
                          widget.onNextPressed();
                        },
                  child: const Text('Suivant'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool isMinor() {
    if (kDebugMode) {
      return selectedDate == null;
    } else {
      return selectedDate != null &&
          selectedDate!.isAfter(
            DateTime.now().subtract(const Duration(days: 18 * 365)),
          );
    }
  }
}
