import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parents_in_love/home.dart';

Future<LocationPermission> checkAndRequestLocationPermission() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return permission;
}

class LocationGate extends StatefulWidget {
  const LocationGate({super.key});

  @override
  State<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends State<LocationGate> {
  Future<LocationPermission> _checkAndRequestLocationPermission =
      checkAndRequestLocationPermission();
  bool isTimerRunning = false;

  void openAppSettingsAndCheck() {
    if (!isTimerRunning) {
      isTimerRunning = true;
      // Start timer to periodically check permission
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == .always || permission == .whileInUse) {
          timer.cancel();
          setState(() {
            isTimerRunning = false;
            _checkAndRequestLocationPermission =
                checkAndRequestLocationPermission();
          });
        }
      });
    }

    Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationPermission>(
      future: _checkAndRequestLocationPermission,
      builder: (BuildContext context, AsyncSnapshot<LocationPermission> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final LocationPermission locationPermission = snapshot.data!;
        switch (locationPermission) {
          case .denied:
            return Column(
              children: [
                const Text(
                  "Veuillez svp donner la permission d'accéder à la localisation",
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _checkAndRequestLocationPermission =
                        checkAndRequestLocationPermission();
                  }),
                  child: const Text('Activer'),
                ),
              ],
            );
          case .deniedForever:
            return Column(
              children: [
                const Text(
                  "Permission refusée :(. Veuillez réauthoriser la localisation dans les paramètres.",
                ),
                ElevatedButton(
                  onPressed: openAppSettingsAndCheck,
                  child: const Text('Paramètres'),
                ),
              ],
            );
          default:
        }

        return const Home();
      },
    );
  }
}
