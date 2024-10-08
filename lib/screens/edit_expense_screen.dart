import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../services/database_helper.dart';
import 'dart:developer' as developer;

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  // ignore: library_private_types_in_public_api
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  Category? _selectedCategory;
  Account? _selectedAccount;
  List<Category> _categories = [];
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _selectedDate = widget.expense.date;
    _loadCategories();
    _loadAccounts();
    developer.log('edit expense screen');
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
      _selectedCategory =
          categories.firstWhere((c) => c.id == widget.expense.categoryId);
    });
  }

  Future<void> _loadAccounts() async {
    final accounts = await DatabaseHelper.instance.getAccounts();
    setState(() {
      _accounts = accounts;
      _selectedAccount =
          accounts.firstWhere((a) => a.id == widget.expense.accountId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            DropdownButtonFormField<Account>(
              value: _selectedAccount,
              decoration: const InputDecoration(labelText: 'Account'),
              items: _accounts.map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an account';
                }
                return null;
              },
            ),
            ListTile(
              title: Text('Date: ${_selectedDate.toString().substring(0, 10)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            ElevatedButton(
              child: const Text('Update Expense'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedExpense = Expense(
                    id: widget.expense.id,
                    description: _descriptionController.text,
                    amount: double.parse(_amountController.text),
                    categoryId: _selectedCategory!.id!,
                    accountId: _selectedAccount!.id!,
                    date: _selectedDate,
                  );
                  await DatabaseHelper.instance.updateExpense(updatedExpense);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
