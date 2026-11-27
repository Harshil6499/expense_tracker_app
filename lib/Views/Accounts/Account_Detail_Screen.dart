import 'dart:ffi';

import 'package:expense_tracker/Assets/App_Color.dart';
import 'package:expense_tracker/Models/Income_Model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/Models/Expense_Model.dart';

import 'package:expense_tracker/ViewModels/Expense_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Income_ViewModel.dart';

import 'package:expense_tracker/Widgets/Glass_Dialog.dart';
import 'package:expense_tracker/Views/Dialogs/Add_Transaction_Dialog.dart';



class AccountDetailsScreen extends StatefulWidget {
  final String accountId;
  final String accountName;
  final String accountType;
  final String balance;


  const AccountDetailsScreen({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.balance,
  });

  @override
  State<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {


  static const Color borderColor = Color(0xFFECEEF2);

  bool _isInitialLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadData();
    });
  }

  // Fetch Income and Expenses
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isInitialLoading = true;
      _loadError = null;
    });

    try {
      final incomeVM = Provider.of<IncomeViewmodel>(
        context,
        listen: false,
      );

      final expenseVM = Provider.of<ExpenseViewModel>(
        context,
        listen: false,
      );

      final userId = await incomeVM.getUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception("User not logged in");
      }

      await Future.wait([
        incomeVM.fetchIncome(userId),
        expenseVM.fetchExpenses(userId),
      ]);

    } catch (e) {
      _loadError = "Failed to load account transactions";
      debugPrint("Account Detail Error: $e");

    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  // Calculate Total Income
  double _calculateTotalIncome(List<IncomeModel> incomeList) {

    return incomeList
        .where((item) => item.accountId == widget.accountId)
        .fold(
      0.0,
          (sum, item) =>
      sum + (double.tryParse(item.amount.toString()) ?? 0.0),
    );
  }

  // Calculate Total Expense
  double _calculateTotalExpense(List<ExpenseModel> expenseList) {

    return expenseList
        .where((item) => item.accountId == widget.accountId)
        .fold(
      0.0,
          (sum, item) => sum + item.amount,
    );
  }

  // Combine Income and Expense Transactions
  List<AccountTransaction> _getRecentTransactions(
      List<IncomeModel> incomeList,
      List<ExpenseModel> expenseList,
      ) {

    List<AccountTransaction> transactions = [];

    // Add Income Transactions
    for (var item in incomeList) {

      if (item.accountId == widget.accountId) {

        transactions.add(
          AccountTransaction(
            title: item.note.isNotEmpty
                ? item.note
                : item.category,
            category: item.category,
            amount: double.tryParse(item.amount.toString()) ?? 0.0,
            date: item.incomeDate,
            isIncome: true,
          ),
        );
      }
    }

    // Add Expense Transactions
    for (var item in expenseList) {

      if (item.accountId == widget.accountId) {

        transactions.add(
          AccountTransaction(
            title: item.note.isNotEmpty
                ? item.note
                : item.category,
            category: item.category,
            amount: item.amount,
            date: item.expenseDate,
            isIncome: false,
          ),
        );
      }
    }

    // Sort Newest Transactions First
    transactions.sort((a, b) {
      final dateA = DateTime.tryParse(a.date) ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.date) ?? DateTime(1970);

      return dateB.compareTo(dateA);
    });

    return transactions;
  }

  // Format Amount
  String _formatAmount(double amount) {
    return amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  // Format Date
  String _formatDate(String date) {

    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) return date;

    return "${parsedDate.day.toString().padLeft(2, '0')}/"
        "${parsedDate.month.toString().padLeft(2, '0')}/"
        "${parsedDate.year}";
  }

  @override
  Widget build(BuildContext context) {

    final incomeVM = context.watch<IncomeViewmodel>();
    final expenseVM = context.watch<ExpenseViewModel>();

    // Filter data for selected account
    final accountIncome = incomeVM.income
        .where((item) => item.accountId == widget.accountId)
        .toList();

    final accountExpenses = expenseVM.expenses
        .where((item) => item.accountId == widget.accountId)
        .toList();


    // Calculate totals
    final totalIncome = _calculateTotalIncome(accountIncome);
    final totalExpense = _calculateTotalExpense(accountExpenses);

    // Calculate Available Balance
    final openingBalance = double.tryParse(widget.balance) ?? 0.0;

    final availableBalance =
        openingBalance + totalIncome - totalExpense;

    // Combined transactions
    final transactions = _getRecentTransactions(
      accountIncome,
      accountExpenses,
    );

    return Scaffold(
      backgroundColor: AppColors.BackGround,

      appBar: AppBar(
        backgroundColor: AppColors.BackGround,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          widget.accountName,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,
      ),

      body: _isInitialLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _loadError != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _loadError!,
              style: const TextStyle(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20, 10, 20, 25,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Account Information Card
              _buildAccountCard(
                availableBalance: availableBalance,
              ),

              const SizedBox(height: 25),

              // Financial Overview
              const Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Income',
                      amount: '₹${_formatAmount(totalIncome)}',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.Income,
                      lightColor: const Color(0xFFE9F8F0),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Expense',
                      amount: '₹${_formatAmount(totalExpense)}',
                      icon: Icons.trending_down_rounded,
                      color: AppColors.Income,
                      lightColor: const Color(0xFFFFF0F0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Recent Transactions Heading
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),

                  Text(
                    '${transactions.length} transactions',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Transaction List
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.025),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: transactions.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 35,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: AppColors.secondaryText,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "No transactions found",
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Column(
                  children: transactions
                      .map(
                        (transaction) =>
                        _buildTransactionItem(
                          transaction,
                        ),
                  )
                      .toList(),
                ),
              ),

              const SizedBox(height: 28),

              // Add Income and Expense Buttons
              Row(
                children: [

                  /// Income Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.Income,
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
                                  widget.accountId,
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
                        backgroundColor: AppColors.Expense,
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
                                  widget.accountId,
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
      ),
    );
  }

  // Account Information Card
  Widget _buildAccountCard({
    required double availableBalance,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1F8),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.account_balance_outlined,
                  color: Color(0xFF5969B0),
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      widget.accountName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color:AppColors.primaryText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.accountType,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.verified_outlined,
                color: AppColors.Income,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 25),
          const Text(
            'Available Balance',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '₹ ${_formatAmount(availableBalance)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 20),

          const Divider(
            color: borderColor,
            height: 1,
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              const Text(
                'Account ID',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),

              Text(
                widget.accountId,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Income and Expense Summary Card
  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {

    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const SizedBox(height: 13),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,

            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recent Transaction Item
  Widget _buildTransactionItem(
      AccountTransaction transaction,
      ) {

    final bool isIncome = transaction.isIncome;

    final Color color = isIncome
        ? AppColors.Income : AppColors.Income;

    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),

          child: Row(
            children: [

              Container(
                height: 43,
                width: 43,

                decoration: BoxDecoration(
                  color: isIncome
                      ? const Color(0xFFE9F8F0)
                      : const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(
                  isIncome
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: color,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${transaction.category} · ${_formatDate(transaction.date)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              Text(
                '${isIncome ? '+' : '-'} ₹${_formatAmount(transaction.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),

        const Divider(
          color: borderColor,
          height: 1,
        ),
      ],
    );
  }
}


//Combined Transaction Model for UI
class AccountTransaction {

  final String title;
  final String category;
  final double amount;
  final String date;
  final bool isIncome;

  AccountTransaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

