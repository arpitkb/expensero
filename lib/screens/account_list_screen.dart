import 'package:expensero/widgets/account_list_item.dart';
import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/database_helper.dart';
import '../utils/snack_bar.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _refreshAccounts();
  }

  Future<void> _refreshAccounts() async {
    final accounts = await DatabaseHelper.instance.getAccounts();
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accounts')),
      body: ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return AccountListItem(
            account: account,
            onDelete: () => _showDeleteAccountDialog(account),
            onEdit: () => _showAddorUpdateAccountDialog(account),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddorUpdateAccountDialog(null);
        },
      ),
    );
  }

  Future<void> _showAddorUpdateAccountDialog(acc) async {
    final textController = TextEditingController();
    if (acc != null) textController.text = acc.name;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: acc == null
              ? const Text('Add Account')
              : const Text('Update Account'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Account name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: acc == null ? const Text('Add') : const Text('Update'),
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  try {
                    final account = acc == null
                        ? Account(name: textController.text)
                        : Account(id: acc.id, name: textController.text);
                    if (acc == null) {
                      await DatabaseHelper.instance.insertAccount(account);
                      _refreshAccounts();
                      showSnackBar(context, 'Account created successfully!',
                          SnackBarStatus.create,
                          seconds: 2);
                    } else {
                      await DatabaseHelper.instance.updateAccount(account);
                      _refreshAccounts();
                      showSnackBar(context, 'Account updated successfully!',
                          SnackBarStatus.update,
                          seconds: 2);
                    }
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    showSnackBar(context, e.toString(), SnackBarStatus.error,
                        seconds: 2);
                  }

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(Account account) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to Delete?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await DatabaseHelper.instance.deleteAccount(account.id!);
                  _refreshAccounts();
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, 'Deleted Account Successfully',
                      SnackBarStatus.deleted,
                      seconds: 2);
                } catch (e) {
                  // print('Error: $e');
                  showSnackBar(
                      // ignore: use_build_context_synchronously
                      context,
                      'Failed to delete the Account, Please try again',
                      SnackBarStatus.error,
                      seconds: 2);
                }

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
