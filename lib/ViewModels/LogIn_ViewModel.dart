import 'dart:convert';
import 'package:expense_tracker/Core/Network/Api_Endpoints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.post(Uri.parse(ApiConstants.Sign_In),

        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["status"] == "success") {

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);


        ///Save Data for a DashBoard Screen (Name & User_ID)
        await prefs.setString("userName", data["data"]["name"]);
        await prefs.setString("userId", data["data"]["user_id"]);

        _setLoading(false);
        return true;
      } else {
        _setError(data["message"] ?? "Login Failed");
      }
    } catch (e) {
      _setError("Server Error. Please try again.");
    }
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
