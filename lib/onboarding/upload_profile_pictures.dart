import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parents_in_love/theme/app_constants.dart';

class UploadProfilePictures extends StatefulWidget {
  const UploadProfilePictures({super.key});

  @override
  State<UploadProfilePictures> createState() => _UploadProfilePicturesState();
}

class _UploadProfilePicturesState extends State<UploadProfilePictures> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> pickedFiles = [];

  @override
  Widget build(BuildContext context) {
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
              setState(() {
                if (pickedFile != null) {
                  pickedFiles.add(pickedFile);
                }
              });
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
            Text(
              'Ajoutez une ou des photos de profil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: GridView.count(
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                crossAxisCount: 3,
                children: gridItems,
              ),
            ),
            Row(
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Ajouter')),
                OutlinedButton(
                  onPressed: () => setState(() {
                    pickedFiles = [];
                  }),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
