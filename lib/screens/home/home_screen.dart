import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juntaai/screens/planning/planning_screen.dart';
import 'package:juntaai/screens/transactions/expense_screen.dart';
import 'package:juntaai/screens/transactions/income_screen.dart';
import 'package:juntaai/screens/transactions/transactions_screen.dart';
import 'package:juntaai/screens/welcome_screen.dart';
import 'package:juntaai/service/firebase_service.dart';
import 'package:juntaai/service/user_transactions_service.dart'; 
import 'package:juntaai/widgets/home_transactions_list.dart';
import 'package:juntaai/widgets/income_expense_card.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final UserTransactionsService _userTransactionsService = UserTransactionsService();
  
  User? _currentUser;
  List<Map<String, dynamic>> _recentTransactions = [];
  
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchRecentTransactions();
  }

  void _getCurrentUser() async {
    User? user = _firebaseService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Widget getProfileImage() {
    if (_currentUser?.photoURL != null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(_currentUser!.photoURL!),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.account_circle,
          size: 60,
          color: Colors.white,
        ),
      );
    }
  }

  void _logout() async {
    await _firebaseService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  Future<void> _fetchRecentTransactions() async {
    try {
      List<Map<String, dynamic>> transactions = await _userTransactionsService.fetchRecentTransactions();
      
      double income = 0.0;
      double expense = 0.0;
      
      for (var transaction in transactions) {
        double amount = transaction['amount']?.toDouble() ?? 0.0;
        if (transaction['type'] == 'income') {
          income += amount;
        } else if (transaction['type'] == 'expense') {
          expense += amount;
        }
      }

      setState(() {
        _recentTransactions = transactions;
        totalIncome = income;
        totalExpense = expense;
      });
    } catch (e) {
      print('Erro ao buscar transações: $e');
    }
  }

  Widget _buildIconMenu(BuildContext context, IconData icon, String label, Widget screen) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.07; // Tamanho do ícone adaptativo
    double fontSize = screenWidth * 0.035; // Tamanho da fonte adaptativo

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: iconSize, // Icone adaptativo
            backgroundColor: Colors.white,
            child: Icon(icon, size: iconSize, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          //   decoration: BoxDecoration(
          //    color: Colors.white,
          //    borderRadius: BorderRadius.circular(1),
          //  ),
            child: SizedBox(
              width: screenWidth * 0.2, // Largura adaptativa
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize, color: Colors.white), // Fonte adaptativa
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMonthHeader(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.06; // Tamanho da fonte adaptativo para "Este mês"
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, color: Colors.white, size: fontSize * 0.8), // Ícone de calendário
          const SizedBox(width: 10),
          Text(
            "Este mês",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ListTile(
                      title: Text(
                        "Olá, ${_currentUser?.displayName ?? _currentUser?.email ?? 'Usuário'}!",
                        style: const TextStyle(color: Colors.white),
                      ),
                      leading: getProfileImage(),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.bell_solid, color: Colors.white),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _logout,
                            child: const Text(
                              "Sair",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(child: buildMonthHeader(context)),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingValue),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: IncomeExpenseCard(
                            expenseData: ExpenseData(
                              Icons.arrow_upward_rounded,
                              "Receita",
                              totalIncome,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: IncomeExpenseCard(
                            expenseData: ExpenseData(
                              Icons.arrow_downward_rounded,
                              "Despesa",
                              totalExpense,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: paddingValue),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconMenu(context, Icons.trending_up, 'Receita', const IncomeScreen()),
                          const SizedBox(width: 10),
                          _buildIconMenu(context, Icons.money_off, 'Despesa', const ExpenseScreen()),
                          const SizedBox(width: 10),
                          _buildIconMenu(context, Icons.swap_horiz, 'Transações', const TransactionsScreen()),
                          const SizedBox(width: 10),
                          _buildIconMenu(context, Icons.event_note, 'Planejamento', const PlanningScreen()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(paddingValue, 20.0, paddingValue, 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transações Recentes",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: ListView(
                        children: _recentTransactions.map((transaction) {
                          return HomeTransactionsList(
                            categoryName: transaction['categoryName'] ?? 'Sem descrição',
                            amount: (transaction['amount'] ?? 0.0).toDouble(),
                            date: transaction['date'] != null
                                ? transaction['date'].toDate().toString()
                                : 'Data desconhecida',
                            type: transaction['type'] ?? 'outro',
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 70), // Espaçamento para a parte inferior da tela
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.menu),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          shape: const CircleBorder(),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          shape: const CircleBorder(),
        ),
        type: ExpandableFabType.fan,
        pos: ExpandableFabPos.center,
        fanAngle: 180,
        distance: 90,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.black.withOpacity(0.3),
          blur: 4,
        ),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IncomeScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.trending_up, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text('Receita', style: TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {},
                backgroundColor: Colors.blue,
                child: const Icon(Icons.smart_toy, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text('IA', style: TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpenseScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.money_off, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text('Despesa', style: TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
