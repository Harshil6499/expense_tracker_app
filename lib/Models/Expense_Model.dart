class ExpenseModel{

  final String? expenseId;
  final String? accountId;
  final String? userId;
  final String? userName;
  final String? accountName;

  final String category;
  final double amount;
  final String note;
  final String expenseDate;
  //final String role;

  ExpenseModel({

    this.expenseId,
    this.accountId,
    this.userId,
    this.userName,
    this.accountName,

    required this.category,
    required this.amount,
    required this.note,
    required this.expenseDate,
    //required this.role,
  });

  ///Convert Json to Object GET
  factory ExpenseModel.fromJson(Map<String, dynamic> json){
    return ExpenseModel(
      expenseId: json['expense_id']?? '',
      accountId: json['account_id']?? '',
      userId: json['user_id']?? '',
      category: json['category']?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      note: json['note']?? '',
      expenseDate: json['expense_date']?? '',
      userName: json['user_name']?? '',
      accountName: json['account_name']?? '',
    );
  }

  ///Convert Data to Json
  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'account_id': accountId,
      'user_id': userId,
      'category': category,
      'amount': amount.toString(),
      'note': note,
      'expense_date': expenseDate,
      'user_name': userName,
      'account_name': accountName,
    };
  }
}
