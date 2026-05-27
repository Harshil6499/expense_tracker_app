// import 'package:expense_tracker/Assets/App_Color.dart';
// import 'package:expense_tracker/ViewModels/Account_ViewModel.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AddAccountScreen extends StatefulWidget {
//   const AddAccountScreen({super.key});
//
//   @override
//   State<AddAccountScreen> createState() => _AddAccountScreenState();
// }
//
// class _AddAccountScreenState extends State<AddAccountScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _accountNameController =
//   TextEditingController();
//
//   String _selectedType = "bank"; // default value
//
//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.watch<AccountViewModel>();
//
//     return Scaffold(
//       backgroundColor: AppColors.BackGround,
//       appBar: AppBar(
//         title: const Text("Add Account"),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               /// FORM
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     /// Account Name
//                     TextFormField(
//                       controller: _accountNameController,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return "Account name required";
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         labelText: "Account Name",
//                         prefixIcon:
//                         const Icon(Icons.account_circle_outlined),
//                         filled: true,
//                         fillColor: AppColors.BackGround,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     /// Account Type Dropdown
//                     DropdownButtonFormField<String>(
//                       value: _selectedType,
//                       decoration: InputDecoration(
//                         labelText: "Account Type",
//                         prefixIcon:
//                         const Icon(Icons.category_outlined),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       items: ["bank", "cash", "wallet"]
//                           .map((type) => DropdownMenuItem(
//                         value: type,
//                         child: Text(type.toUpperCase()),
//                       ))
//                           .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedType = value!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// Error Message
//               if (viewModel.errorMessage != null &&
//                   viewModel.errorMessage!.isNotEmpty)
//                 Text(
//                   viewModel.errorMessage!,
//                   style: TextStyle(color: AppColors.Message),
//                 ),
//
//               const SizedBox(height: 20),
//
//               /// Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.Button,
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: viewModel.isLoading
//                       ? null
//                       : () async {
//                     if (!_formKey.currentState!.validate()) return;
//
//                     final prefs =
//                     await SharedPreferences.getInstance();
//                     String userId =
//                         prefs.getString("userId") ?? "";
//
//                     bool success =
//                     await viewModel.addAccount(
//                       userId: userId,
//                       accountName:
//                       _accountNameController.text.trim(),
//                       accountType: _selectedType,
//                     );
//
//                     if (success) {
//                       await viewModel.fetchAccounts(userId);
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Account Created"),
//                         ),
//                       );
//
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: viewModel.isLoading
//                       ? CircularProgressIndicator(
//                     color: AppColors.BackGround,
//                   )
//                       : const Text("Create Account"),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }