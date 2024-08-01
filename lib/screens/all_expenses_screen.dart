import 'package:expensero/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/expense.dart';
import '../utils/date.dart';
import '../models/category.dart';
import '../models/account.dart';
import 'add_expense_screen.dart';
import 'home_screen.dart';

enum SortBy { amount, date }

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AllExpensesScreenState createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  List<Expense> expenses = [];

  List<Expense> filteredExpenses = [];
  List<Category> categories = [];
  List<Account> accounts = [];

  Map<int, String> accountNames = {};
  Map<int, String> categoryNames = {};

  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  String? _selectedCustomDateRange;

  DateTime? startDate;
  DateTime? endDate;
  Category? selectedCategory;
  Account? selectedAccount;
  SortBy? _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  Future<void> _refreshExpenses() async {
    final data = await DatabaseHelper.instance.getExpenses();

    final categoriesData = await DatabaseHelper.instance.getCategories();
    final accountsData = await DatabaseHelper.instance.getAccounts();

    // Create a map of account IDs to account names
    final accountNamesMap = {
      for (var account in accountsData) account.id!: account.name
    };
    // Create a map of category IDs to account names
    final categoryNamesMap = {
      for (var category in categoriesData) category.id!: category.name
    };

    setState(() {
      expenses = data;
      filteredExpenses = data;
      categories = categoriesData;
      accounts = accountsData;
      accountNames = accountNamesMap;
      categoryNames = categoryNamesMap;
      _selectedCustomDateRange = 'This Month';
    });
  }

  void _applyFilters2() {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        bool dateFilter = true;
        bool categoryFilter = true;
        bool accountFilter = true;
        final startOfDay =
            DateTime(_startDate.year, _startDate.month, _startDate.day);
        final endOfDay = DateTime(_endDate.year, _endDate.month, _endDate.day)
            .add(const Duration(days: 1))
            .subtract(const Duration(microseconds: 1));

        dateFilter = expense.date.isAtSameMomentAs(startOfDay) ||
            expense.date.isAtSameMomentAs(endOfDay) ||
            (expense.date.isAfter(startOfDay) &&
                expense.date.isBefore(endOfDay));

        if (selectedCategory != null) {
          categoryFilter = expense.categoryId == selectedCategory!.id;
        }

        if (selectedAccount != null) {
          accountFilter = expense.accountId == selectedAccount!.id;
        }

        return dateFilter && categoryFilter && accountFilter;
      }).toList();

      if (_selectedSortBy == SortBy.amount) {
        filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
      } else {
        filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  void _setPresetDateRange(String preset) {
    final now = DateTime.now();
    setState(() {
      switch (preset) {
        case 'Today':
          _startDate = now;
          _endDate = now;
          break;
        case 'This Week':
          _startDate = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1)); // Monday
          _endDate = now;
          break;
        case 'This Month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'This Year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
      }
      _applyFilters2();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _applyFilters2();
      });
    }
  }

  Widget _buildDateRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () => _selectDateRange(context),
            child: Text(
                '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}'),
          ),
          SizedBox(
            width: 125,
            height: 40, // or any specific width that fits your layout
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300)),
                child: DropdownButton<String>(
                  value: _selectedCustomDateRange,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  isExpanded: true,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  items: ['Today', 'This Week', 'This Month', 'This Year']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCustomDateRange = newValue;
                        _setPresetDateRange(newValue);
                      });
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildDateRangeSelector(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = filteredExpenses[index];
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    child: ListTile(
                      title: Text(expense.description),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '${categoryNames[expense.categoryId]} - ${accountNames[expense.accountId]}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('${expense.amount}'),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.currency_rupee,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  '- ${DateUtil.formatDateShortWithDayName(expense.date)}')
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteExpenseDialog(expense);
                        },
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddExpenseScreen(expense: expense)),
                        );
                        _refreshExpenses();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExpenseScreen()),
                );
                _refreshExpenses();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 6.0,
      children: [
        if (selectedCategory != null)
          Chip(
            label: Text(selectedCategory!.name),
            onDeleted: () {
              setState(() {
                selectedCategory = null;
              });
              _applyFilters2();
            },
          ),
        if (selectedAccount != null)
          Chip(
            label: Text(selectedAccount!.name),
            onDeleted: () {
              setState(() {
                selectedAccount = null;
              });
              _applyFilters2();
            },
          ),
      ],
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Filter Expenses'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    DropdownButton<Category>(
                      hint: const Text('Select Category'),
                      value: selectedCategory,
                      onChanged: (Category? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<Category>>((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ),
                    DropdownButton<Account>(
                      hint: const Text('Select Account'),
                      value: selectedAccount,
                      onChanged: (Account? newValue) {
                        setState(() {
                          selectedAccount = newValue;
                        });
                      },
                      items: accounts
                          .map<DropdownMenuItem<Account>>((Account account) {
                        return DropdownMenuItem<Account>(
                          value: account,
                          child: Text(account.name),
                        );
                      }).toList(),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text('Sort By'),
                    ),
                    RadioListTile<SortBy>(
                      title: const Text('Amount'),
                      value: SortBy.amount,
                      groupValue: _selectedSortBy,
                      onChanged: (SortBy? value) {
                        setState(() {
                          _selectedSortBy = value;
                        });
                      },
                    ),
                    RadioListTile<SortBy>(
                      title: const Text('Date'),
                      value: SortBy.date,
                      groupValue: _selectedSortBy,
                      onChanged: (SortBy? value) {
                        setState(() {
                          _selectedSortBy = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters2();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteExpenseDialog(Expense expense) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete this expense?'),
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
                  await DatabaseHelper.instance.deleteExpense(expense.id!);
                  _refreshExpenses();
                  showSnackBar(
                      context, 'Expense Deleted', SnackBarStatus.deleted);
                } catch (e) {
                  showSnackBar(
                      context,
                      'Could not Delete expense. Please try again!',
                      SnackBarStatus.error);
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
