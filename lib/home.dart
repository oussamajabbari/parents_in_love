import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/models/user_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<UserProfile> _currentUser = UserProfile.getCurrentOrCreate();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Home'),
        FutureBuilder<UserProfile>(
          future: _currentUser,
          builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final UserProfile userProfile = snapshot.data!;
            return Text(userProfile.toFirestore().toString());
          },
        ),
        ElevatedButton(
          onPressed: () => {FirebaseAuth.instance.signOut()},
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}
