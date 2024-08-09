import 'package:expensero/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'all_expenses_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  final Map<int, double> _categoryTotals = {};
  double _totalExpense = 0;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  String? _selectedCustomDateRange;
  Account? _selectedAccount;
  int? _selectedCategoryId;
  // List<String> _accounts = ['All Accounts', 'Account 1', 'Account 2'];
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.getExpenses();
    final accountsData = await DatabaseHelper.instance.getAccounts();
    final categoriesData = await DatabaseHelper.instance.getCategories();
    // categoriesData
    //     .forEach((cat) => print('Category ${cat.name} id is ${cat.id}'));
    // print('${categoriesData.first.name} id is ${categoriesData.first.id}');
    setState(() {
      _expenses = expenses;
      _categories = categoriesData;
      _accounts = accountsData;
      _selectedCustomDateRange = 'This Month';
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _categoryTotals.clear();
    _totalExpense = 0;
    final startOfDay =
        DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endOfDay = DateTime(_endDate.year, _endDate.month, _endDate.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    for (var expense in _expenses) {
      if (expense.date.isAtSameMomentAs(startOfDay) ||
          expense.date.isAtSameMomentAs(endOfDay) ||
          (expense.date.isAfter(startOfDay) &&
                  expense.date.isBefore(endOfDay)) &&
              (_selectedAccount == null ||
                  expense.accountId == _selectedAccount!.id)) {
        _categoryTotals[expense.categoryId!] =
            (_categoryTotals[expense.categoryId!] ?? 0) + expense.amount;
        _totalExpense += expense.amount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Expense Analysis",
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(),
          _buildAccountSelector(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expense:  ${_totalExpense.toStringAsFixed(2)} ₹',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _totalExpense > 0
                        ? _buildPieChart()
                        : const Text('No expense incurred in this time range'),
                    const SizedBox(height: 10),
                    _buildCategoryList(),
                  ],
                ),
              ),
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
              icon: const Icon(Icons.list),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllExpensesScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _buildAccountSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: 180,
        height: 40, // or any specific width that fits your layout
        child: DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButton<Account>(
              value: _selectedAccount,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              isExpanded: true,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
              items: [
                const DropdownMenuItem<Account>(
                  value: null,
                  child: Text('All Accounts'),
                ),
                ..._accounts.map((account) {
                  return DropdownMenuItem<Account>(
                    value: account,
                    child: Text(account.name),
                  );
                }),
              ],
              onChanged: (Account? newValue) {
                setState(() {
                  _selectedAccount = newValue;
                  _calculateTotals();
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: _getCategorySections(),
              centerSpaceRadius: 75,
              sectionsSpace: 1,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (event is FlTapUpEvent && pieTouchResponse != null) {
                      final touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                      if (touchedIndex >= 0) {
                        _selectedCategoryId =
                            _categoryTotals.keys.elementAt(touchedIndex);
                      } else {
                        _selectedCategoryId = null;
                      }
                    } else {
                      _selectedCategoryId = null;
                    }
                  });
                },
              ),
            ),
          ),
          Center(
            child: _buildCenterText(),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterText() {
    if (_selectedCategoryId == null) {
      return Text(
        'Total\n${_formatCurrency(_totalExpense)}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }

    final category = _categories.firstWhere((c) => c.id == _selectedCategoryId);
    final expense = _categoryTotals[_selectedCategoryId] ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          category.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 0),
        Text(
          _formatCurrency(expense),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ₹';
  }

  List<PieChartSectionData> _getCategorySections() {
    return _categoryTotals.entries.map((entry) {
      final categoryId = entry.key;
      final category = _categories.firstWhere((c) => c.id == categoryId);
      final double percentage = (entry.value / _totalExpense) * 100;
      final isSelected = _selectedCategoryId == categoryId;

      return PieChartSectionData(
        color: _getCategoryColor(category.id!),
        value: entry.value,
        title: isSelected ? '' : '${percentage.toStringAsFixed(1)}%',
        radius: isSelected ? 85 : 75,
        titleStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(int categoryId) {
    // This ensures a consistent color for each category, regardless of its ID value
    final colorIndex = categoryId % Colors.primaries.length;
    return Colors.primaries[colorIndex];
  }

  Widget _buildCategoryList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 6, right: 6, top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 16),
          ..._categoryTotals.entries.map((entry) {
            final category = _categories.firstWhere((c) => c.id == entry.key);
            return GestureDetector(
              onTap: () => _showCategoryDetails(category.name, entry.value),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
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
        _calculateTotals();
      });
    }
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
      _calculateTotals();
    });
  }

  void _showCategoryDetails(String categoryName, double total) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Category: $categoryName'),
          content: Text('Total: \$${total.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
