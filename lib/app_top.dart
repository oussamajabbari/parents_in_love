import 'package:flutter/material.dart';
import 'package:parents_in_love/auth_gate.dart';

class AppTop extends StatelessWidget {
  const AppTop({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
            ),
            AuthGate(),
          ],
        ),
      ),
    );
  }
}
