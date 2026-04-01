import 'package:expense_tracker/ViewModels/Account_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Expense_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Income_ViewModel.dart';
import 'package:expense_tracker/ViewModels/SignUp_ViewModel.dart';
import 'package:expense_tracker/Views/DashBoard_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/ViewModels/LogIn_ViewModel.dart';
import 'package:expense_tracker/Views/Access/LogIn_Screen.dart';
import 'Views/OnBording Screen/OnBording_Screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _startScreen;

  @override
  void initState() {
    super.initState();
    _decideStartScreen();
  }

  Future<void> _decideStartScreen() async {
    final prefs = await SharedPreferences.getInstance();

    bool onboardingDone = prefs.getBool('onboarding_done') ?? false;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!onboardingDone) {
      _startScreen = const OnBordingScreen();
    } else if (isLoggedIn) {
      _startScreen = const DashboardScreen();
    } else {
      _startScreen = const LoginScreen();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_startScreen == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => SignUpViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => IncomeViewmodel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _startScreen,
      ),
    );
  }
}
