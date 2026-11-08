import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parents_in_love/models/custodies.dart';

part 'user_profile.g.dart';

enum Gender {
  woman('woman'),
  man('man');

  const Gender(this.value);
  final String value;
}

@JsonSerializable(explicitToJson: true)
class UserProfile {
  String? name;
  DateTime? birthDate;
  Gender? gender;
  Custodies? custodies;
  List<String>? profilePicturePaths;
  bool? onboardingDone;

  UserProfile({
    this.name,
    this.birthDate,
    this.gender,
    this.custodies,
    this.profilePicturePaths,
    this.onboardingDone,
  });

  bool isMinor() {
    return birthDate != null &&
        birthDate!.isAfter(
          DateTime.now().subtract(const Duration(days: 18 * 365)),
        );
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) => _$UserProfileFromJson(snapshot.data()!);

  Map<String, dynamic> toFirestore() => _$UserProfileToJson(this);

  static DocumentReference<UserProfile> _getCurrentUserProfileDocRef() =>
      FirebaseFirestore.instance
          .collection('users_profiles')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .withConverter(
            fromFirestore: UserProfile.fromFirestore,
            toFirestore: (UserProfile userProfile, _) =>
                userProfile.toFirestore(),
          );

  static Stream<DocumentSnapshot<UserProfile>> snapshots() =>
      _getCurrentUserProfileDocRef().snapshots();

  static Future<UserProfile> getCurrentOrCreate() async {
    final userProfileSnapshot = await _getCurrentUserProfileDocRef().get();
    final userProfile = userProfileSnapshot.data();
    return userProfile ?? UserProfile();
  }

  Future<void> save() => _getCurrentUserProfileDocRef().set(this);
}
