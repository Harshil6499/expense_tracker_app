import 'dart:convert';
import 'package:expense_tracker/Core/Network/Api_Endpoints.dart';
import 'package:expense_tracker/Models/Account_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AccountViewModel extends ChangeNotifier {

  bool _isLoading = false;
  List<AccountModel> _accounts = [];

  bool get isLoading => _isLoading;
  List<AccountModel> get accounts => _accounts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAccounts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Uri url = Uri.parse("${ApiConstants.View_Accounts}?role=user&user_id=$userId");

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      //print(data);

      if (data["status"] == "success") {
        List list = data["data"];
        _accounts = list.map((e) => AccountModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<bool> addAccount({

    required String userId,
    required String accountName,
    required String accountType,
    required String balance,


  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(Uri.parse(ApiConstants.Add_Account),

        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "account_name": accountName,
          "account_type": accountType,
          "balance": balance,
        }),
      );
      final data = jsonDecode(response.body);



      if (response.statusCode == 200 && data["status"] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data["message"] ?? "Something went wrong";
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}