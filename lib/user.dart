import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String? name;
  final DateTime? birthDate;

  User({this.name, this.birthDate});

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) => _$UserFromJson(snapshot.data()!);

  Map<String, dynamic> toFirestore() => _$UserToJson(this);

  static DocumentReference<User> _getCurrentUserDocRef() => FirebaseFirestore
      .instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .withConverter(
        fromFirestore: User.fromFirestore,
        toFirestore: (User userProfile, _) => userProfile.toFirestore(),
      );

  static Stream<DocumentSnapshot<User>> snapshots() =>
      _getCurrentUserDocRef().snapshots();

  static Future<User?> get() async {
    final userSnapshot = await _getCurrentUserDocRef().get();
    return userSnapshot.data();
  }

  Future<void> save() => _getCurrentUserDocRef().set(this);
}
