import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parents_in_love/position.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<Position> _determinePosition = determinePosition();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Home'),
        // FutureBuilder(
        //   future: _determinePosition,
        //   builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        //     if (snapshot.hasError) {
        //       final error = snapshot.error;
        //       return Text('Failed to retrieve position ! : $error');
        //     } else if (snapshot.hasData) {
        //       double? altitude = snapshot.data?.longitude;
        //       return altitude != null
        //           ? Text(altitude.toString())
        //           : const Text('no altitude');
        //     } else {
        //       return const Text('loading');
        //     }
        //   },
        // ),
        ElevatedButton(
          onPressed: () => {FirebaseAuth.instance.signOut()},
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}
