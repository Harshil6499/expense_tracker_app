import 'package:expense_tracker/Assets/App_Color.dart';
import 'package:expense_tracker/ViewModels/Account_ViewModel.dart';
import 'package:expense_tracker/Views/Accounts/Account_Detail_Screen.dart';
import 'package:expense_tracker/Views/add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';


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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddExpenseScreen(
                                        accountId: account.accountId,
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddExpenseScreen(
                                        accountId: account.accountId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Add Expens"),
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


 /// Add Account Dialog Box (Funcation)
class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        const Text(
          "Add Account",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 15),

        /// Account Name
        _inputField(
          controller: nameController,
          label: 'Account Name',
        ),

        const SizedBox(height: 10),

        /// Balance
        _inputField(
          controller: balanceController,
          label: 'Initial Balance',
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 10),

        ///Dropdown
        DropdownButtonFormField<String>(
          value: selectedType,
          hint: const Text("Select Account Type", style: TextStyle(color: Colors.white70),),

          style: const TextStyle(color: Colors.black),

          iconEnabledColor: Colors.white,
          dropdownColor: Colors.white,

          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),

          items: const [
            DropdownMenuItem(
              value: "bank",
              child: Text("Bank", style: TextStyle(color: Colors.black)),
            ),
            DropdownMenuItem(
              value: "cash",
              child: Text("Cash", style: TextStyle(color: Colors.black)),
             ),
             DropdownMenuItem(
               value: "wallet",
               child: Text("Wallet", style: TextStyle(color: Colors.black)),
              ),
             ],

             onChanged: (value) {
              setState(() {
                selectedType = value;
            });
         },
        ),

        const SizedBox(height: 20),

        /// Button
        ElevatedButton(
          onPressed: () async {

            final prefs = await SharedPreferences.getInstance();

            String userId = prefs.getString("userId") ?? "";

            final viewModel =
            Provider.of<AccountViewModel>(context, listen: false);

            await viewModel.addAccount(
              userId: userId,
              accountName: nameController.text,
              balance: balanceController.text,
              accountType: selectedType ?? "",
            );

            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }

  /// Input Field
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}