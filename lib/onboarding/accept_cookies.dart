import 'package:flutter/material.dart';

class AcceptCookies extends StatelessWidget {
  const AcceptCookies({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'ACCEPTE LES COOKIES, ou jte mets une patate dans le menton',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
