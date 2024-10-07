import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juntaai/screens/planning_screen.dart';
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
  final UserTransactionsService _userTransactionsService =
      UserTransactionsService(); 
      
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
        child: Icon(
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
      MaterialPageRoute(
          builder: (context) =>
              const WelcomeScreen()
      ),           
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
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    },
    child: Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Icon(icon, size: 30, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12), 
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12), 
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: Colors.orange,
  body: Column(
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
                  style: TextStyle(color: Colors.white),
                ),
                leading: getProfileImage(), 
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Icon(CupertinoIcons.bell_solid, color: Colors.white), 
                    const SizedBox(width: 8), 
                    ElevatedButton(
                      onPressed: _logout,
                      child: const Text("Sair",
                      style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, 
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), 
                      ),
                    ),
                  ],
                ),              
                ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Text(
                    //   "Saldo Atual",
                    //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    // ),
                    // const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), 
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12.0), 
                    ),
                    child: Text(
                      'Este mês', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18.0, fontWeight: FontWeight.w800, color: Colors.black), 
                    ),
                  ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: IncomeExpenseCard(
                      expenseData: ExpenseData(
                        Icons.arrow_upward_rounded,
                        "Receita",
                        totalIncome.toStringAsFixed(2),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: IncomeExpenseCard(
                      expenseData: ExpenseData(
                        Icons.arrow_downward_rounded,
                        "Despesa",
                        totalExpense.toStringAsFixed(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 16), // Espaço na esquerda para evitar que os ícones fiquem colados na borda
                  _buildIconMenu(context, Icons.trending_up, 'Receita', IncomeScreen()),
                  const SizedBox(width: 16),
                  _buildIconMenu(context, Icons.money_off, 'Despesa', ExpenseScreen()),
                  const SizedBox(width: 16),
                  _buildIconMenu(context, Icons.swap_horiz, 'Transações', TransactionsScreen()),
                  const SizedBox(width: 16),
                  _buildIconMenu(context, Icons.event_note, 'Planejamento', PlanningScreen()),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16.0),

      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
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
                  children: [
                    ..._recentTransactions.map((transaction) {
                      return HomeTransactionsList(
                        categoryName: transaction['categoryName'] ?? 'Sem descrição',
                        amount: transaction['amount'] ?? 0.0,
                        date: transaction['date'] != null
                            ? transaction['date'].toDate().toString() 
                            : 'Data desconhecida',
                        type: transaction['type'] ?? 'outro', 
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
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
          },          backgroundColor: Colors.red, 
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
