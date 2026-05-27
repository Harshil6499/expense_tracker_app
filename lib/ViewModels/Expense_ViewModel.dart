import 'dart:convert';
import 'package:expense_tracker/Core/Network/Api_Endpoints.dart';
import 'package:expense_tracker/Models/Expense_Model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseViewModel extends ChangeNotifier {

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");

  }

  Future<String?> getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accountId");
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// View Expense
  Future<void> fetchExpenses(String userId) async {
    _isLoading = true;
    notifyListeners();
    _setLoading(true);
    try {
      final Uri url = Uri.parse("${ApiConstants.View_Expenses}?role=user&user_id=$userId");

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        _expenses = (data["data"] as List)
            .map((e) => ExpenseModel.fromJson(e))
            .toList();
      } else {
        _setError(data["message"]);
      }
    } catch (e) {
      print("Error: $e");
    }
    _isLoading = false;
    notifyListeners();
    _setLoading(false);
  }

  Future<bool> addExpense(
      String amount,
      String category,
      String note,
      String accountId,
      ) async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = await getUserId();
      final accountId = await getAccountId();


      if (userId == null || userId.isEmpty) {
        _setError("User not logged in");
        return false;
      }

      String formattedDate =
      DateTime.now().toIso8601String().split("T")[0];

      ///API Call
      final response = await http.post(Uri.parse(ApiConstants.Add_Expense),

        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "account_id": accountId,
          "amount": amount,
          "category": category,
          "note": note,
          "expense_date": formattedDate,
        }),
      );

      /// Debug
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      /// Success
      if (response.statusCode == 200 && data["status"] == "success") {
        await fetchExpenses(userId);
        return true;
      } else {
        _setError(data["message"] ?? "Failed to Add Expense");
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