import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  List<XFile> pickedFiles = [];
  List<String> profilePicturesPaths = [];

  @override
  Widget build(BuildContext context) {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance
        .collection('users_parameters')
        .doc(userUid);
    final storageRef = FirebaseStorage.instance.ref();

    final List<Widget> gridItems =
        List.from(
          pickedFiles.map(
            (f) => ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: Image.file(File(f.path), fit: BoxFit.cover),
            ),
          ),
        )..add(
          IconButton.outlined(
            onPressed: () async {
              final XFile? pickedFile = await _picker.pickImage(
                source: .gallery,
              );

              if (pickedFile != null) {
                final fileNameUuid = const Uuid().v4();
                final String filePath =
                    "$userUid/profilePictures/$fileNameUuid)";

                profilePicturesPaths.add(filePath);

                storageRef.child(filePath).putFile(File(pickedFile.path));
                userDoc.set({
                  'profilePictures': profilePicturesPaths,
                }, SetOptions(merge: true));

                setState(() {
                  pickedFiles.add(pickedFile);
                });
              }
            },
            icon: const Icon(Icons.add),
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        );
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLG),
        child: Column(
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
                    children: gridItems,
                  ),
                  Row(
                    mainAxisAlignment: .end,
                    children: [
                      TextButton.icon(
                        label: const Text('Effacer'),
                        iconAlignment: .end,
                        onPressed: pickedFiles.isEmpty
                            ? null
                            : () async {
                                final result = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: const Text('Tout supprimer'),
                                    content: const Text(
                                      'Etes-vous sûr de vouloir supprimer les photos ?',
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
                                    pickedFiles = [];
                                    for (var profilePicturesPath
                                        in profilePicturesPaths) {
                                      storageRef
                                          .child(profilePicturesPath)
                                          .delete();
                                    }
                                    profilePicturesPaths = [];

                                    userDoc.set({
                                      'profilePictures': [],
                                    }, SetOptions(merge: true));
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
                  onPressed: pickedFiles.isEmpty
                      ? null
                      : () => widget.onNextPressed(),
                  child: const Text('Suivant'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLG),
          ],
        ),
      ),
    );
  }
}
