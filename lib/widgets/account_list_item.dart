import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountListItem extends StatelessWidget {
  final Account account;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AccountListItem({
    super.key,
    required this.account,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: const BoxDecoration(
            border: BorderDirectional(
                bottom: BorderSide(color: Colors.black, width: .5))),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          title: Text(
            account.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          onTap: onEdit,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
