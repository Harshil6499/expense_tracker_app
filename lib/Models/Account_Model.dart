class AccountModel{

  final String accountId;
  final String userId;
  final String accountName;
  final String accountType;
  final String balance;

  AccountModel({

    required this.accountId,
    required this.userId,
    required this.accountName,
    required this.accountType,
    required this.balance,
  });

  ///Convert Json to Data
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json['account_id'],
      userId: json['user_id'],
      accountName: json['account_name'],
      accountType: json['account_type'],
      balance: json['balance'],
    );
  }
}