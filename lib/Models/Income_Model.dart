
class IncomeModel{
  final String incomeId;
  final String accountId;
  final String userId;
  final String category;
  final String amount;
  final String note;
  final String incomeDate;
  final String accountName;

  IncomeModel({

    required this.incomeId,
    required this.accountId,
    required this.userId,
    required this.category,
    required this.amount,
    required this.note,
    required this.incomeDate,
    required this.accountName,
  });

  factory IncomeModel.fromJson(Map<String, dynamic>json){
    return IncomeModel(
      incomeId: json['income_id'] ?? '',
      accountId: json['account_id'] ?? '',
      userId: json['user_id'] ?? '',
      category: json['category'] ?? '',
      amount: json['amount'] ?? '',
      note: json['note'] ?? '',
      incomeDate: json['income_date'] ?? '',
      accountName: json['account_name'] ?? '',
    );
  }
}