import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parents_in_love/auth_gate.dart';
import 'package:parents_in_love/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kReleaseMode) {
    const String devMachineIP = '192.168.1.97';
    //const String devMachineIP = 'localhost';
    //const String devMachineIP = '10.92.10.211';

    await FirebaseAuth.instance.useAuthEmulator(devMachineIP, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(devMachineIP, 8080);
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: kReleaseMode ? null : const Locale('fr'),
      title: 'Parents in Love app',
      theme: AppTheme.lightTheme, // Light mode theme
      themeMode: ThemeMode.light, // Follows system setting
      home: const AuthGate(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FirebaseUILocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('fr'),
        const Locale('es'),
      ],
    );
  }
}
