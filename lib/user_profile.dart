import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

DocumentReference<UserProfile>? currentUserProfile() {
  if (FirebaseAuth.instance.currentUser == null) {
    return null;
  }

  return FirebaseFirestore.instance
      .collection('users_profiles')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .withConverter(
        fromFirestore: UserProfile.fromFirestore,
        toFirestore: (UserProfile userProfile, _) => userProfile.toFirestore(),
      );
}

class UserProfile {
  final String? name;
  final DateTime? birthDate;

  UserProfile({this.name, this.birthDate});

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserProfile(
      name: data?['name'],
      birthDate: (data?['birthDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (birthDate != null) 'birthDate': birthDate,
    };
  }
}
