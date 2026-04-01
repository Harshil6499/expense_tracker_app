import 'dart:convert';
import 'package:expense_tracker/Core/Network/Api_Endpoints.dart';
import 'package:expense_tracker/Models/Income_Model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class IncomeViewmodel extends ChangeNotifier{

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<IncomeModel> _income = [];
  List<IncomeModel> get income => _income;

  Future<void> fetchIncome(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Uri url = Uri.parse("${ApiConstants.View_Income}?role=user&user_id=$userId");

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
}