import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/ViewModels/SignUp_ViewModel.dart';

import 'package:expense_tracker/Views/Access/LogIn_Screen.dart';

import 'package:expense_tracker/Assets/App_Color.dart';
import 'package:expense_tracker/Widgets/Custom_TextField.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final signupVM = context.watch<SignUpViewModel>();
    return Scaffold(
      backgroundColor: AppColors.BackGround,
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                /// Logo
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.Primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.BackGround,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ///Title & SubTitle
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.Title,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Smart Spending Starts Here',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.SubTitle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      //Name
                      CustomTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.account_circle_outlined,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Name is required";
                          }
                          if (value.length > 9) {
                            return "Name must be only under 9 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      //Surname
                      CustomTextField(
                        controller: _surnameController,
                        label: 'surname',
                        icon: Icons.account_circle_outlined,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Surname is required";
                          }
                          if (value.length > 12) {
                            return "Name must be only under 15 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      //Phone Number
                      CustomTextField(
                        controller: _phonenumberController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        prefixText: "+91 ",
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return "Please enter your phone number";
                          }

                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                            return "Enter a valid 10-digit Indian mobile number";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      //Email
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return "Email is required";
                          }
                          final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      CustomTextField(
                        controller: _confirmpasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm Password is required";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      //Date of Birth
                      CustomTextField(
                        controller: _dobController,
                        label: 'Date of Birth',
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: () async {
                          // Remove keyboard focus
                          FocusScope.of(context).unfocus();

                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              _dobController.text =
                              "${pickedDate.year}-${pickedDate.month
                                  .toString()
                                  .padLeft(2, '0')}-${pickedDate.day
                                  .toString()
                                  .padLeft(2, '0')}";
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select your Date of Birth";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Error Message from API
                if (signupVM.errorMessage != null &&
                    signupVM.errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        signupVM.errorMessage!,
                        style: TextStyle(color: AppColors.Message),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                /// Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Button,
                      foregroundColor: AppColors.BackGround,
                    ),
                    onPressed: signupVM.isLoading
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      bool success = await signupVM.signUp(
                        name: _nameController.text.trim(),
                        surname: _surnameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: "+91${_phonenumberController.text.trim()}",
                        password: _passwordController.text.trim(),
                        confirm_password: _confirmpasswordController.text
                            .trim(),
                        dob: _dobController.text.trim(),
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registration Successful"),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: signupVM.isLoading
                        ? CircularProgressIndicator(
                      color: AppColors.BackGround,
                    )
                        : const Text("Register"),
                  ),
                ),

                const SizedBox(height: 24),

              ],
            ),
          )
      ),
    );
  }
}