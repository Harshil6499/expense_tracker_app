import 'package:flutter/material.dart';

class AccountDetailsScreen extends StatelessWidget {
  final String accountId;
  final String accountName;
  final String accountType;
  final String balance;

  const AccountDetailsScreen({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(accountName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Account ID: $accountId",
                style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            Text("Account Type: $accountType",
                style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            Text("Balance: ₹$balance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}