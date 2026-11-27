
import 'package:flutter/material.dart';

import 'package:expense_tracker/Widgets/Custom_TextField.dart';
import 'package:expense_tracker/Widgets/Glass_Dialog.dart';

class AddTransactionDialog extends StatefulWidget {
  final String title;
  final Function(String amount, String note) onSubmit;

  const AddTransactionDialog({
    super.key,
    required this.title,
    required this.onSubmit,
  });

  @override
  State<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState
    extends State<AddTransactionDialog> {

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Amount
          CustomTextField(
            controller: amountController,
            label: "Amount",
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 15),

          // Note
          CustomTextField(
            controller: noteController,
            label: "Note",
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: () {
                  widget.onSubmit(
                    amountController.text,
                    noteController.text,
                  );

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
