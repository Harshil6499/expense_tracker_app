import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/Core/Network/Api_Endpoints.dart';

import 'package:expense_tracker/Models/Income_Model.dart';


class IncomeViewmodel extends ChangeNotifier {

  /// Get User ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<IncomeModel> _income = [];
  List<IncomeModel> get income => _income;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  ///View Income
  Future<void> fetchIncome(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Uri url = Uri.parse(
          "${ApiConstants.View_Income}?role=user&user_id=$userId");

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        List list = data["data"];
        _income = list.map((e) => IncomeModel.fromJson(e)).toList();

        //print("Total items: ${_income.length}");

      } else {
        print("API Error: ${data["message"]}");
      }
    } catch (e) {
      print("Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  ///Add Income
  Future<bool> addIncome(
      String amount,
      String category,
      String note,
      String accountId,)
  async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        _setError("User not logged in");
        return false;
      }
      String formattedDate = DateTime.now().toIso8601String().split("T")[0];

      final response = await http.post(
        Uri.parse(ApiConstants.Add_Income),
        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({
          "user_id": userId,
          "account_id": accountId,
          "amount": amount,
          "category": category,
          "note": note,
          "income_date": formattedDate,

        }),
      );

      // Debug
      print("===============");
      print("STATUS CODE : ${response.statusCode}");
      print("RAW RESPONSE : ${response.body}");
      print("===============");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("Income Added");
        await fetchIncome(userId);
        return true;
      } else {
        print("Income Failed");
        _setError(data["message"]);
        return false;
      }
    } catch (e) {
      print("Error: $e");
      _setError("Server Error. Please try again.");
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

