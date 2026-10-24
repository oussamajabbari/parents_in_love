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

class AskGenderState extends State<AskGender>
    with AutomaticKeepAliveClientMixin<AskGender> {
  bool enableNextButton = false;
  UserProfile? currentUser;

  void _loadCurrentUser() async {
    final loadedCurrentUser = await UserProfile.getCurrent();
    setState(() {
      currentUser = loadedCurrentUser;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  bool get wantKeepAlive => true;

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
            Card(
              margin: const EdgeInsets.all(0),
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.spacingMD),
                  Text(
                    'Quel est votre sexe ?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  RadioGroup<Gender>(
                    groupValue: currentUser!.gender,
                    onChanged: (Gender? value) {
                      setState(() {
                        currentUser!.gender = value;
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
            Card(
              margin: const EdgeInsets.all(0),
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.spacingMD),
                  Text(
                    'Que recherchez-vous ?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  RadioGroup<Gender>(
                    groupValue: currentUser!.lookingForGender,
                    onChanged: (Gender? value) {
                      setState(() {
                        currentUser!.lookingForGender = value;
                      });
                    },
                    child: const Column(
                      children: <Widget>[
                        RadioListTile<Gender>(
                          title: Text('Une femme'),
                          value: Gender.woman,
                        ),
                        RadioListTile<Gender>(
                          title: Text('Un homme'),
                          value: Gender.man,
                        ),
                        RadioListTile<Gender>(
                          title: Text('Pas de préférence'),
                          value: Gender.whatever,
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
                  onPressed:
                      currentUser!.gender != null &&
                          currentUser!.lookingForGender != null
                      ? () async {
                          currentUser!.save();
                          widget.onNextPressed();
                        }
                      : null,
                  child: const Text('Suivant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
