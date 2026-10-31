
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/Models/Income_Model.dart';
import 'package:expense_tracker/Models/Expense_Model.dart';

import 'package:expense_tracker/ViewModels/Expense_ViewModel.dart';
import 'package:expense_tracker/ViewModels/Income_ViewModel.dart';


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

  // Colors
  static const Color backgroundColor = Color(0xFFF7F8FC);
  static const Color primaryText = Color(0xFF202633);
  static const Color secondaryText = Color(0xFF777F8E);
  static const Color incomeColor = Color(0xFF16A36A);
  static const Color expenseColor = Color(0xFFE65353);
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

      final dateA = DateTime.tryParse(a.date) ??
          DateTime(1970);

      final dateB = DateTime.tryParse(b.date) ??
          DateTime(1970);

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

  // Add Income or Expense Dialog
  Future<void> _showTransactionDialog({
    required bool isIncome,
  }) async {

    final amountController = TextEditingController();
    final noteController = TextEditingController();

    final input = await showDialog<TransactionInput>(
      context: context,
      builder: (dialogContext) {

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            isIncome ? "Add Income" : "Add Expense",
            style: const TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixText: "₹ ",
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: "Note",
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome
                    ? incomeColor
                    : expenseColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {

                final amount = amountController.text.trim();
                final note = noteController.text.trim();

                if (amount.isEmpty ||
                    (double.tryParse(amount) ?? 0) <= 0) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid amount"),
                    ),
                  );

                  return;
                }

                Navigator.pop(
                  dialogContext,
                  TransactionInput(
                    amount: amount,
                    note: note,
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    amountController.dispose();
    noteController.dispose();

    if (input == null || !mounted) return;

    bool success = false;

    if (isIncome) {

      final incomeVM = Provider.of<IncomeViewmodel>(
        context,
        listen: false,
      );

      success = await incomeVM.addIncome(
        input.amount,
        "General",
        input.note,
        widget.accountId,
      );

    } else {

      final expenseVM = Provider.of<ExpenseViewModel>(
        context,
        listen: false,
      );

      success = await expenseVM.addExpense(
        input.amount,
        "General",
        input.note,
        widget.accountId,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "${isIncome ? 'Income' : 'Expense'} added successfully"
              : "Failed to add ${isIncome ? 'income' : 'expense'}",
        ),
        backgroundColor: success ? incomeColor : expenseColor,
      ),
    );
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

    // Combined transactions
    final transactions = _getRecentTransactions(
      accountIncome,
      accountExpenses,
    );

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          widget.accountName,
          style: const TextStyle(
            color: primaryText,
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
                color: secondaryText,
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
              _buildAccountCard(),

              const SizedBox(height: 25),

              // Financial Overview
              const Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
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
                      color: incomeColor,
                      lightColor: const Color(0xFFE9F8F0),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Expense',
                      amount: '₹${_formatAmount(totalExpense)}',
                      icon: Icons.trending_down_rounded,
                      color: expenseColor,
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
                      color: primaryText,
                    ),
                  ),

                  Text(
                    '${transactions.length} transactions',
                    style: const TextStyle(
                      fontSize: 12,
                      color: secondaryText,
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
                          color: secondaryText,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "No transactions found",
                          style: TextStyle(
                            color: secondaryText,
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

                  Expanded(
                    child: _buildActionButton(
                      title: 'Add Income',
                      icon: Icons.add_circle_outline,
                      color: incomeColor,
                      onPressed: () {
                        _showTransactionDialog(
                          isIncome: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildActionButton(
                      title: 'Add Expense',
                      icon: Icons.remove_circle_outline,
                      color: expenseColor,
                      onPressed: () {
                        _showTransactionDialog(
                          isIncome: false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Account Information Card
  Widget _buildAccountCard() {

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
                        color: primaryText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.accountType,
                      style: const TextStyle(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.verified_outlined,
                color: incomeColor,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            'Available Balance',
            style: TextStyle(
              color: secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '₹ ${widget.balance}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: primaryText,
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
                  color: secondaryText,
                  fontSize: 13,
                ),
              ),

              Text(
                widget.accountId,
                style: const TextStyle(
                  color: primaryText,
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
              color: secondaryText,
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
        ? incomeColor
        : expenseColor;

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
                        color: primaryText,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${transaction.category} · ${_formatDate(transaction.date)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: secondaryText,
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

  // Add Income and Expense Buttons
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {

    return SizedBox(
      height: 52,

      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: Icon(
          icon,
          size: 19,
        ),

        label: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// Combined Transaction Model for UI
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

// Dialog Input Model
class TransactionInput {

  final String amount;
  final String note;

  TransactionInput({
    required this.amount,
    required this.note,
  });
}
