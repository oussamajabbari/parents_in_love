import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parents_in_love/home.dart';
import 'package:parents_in_love/models/user_profile.dart';
import 'package:parents_in_love/onboarding/ask_birth.dart';
import 'package:parents_in_love/onboarding/ask_child_custody.dart';
import 'package:parents_in_love/onboarding/ask_name.dart';
import 'package:parents_in_love/onboarding/ask_gender.dart';
import 'package:parents_in_love/onboarding/intro.dart';
import 'package:parents_in_love/onboarding/upload_profile_pictures.dart';
import 'package:parents_in_love/theme/app_constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  final PageController _pageController = PageController();
  final Stream<DocumentSnapshot<UserProfile>> _currentUserStream =
      UserProfile.snapshots();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _goToPrevioustPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> onboardingPages = [
      Intro(onNextPressed: _goToNextPage),
      AskName(
        onPreviousPressed: _goToPrevioustPage,
        onNextPressed: _goToNextPage,
      ),
      AskGender(
        onPreviousPressed: _goToPrevioustPage,
        onNextPressed: _goToNextPage,
      ),
      AskBirth(
        onPreviousPressed: _goToPrevioustPage,
        onNextPressed: _goToNextPage,
      ),
      AskChildCustody(
        onPreviousPressed: _goToPrevioustPage,
        onNextPressed: _goToNextPage,
      ),
      UploadProfilePictures(
        onPreviousPressed: _goToPrevioustPage,
        onNextPressed: _goToNextPage,
      ),
      //const AcceptCookies(),
    ];

    return StreamBuilder<DocumentSnapshot<UserProfile>>(
      stream: _currentUserStream,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<UserProfile>> snapshot,
          ) {
            if (snapshot.hasError) {
              return const Text('Auth stream error !');
            } else if (!snapshot.hasData) {
              return const Text('Waiting for user doc');
            }

            final UserProfile currentUser =
                snapshot.data!.data() ?? UserProfile();

            currentUser.onboardingDone = currentUser.onboardingDone ?? false;

            if (!currentUser.onboardingDone!) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingSM,
                  0,
                  AppConstants.spacingSM,
                  AppConstants.spacingMD,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: onboardingPages,
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: onboardingPages.length,
                    ),
                  ],
                ),
              );
            } else {
              return const Home();
            }
          },
    );
  }
}
