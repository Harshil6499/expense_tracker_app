import 'dart:convert';
import 'package:expense_tracker/Core/Network/api_endpoints.dart';
import 'package:expense_tracker/Models/Expense_Model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class ExpenseViewModel extends ChangeNotifier{

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  Future<void> fetchExpenses(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Uri url = Uri.parse("${ApiConstants.View_Expenses}?role=user&user_id=$userId");

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] == "success") {

        List list = data["data"];
        _expenses = list.map((e) => ExpenseModel.fromJson(e)).toList();

        //print("Total items: ${_expenses.length}");

      } else {
        print("API Error: ${data["message"]}");
      }

    } catch (e) {
      print("Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}