import 'package:expense_tracker/Views/Access/Login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/assets/AppColors.dart';


class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BackGround,
      body: Stack(
        children: [

          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            children: [
              buildPage(
                lottie: "lib/assets/lottie/SplashScreen.json",
                title: "Track Expenses",
                subtitle: "Easily track your daily expenses",
              ),
              buildPage(
                icon: Icons.pie_chart_outline,
                title: "Manage Budget",
                subtitle: "Plan monthly & yearly budgets",
              ),
              buildPage(
                icon: Icons.savings_outlined,
                title: "Save Money",
                subtitle: "Analyze spending and save smarter",
              ),
            ],
          ),

          if (currentIndex != 2)
            Positioned(
              top: 40,
              right: 20,
              child: TextButton(
                onPressed: () => navigateToLogin(context),
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: AppColors.Primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.Button,
                ),
                onPressed: () {
                  if (currentIndex == 2) {
                    navigateToLogin(context);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  currentIndex == 2 ? "Get Started" : "Next",
                  style: TextStyle(
                    color: AppColors.BackGround,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    String? lottie,
    IconData? icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottie != null)
            Lottie.asset(lottie, height: 220)
          else if (icon != null)
            Icon(icon, size: 120, color: AppColors.Primary),
          const SizedBox(height: 40),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 26, color: AppColors.Title, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: AppColors.SubTitle)),
        ],
      ),
    );
  }

  Future<void> saveOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
  }

  void navigateToLogin(BuildContext context) async {
    await saveOnboardingDone();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
