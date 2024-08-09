import 'package:expensero/utils/my_app_bar.dart';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/expense.dart';
import '../utils/date.dart';
import '../utils/formatting.dart';
import 'add_expense_screen.dart';
import 'analysis_screen.dart';
import 'category_list_screen.dart';
import 'account_list_screen.dart';
import 'all_expenses_screen.dart'; // You'll need to create this screen

class HomeScreen extends StatefulWidget {
  static Future<void> refreshAndClear(BuildContext context) async {
    // Pop all routes until we reach the root
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Push a new instance of HomeScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> recentExpenses = [];
  double todayTotal = 0;
  double weekTotal = 0;
  Map<int, String> accountNames = {};

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refresh() async {
    await HomeScreen.refreshAndClear(context);
  }

  Future<void> _refreshData() async {
    final allExpenses = await DatabaseHelper.instance.getExpenses();
    weekTotal = await DatabaseHelper.instance.currentWeekExpense();
    final accountsData = await DatabaseHelper.instance.getAccounts();

    // Create a map of account IDs to account names
    final accountNamesMap = {
      for (var account in accountsData) account.id!: account.name
    };

    final now = DateTime.now();

    setState(() {
      allExpenses.sort((a, b) => b.date.compareTo(a.date));
      recentExpenses = allExpenses.take(3).toList();
      accountNames = accountNamesMap;
      todayTotal = allExpenses
          .where((e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day)
          .fold(0, (sum, e) => sum + e.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "Expensero",
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryCard('Today', todayTotal),
                  _buildSummaryCard('This Week', weekTotal),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Recent Expenses',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: TextButton(
                        child: const Text('See All'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllExpensesScreen()),
                          );
                        },
                      ),
                    ),
                    ...recentExpenses.map((expense) => ListTile(
                          title: Text(
                            expense.description,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          trailing: Text('${accountNames[expense.accountId]}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black87)),
                          subtitle: Row(
                            children: [
                              Text('${expense.amount}'),
                              const SizedBox(
                                  width:
                                      2), // Add some space between the amount and the icon
                              const Icon(
                                Icons
                                    .currency_rupee, // You can choose any icon that represents currency
                                size: 16, // Adjust the size as needed
                                color: Colors
                                    .green, // You can change the color as desired
                              ),
                              const SizedBox(
                                  width:
                                      4), // Add some space between the icon and the date
                              Text(
                                  '- ${DateUtil.getRelativeDate(expense.date)}'),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddExpenseScreen(expense: expense)),
                            );
                            _refreshData();
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.pie_chart),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AnalysisScreen())),
            ),
            IconButton(
              icon: Icon(Icons.category),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoryListScreen())),
            ),
            IconButton(
              icon: Icon(Icons.account_balance),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AccountListScreen())),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddExpenseScreen()));
                _refreshData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount) {
    String formattedAmount = Formatting.formatCurrency(amount);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₹$formattedAmount',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: amount > 1000 ? Colors.blueGrey : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
