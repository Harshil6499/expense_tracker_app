import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/ViewModels/Account_ViewModel.dart';

import 'package:expense_tracker/Widgets/Custom_TextField.dart';

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
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

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
        CustomTextField(
          controller: nameController,
          label: "Account Name",
        ),

        const SizedBox(height: 10),

        /// Balance
        CustomTextField(
          controller: balanceController,
          label: "Initial Balance",
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 10),

        /// Dropdown
        DropdownButtonFormField<String>(
          value: selectedType,
          hint: const Text(
            "Select Account Type",
            style: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white70),
          iconEnabledColor: Colors.white,
          dropdownColor: Colors.black,
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
              child: Text(
                "Bank",
                style: TextStyle(color: Colors.white),
              ),
            ),
            DropdownMenuItem(
              value: "cash",
              child: Text(
                "Cash",
                style: TextStyle(color: Colors.white),
              ),
            ),
            DropdownMenuItem(
              value: "wallet",
              child: Text(
                "Wallet",
                style: TextStyle(color: Colors.white),
              ),
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
}