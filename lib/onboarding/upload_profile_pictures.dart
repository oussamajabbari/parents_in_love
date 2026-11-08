import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parents_in_love/models/user_profile.dart';
import 'package:parents_in_love/theme/app_constants.dart';
import 'package:uuid/uuid.dart';

class UploadProfilePictures extends StatefulWidget {
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  const UploadProfilePictures({
    super.key,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  State<UploadProfilePictures> createState() => _UploadProfilePicturesState();
}

class _UploadProfilePicturesState extends State<UploadProfilePictures> {
  final ImagePicker _picker = ImagePicker();
  final Stream<DocumentSnapshot<UserProfile>> _currentUserStream =
      UserProfile.snapshots();

  @override
  Widget build(BuildContext context) {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final storageRef = FirebaseStorage.instance.ref();

    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLG),
        child: StreamBuilder<DocumentSnapshot<UserProfile>>(
          stream: _currentUserStream,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<DocumentSnapshot<UserProfile>> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final UserProfile currentUser =
                    snapshot.data!.data() ?? UserProfile();

                currentUser.profilePicturePaths =
                    currentUser.profilePicturePaths ?? [];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: AppConstants.spacingLG),
                    Text(
                      'Ajoutez une ou des photos de profil',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.spacingLG),
                    Expanded(
                      child: Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            crossAxisCount: 3,
                            children:
                                List.from(
                                  currentUser.profilePicturePaths!.map((
                                    picturePath,
                                  ) {
                                    return Image(
                                      image: FirebaseImageProvider(
                                        FirebaseUrl.fromReference(
                                          FirebaseStorage.instance.ref(
                                            picturePath,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                )..add(
                                  IconButton.outlined(
                                    onPressed:
                                        currentUser
                                                .profilePicturePaths!
                                                .length >=
                                            5
                                        ? null
                                        : () async {
                                            final XFile? pickedFile =
                                                await _picker.pickImage(
                                                  source: .gallery,
                                                );

                                            if (pickedFile != null) {
                                              final fileNameUuid = const Uuid()
                                                  .v4();
                                              final String picturePath =
                                                  "$userUid/profilePictures/$fileNameUuid)";

                                              await storageRef
                                                  .child(picturePath)
                                                  .putFile(
                                                    File(pickedFile.path),
                                                  );

                                              currentUser.profilePicturePaths!
                                                  .add(picturePath);
                                              currentUser.save();
                                            }
                                          },
                                    icon: const Icon(Icons.add),
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                          Row(
                            mainAxisAlignment: .end,
                            children: [
                              TextButton.icon(
                                label: const Text('Effacer'),
                                iconAlignment: .end,
                                onPressed:
                                    currentUser.profilePicturePaths!.isEmpty
                                    ? null
                                    : () async {
                                        final result = await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: const Text(
                                                  'Tout supprimer',
                                                ),
                                                content: const Text(
                                                  'Etes-vous sûr de vouloir supprimer les photos ?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          'cancel',
                                                        ),
                                                    child: const Text(
                                                      'Annuler',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          'confirm',
                                                        ),
                                                    child: const Text(
                                                      'Supprimer',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (result == 'confirm') {
                                          setState(() {
                                            for (var profilePicturePath
                                                in currentUser
                                                    .profilePicturePaths!) {
                                              storageRef
                                                  .child(profilePicturePath)
                                                  .delete();
                                            }
                                            currentUser.profilePicturePaths =
                                                [];
                                            currentUser.save();
                                            FirebaseCacheManager().clearCache();
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
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () => widget.onPreviousPressed(),
                          child: const Text('Précédent'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: currentUser.profilePicturePaths!.isEmpty
                              ? null
                              : () {
                                  // This is the last step, mark onboarding as done
                                  currentUser.onboardingDone = true;
                                  currentUser.save();

                                  widget.onNextPressed();
                                },
                          child: const Text('Suivant'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLG),
                  ],
                );
              },
        ),
      ),
    );
  }
}
