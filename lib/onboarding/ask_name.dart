import 'package:flutter/material.dart';
import 'package:parents_in_love/theme/app_constants.dart';
import 'package:parents_in_love/models/user_profile.dart';

class AskName extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const AskName({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  AskNameState createState() {
    return AskNameState();
  }
}

class AskNameState extends State<AskName>
    with AutomaticKeepAliveClientMixin<AskName> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool enableNextButton = false;
  UserProfile? currentUser;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

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
    // setState(() async {
    //   currentUser = await UserProfile.getCurrent();
    //   nameController.text = currentUser!.name ?? '';
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLG,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Quel est votre prénom ?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre prénom';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    enableNextButton =
                        _formKey.currentState != null &&
                        _formKey.currentState!.validate();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      widget.onPreviousPressed();
                    },
                    child: const Text('Précédent'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: enableNextButton
                        ? () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            var name = nameController.text.trim();
                            currentUser!.name = name;
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
      ),
    );
  }
}
