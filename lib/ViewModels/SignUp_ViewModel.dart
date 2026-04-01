import 'dart:convert';
import 'package:expense_tracker/Core/Network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SignUpViewModel extends ChangeNotifier {

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> signUp({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required String password,
    required String confirm_password,
    required String dob,
  }) async {

    _isLoading = true;
    notifyListeners();

    try {

      final response = await http.post(
        Uri.parse(ApiConstants.Sign_Up),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "surname": surname,
          "email": email,
          "phone": phone,
          "password": password,
          "confirm_password": confirm_password,
          "DOB": dob,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["status"] == "success") {

        _successMessage = data["message"];

        _isLoading = false;
        notifyListeners();
        return true;

      } else {
        _errorMessage = data["message"];
      }

    } catch (e) {
      _errorMessage = "Server Error: $e";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}