import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parents_in_love/home.dart';
import 'package:parents_in_love/models/user_profile.dart';

Future<LocationPermission> checkAndRequestLocationPermission() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return permission;
}

Future<void> determinePositionAndSave() async {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100,
  );

  final lastKnownPosition = await Geolocator.getLastKnownPosition();
  late final Position position;

  if (lastKnownPosition != null) {
    position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    ).timeout(const Duration(seconds: 2), onTimeout: () => lastKnownPosition);
  } else {
    position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  UserProfile userProfile = await UserProfile.getCurrentOrCreate();
  userProfile.lastKnownPosition = GeoPoint(
    position.latitude,
    position.longitude,
  );
  await userProfile.save();
}

class LocationGate extends StatefulWidget {
  const LocationGate({super.key});

  @override
  State<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends State<LocationGate> {
  Future<LocationPermission> _checkAndRequestLocationPermission =
      checkAndRequestLocationPermission();
  bool isLocationSettingsCheckTimerRunning = false;

  void openAppSettingsAndCheck() async {
    if (!isLocationSettingsCheckTimerRunning) {
      isLocationSettingsCheckTimerRunning = true;
      // Start timer to periodically check permission
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == .always || permission == .whileInUse) {
          timer.cancel();
          setState(() {
            isLocationSettingsCheckTimerRunning = false;
            _checkAndRequestLocationPermission =
                checkAndRequestLocationPermission();
          });
        }
      });
    }
    await Geolocator.openAppSettings();
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

        return FutureBuilder<void>(
          future: determinePositionAndSave(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return const Home();
          },
        );
      },
    );
  }
}
