import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parents_in_love/position.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Home'),
        FutureBuilder(
          future: determinePosition(),
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.hasError) {
              final error = snapshot.error;
              return Text('Failed to retrieve position ! : $error');
            } else if (snapshot.hasData) {
              double? altitude = snapshot.data?.longitude;
              return altitude != null
                  ? Text(altitude.toString())
                  : Text('no altitude');
            } else {
              return Text('loading');
            }
          },
        ),
        ElevatedButton(
          onPressed: () => {FirebaseAuth.instance.signOut()},
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}
