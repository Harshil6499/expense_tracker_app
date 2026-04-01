import 'dart:convert';
import 'package:expense_tracker/Core/Network/Api_Endpoints.dart';
import 'package:expense_tracker/Models/Account_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AccountViewModel extends ChangeNotifier {

  bool _isLoading = false;
  AccountModel? _account;

  bool get isLoading => _isLoading;
  AccountModel? get account => _account;

  Future<void> fetchAccountBalance(String userId) async {

    _isLoading = true;
    notifyListeners();

    try {
      final Uri url = Uri.parse("${ApiConstants.View_Accounts}?role=user&user_id=$userId");

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        _account = AccountModel.fromJson(data["data"][0]);


      }
    } catch (e) {
      print("Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}