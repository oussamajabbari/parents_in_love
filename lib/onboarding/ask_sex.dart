import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class AskSex extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskSex({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskSexState createState() {
    return AskSexState();
  }
}

enum Sex {
  woman('woman'),
  man('man');

  const Sex(this.value);
  final String value;
}

class AskSexState extends State<AskSex>
    with AutomaticKeepAliveClientMixin<AskSex> {
  bool enableNextButton = false;
  Sex? _sex;
  Sex? _lookinfForSex;

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
            Card(
              child: Column(
                children: [
                  Text(
                    'Quel est votre sexe ?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  RadioGroup<Sex>(
                    groupValue: _sex,
                    onChanged: (Sex? value) {
                      setState(() {
                        _sex = value;
                      });
                    },
                    child: const Column(
                      children: <Widget>[
                        RadioListTile<Sex>(
                          title: Text('Femme'),
                          value: Sex.woman,
                        ),
                        RadioListTile<Sex>(
                          title: Text('Homme'),
                          value: Sex.man,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  Text(
                    'Que recherchez-vous ?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  RadioGroup<Sex>(
                    groupValue: _lookinfForSex,
                    onChanged: (Sex? value) {
                      setState(() {
                        _lookinfForSex = value;
                      });
                    },
                    child: const Column(
                      children: <Widget>[
                        RadioListTile<Sex>(
                          title: Text('Femme'),
                          value: Sex.woman,
                        ),
                        RadioListTile<Sex>(
                          title: Text('Homme'),
                          value: Sex.man,
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
                  child: Text('Précédent'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sex != null && _lookinfForSex != null
                      ? () {
                          userDoc.set({
                            'sex': _sex!.value,
                          }, SetOptions(merge: true));
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
