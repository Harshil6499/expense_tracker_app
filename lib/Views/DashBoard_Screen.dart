import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/ViewModels/Expense_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Income_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Account_ViewModel.dart';

import 'package:expense_tracker/Views/Access/LogIn_Screen.dart';
import 'package:expense_tracker/Views/Accounts/Accounts_Screen.dart';



import 'package:expense_tracker/Assets/App_Color.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return "Good Morning";
  } else if (hour < 17) {
    return "Good Afternoon";
  } else {
    return "Good Evening";
  }
}

class _DashboardScreenState extends State<DashboardScreen> {

  String userName = "";
  String userId = "";


  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {

    final prefs = await SharedPreferences.getInstance();

    String? storedUserId = prefs.getString("userId");
    String? storedUserName = prefs.getString("userName");


    setState(() {
      userId = storedUserId ?? "";
      userName = storedUserName ?? "";
    });

    if (userId.isNotEmpty) {
      // //Account API
      // Provider.of<AccountViewModel>(context, listen: false)
      //     .fetchAccountBalance(userId);

      //Expense API
      Provider.of<ExpenseViewModel>(context, listen: false)
          .fetchExpenses(userId);

      //Income API
      Provider.of<IncomeViewmodel>(context, listen: false)
          .fetchIncome(userId);
    }
  }

  @override
  Widget build(BuildContext context) {

    final accountVM = Provider.of<AccountViewModel>(context);

    final expenseVM = Provider.of<ExpenseViewModel>(context);
    double totalExpense = expenseVM.expenses.fold(
      0.0,
          (sum, item) => sum + item.amount,
    );

    final incomeVM = Provider.of<IncomeViewmodel>(context);
    double totalIncome = incomeVM.income.fold(
      0.0,
          (sum, item) => sum + double.parse(item.amount),
    );

    return Scaffold(
      backgroundColor: AppColors.BackGround,
      appBar: AppBar(
        backgroundColor:AppColors.Primary,
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 5),
            Text("Welcome back, $userName 👋"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // /// Balance
              // Center(
              //   child: accountVM.isLoading
              //       ? const CircularProgressIndicator()
              //       : Text(
              //     "Balance: ₹ ${accountVM.account?.balance ?? "0"}",
              //     style: TextStyle(
              //       fontSize: 20,
              //       fontWeight: FontWeight.bold,
              //       color: AppColors.Primary,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),
              //
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //
              //     /// Expense
              //     Expanded(
              //       child: expenseVM.isLoading
              //           ? const Center(child: CircularProgressIndicator())
              //           : Column(
              //         children: [
              //           const Text(
              //             "Expense",
              //             style: TextStyle(fontSize: 13),
              //           ),
              //           Text(
              //             "₹ $totalExpense",
              //             style: TextStyle(
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold,
              //               color: AppColors.Expense,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //
              //     /// Income
              //     Expanded(
              //       child: incomeVM.isLoading
              //           ? const Center(child: CircularProgressIndicator())
              //           : Column(
              //         children: [
              //           const Text(
              //             "Income",
              //             style: TextStyle(fontSize: 13),
              //           ),
              //           Text(
              //             "₹ $totalIncome",
              //             style: TextStyle(
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold,
              //               color: AppColors.Income,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 30),

              /// Logout Button
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
                child: const Text("Logout"),
              ),
              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: () async {

                  final prefs = await SharedPreferences.getInstance();
                  String? userId = prefs.getString("userId");

                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountsScreen(userId: userId),
                      ),
                    );
                  } else {
                    print("User ID not found");
                  }
                },
                child: Text("View Accounts"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
