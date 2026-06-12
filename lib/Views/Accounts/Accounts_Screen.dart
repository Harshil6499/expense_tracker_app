import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/ViewModels/Account_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Expense_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Income_ViewModel.dart';

import 'package:expense_tracker/Views/Accounts/Account_Detail_Screen.dart';

import 'package:expense_tracker/Views/Dialogs/Add_Account_Dialog.dart';
import 'package:expense_tracker/Views/Dialogs/Add_Transaction_Dialog.dart';

import 'package:expense_tracker/Assets/App_Color.dart';
import 'package:expense_tracker/Widgets/Glass_Dialog.dart';


class AccountsScreen extends StatefulWidget {
  final String userId;

  const AccountsScreen({super.key, required this.userId});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AccountViewModel>(context, listen: false)
          .fetchAccounts(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          "My Accounts",
          style: TextStyle(
            //fontSize: 23,
            fontWeight: FontWeight.bold,
            color: AppColors.Title,
          ),
        ),
      ),
      backgroundColor: AppColors.BackGround,
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.accounts.isEmpty
            ? const Center(child: Text("No Accounts Found"))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              /// Accounts List
              Column(
                children: viewModel.accounts.map((account) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountDetailsScreen(
                            accountId: account.accountId,
                            accountName: account.accountName,
                            accountType: account.accountType,
                            balance: account.balance,
                          ),
                        ),
                      );
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.BackGround,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Account Name
                          Text(
                            account.accountName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.Title,
                            ),
                          ),
                          const SizedBox(height: 8),

                          /// Account Type
                          Row(
                            children: [
                              Icon(Icons.category_outlined,
                                  size: 18,
                                  color: AppColors.SubTitle),
                              const SizedBox(width: 6),
                              Text(
                                account.accountType,
                                style: TextStyle(
                                  color: AppColors.SubTitle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          /// Balance
                          Row(
                            children: [
                              Icon(Icons.currency_rupee,
                                  size: 18,
                                  color: AppColors.Primary),
                              const SizedBox(width: 6),
                              Text(
                                account.balance,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.Primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          /// Add Expense & Add Income Buttons
                          Row(
                            children: [

                              /// Income Button
                              Expanded(
                                child: ElevatedButton(

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.AddIncome,
                                    foregroundColor: AppColors.BackGround,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),

                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(0.3),
                                      builder: (_) => GlassDialog(
                                        child: AddTransactionDialog(
                                          title: "Add Income",
                                          onSubmit: (amount, note) async {
                                            final incomeVM = Provider.of<IncomeViewmodel>(
                                              context,
                                              listen: false,
                                            );
                                            await incomeVM.addIncome(
                                              amount,
                                              "General",
                                              note,
                                              account.accountId.toString(),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("Add Income"),
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// Expense Button
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.AddExpense,
                                    foregroundColor: AppColors.BackGround,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withValues(alpha: 0.3),
                                      builder: (_) => GlassDialog(
                                          child: AddTransactionDialog(
                                          title: "Add Expense",
                                          onSubmit: (amount, note) async {
                                            final expenseVM = Provider.of<ExpenseViewModel>(
                                              context,
                                              listen: false,
                                            );

                                            await expenseVM.addExpense(
                                              amount,
                                              "General",
                                              note,
                                              account.accountId.toString(),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("Add Expense"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.50),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.3),
            builder: (context) {
              return Center(
                child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: AddAccountDialog(),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
