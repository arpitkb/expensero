import 'package:expensero/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../services/database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  AddExpenseScreen({this.expense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  Account? _selectedAccount;
  List<Category> _categories = [];
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    print('add expense screen');
  }

  Future<void> _loadData() async {
    await Future.wait([_loadAccounts(), _loadCategories()]);
    if (widget.expense != null) {
      _initializeFields();
    }
    setState(() {});
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DatabaseHelper.instance.getCategories();
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
      // print('Categories loaded');
    } catch (e) {
      print('Error loading categories: $e');
      _showErrorSnackBar('Failed to load categories. Please try again.');
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await DatabaseHelper.instance.getAccounts();
      setState(() {
        _accounts = accounts;
        if (_accounts.isNotEmpty) {
          _selectedAccount = _accounts.first;
        }
      });
      // print('Accounts loaded');
    } catch (e) {
      print('Error loading accounts: $e');
      _showErrorSnackBar('Failed to load Accounts. Please try again.');
    }
  }

  void _initializeFields() async {
    try {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      // Safely find the category and account

      // print( 'The selected category id is ${widget.expense!.accountId} and the existing is ${_accounts}');

      _selectedCategory =
          _categories.firstWhere((c) => c.id == widget.expense!.categoryId);

      _selectedAccount =
          _accounts.firstWhere((a) => a.id == widget.expense!.accountId);

      // If we couldn't find a matching category or account, log a warning
      if (_selectedCategory == null) {
        _showErrorSnackBar('Warning: Could not find this category}');
      }
      if (_selectedAccount == null) {
        _showErrorSnackBar('Warning: Could not find this Account}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('Failed to open the expense, Please try again!');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              decoration: InputDecoration(labelText: 'Category'),
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
              decoration: InputDecoration(labelText: 'Account'),
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
              trailing: Icon(Icons.calendar_today),
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
              child: Text(
                  widget.expense == null ? 'Save Expense' : 'Update Expense'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final expense = Expense(
                    id: widget.expense?.id,
                    description: _descriptionController.text,
                    amount: double.parse(_amountController.text),
                    categoryId: _selectedCategory!.id!,
                    accountId: _selectedAccount!.id!,
                    date: _selectedDate,
                  );
                  if (widget.expense == null) {
                    print('Inserting expense');
                    await DatabaseHelper.instance.insertExpense(expense);
                    showSnackBar(
                        context, 'Expense Added', SnackBarStatus.create,
                        seconds: 3);
                  } else {
                    print(
                        'Updating expense with expense = ${expense.toMap().toString()}');
                    await DatabaseHelper.instance.updateExpense(expense);
                  }
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
