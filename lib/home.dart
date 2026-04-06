import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Home'),
          ElevatedButton(
            onPressed: () => {FirebaseAuth.instance.signOut()},
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
