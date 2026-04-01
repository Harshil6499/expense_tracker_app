import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/ViewModels/LogIn_ViewModel.dart';
import 'package:expense_tracker/Views/Access/SignUp_Screen.dart';
import 'package:expense_tracker/Views/DashBoard_Screen.dart';
import 'package:expense_tracker/assets/AppColors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = context.watch<LoginViewModel>();

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
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.BackGround,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// Title
              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.Title,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Login to manage your expenses',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.SubTitle,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              /// Form
              Form(
                key: _formKey,
                child: Column(
                  children: [

                    //Email
                    _inputField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    //Password
                    _inputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 4) {
                          return "Password must be at least 4 characters";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Error Message
              if (loginVM.errorMessage != null &&
                  loginVM.errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      loginVM.errorMessage!,
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
                  onPressed: loginVM.isLoading
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) return;

                    bool success = await loginVM.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );

                    if (success && mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  DashboardScreen(),
                        ),
                      );
                    }
                  },
                  child: loginVM.isLoading
                      ?  CircularProgressIndicator(
                    color: AppColors.BackGround,
                  )
                      : Text("Login"),
                ),
              ),

              const SizedBox(height: 30),

              /// Register Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.Primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Footer
              Center(
                child: Text(
                  'Secure & Private',
                  style: TextStyle(
                    color: AppColors.SubTitle,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable Input Field
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
