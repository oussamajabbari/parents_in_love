import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/home.dart';
import 'package:parents_in_love/onboarding/ask_birth.dart';
import 'package:parents_in_love/onboarding/ask_name.dart';
import 'package:parents_in_love/onboarding/ask_sex.dart';
import 'package:parents_in_love/onboarding/intro.dart';
import 'package:parents_in_love/theme/app_constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _goToPrevioustPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance
        .collection('users_parameters')
        .doc(userUid);
    return StreamBuilder(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Auth stream error !');
        } else if (!snapshot.hasData) {
          return Text('Waiting for user doc');
        } else {
          final usersParameters = snapshot.data!.data();
          if (true) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMD,
                0,
                AppConstants.spacingMD,
                AppConstants.spacingMD,
              ),
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    //physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Intro(onNextPressed: _goToNextPage),
                      AskBirth(
                        onPreviousPressed: _goToPrevioustPage,
                        onNextPressed: _goToNextPage,
                      ),
                      AskName(
                        onPreviousPressed: _goToPrevioustPage,
                        onNextPressed: _goToNextPage,
                      ),
                      AskSex(
                        onPreviousPressed: _goToPrevioustPage,
                        onNextPressed: _goToNextPage,
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment(0, 0.9),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 4,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Home();
          }
        }
      },
    );
  }
}
