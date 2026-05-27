import 'package:expense_tracker/ViewModels/Expense_ViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String accountId; // ✅ receive from previous screen

  const AddExpenseScreen({
    super.key,
    required this.accountId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedCategory = "Food";

  final List<String> categories = [
    "Food",
    "Travel",
    "Shopping",
    "Bills",
  ];

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  /// ✅ Submit Function
  void _submitExpense() async {
    final expenseVM = Provider.of<ExpenseViewModel>(context, listen: false);

    final amountText = amountController.text.trim();
    final note = noteController.text.trim();

    /// 🔍 Validation
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter amount")),
      );
      return;
    }

    if (double.tryParse(amountText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid numeric amount")),
      );
      return;
    }

    /// 🚀 Call API with dynamic accountId
    final success = await expenseVM.addExpense(
      amountText,
      selectedCategory,
      note,
      widget.accountId, // ✅ FIXED
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense Added Successfully")),
      );

      amountController.clear();
      noteController.clear();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            expenseVM.errorMessage ?? "Failed to add expense",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 💰 Amount
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 15),

            /// 📂 Category
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),

            const SizedBox(height: 15),

            /// 📝 Note
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Note",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),

            const SizedBox(height: 25),

            /// 🚀 Button / Loader
            Consumer<ExpenseViewModel>(
              builder: (context, vm, child) {
                return vm.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitExpense,
                    child: const Text(
                      "Add Expense",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}