import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parents_in_love/models/custodies.dart';

part 'user_profile.g.dart';

enum Gender {
  woman('woman'),
  man('man'),
  whatever('whatever');

  const Gender(this.value);
  final String value;
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class UserProfile {
  String? name;
  DateTime? birthDate;
  Gender? gender;
  Gender? lookingForGender;
  Custodies? custodies;

  UserProfile({
    this.name,
    this.birthDate,
    this.gender,
    this.lookingForGender,
    this.custodies,
  });

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

  static Future<UserProfile?> getCurrent() async {
    final userProfileSnapshot = await _getCurrentUserProfileDocRef().get();
    return userProfileSnapshot.data();
  }

  Future<void> save() => _getCurrentUserProfileDocRef().set(this);
}
