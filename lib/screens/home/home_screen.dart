import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juntaai/screens/welcome_screen.dart';
import 'package:juntaai/service/firebase_service.dart';
import 'package:juntaai/service/user_transactions_service.dart'; // Importa o serviço de transações
import 'package:juntaai/widgets/custom_scaffold.dart';
import 'package:juntaai/widgets/home_transactions_list.dart';
import 'package:juntaai/widgets/income_expense_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final UserTransactionsService _userTransactionsService =
      UserTransactionsService(); // Nova instância do serviço
  User? _currentUser;
  List<Map<String, dynamic>> _recentTransactions =
      []; // Lista para armazenar as transações

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchRecentTransactions(); // Busca as transações recentes
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
          shape: BoxShape.circle, // Faz o contêiner ser circular
          // border: Border.all(
          //   color: Colors.grey.shade300, // Cor da borda externa
          //   width: 2, // Largura da borda
          // ),
          image: DecorationImage(
            image: NetworkImage(_currentUser!.photoURL!),
            fit: BoxFit.contain, // Ajusta a imagem para preencher o contêiner
          ),
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Faz o contêiner ser circular
          // border: Border.all(
          //   color: Colors.grey.shade300, // Cor da borda externa
          //   width: 2, // Largura da borda
          // ),
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
    await _firebaseService.signOut(); // Chama a função de logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const WelcomeScreen()), // Redireciona para a WelcomeScreen
    );
  }

  Future<void> _fetchRecentTransactions() async {
    try {
      List<Map<String, dynamic>> transactions =
          await _userTransactionsService.fetchRecentTransactions();
      setState(() {
        _recentTransactions = transactions; // Atualiza a lista de transações
      });
    } catch (e) {
      print('Erro ao buscar transações: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.orange, // Cor do fundo da seção superior
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      "Olá, ${_currentUser?.displayName ?? _currentUser?.email ?? 'Usuário'}!",
                      style: TextStyle(color: Colors.white),
                    ),
                    leading:
                        getProfileImage(), // Chama a função para exibir a imagem do usuário
                    trailing: const Icon(CupertinoIcons.bell_solid,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Saldo Atual",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '100', // Valor fictício
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: IncomeExpenseCard(
                          expenseData: ExpenseData(
                            Icons.arrow_upward_rounded,
                            "Receita",
                            '200', // Valor fictício
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: IncomeExpenseCard(
                          expenseData: ExpenseData(
                            Icons.arrow_downward_rounded,
                            "Despesa",
                            '300', // Valor fictício
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Cor do botão de logout
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Seção de transações recentes que ocupará o restante do espaço disponível
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
              child: ListView(
                children: [
                  const SizedBox(height: 20.0),
                  Text(
                    "Transações Recentes",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16.0),
                  // Exibindo a lista de transações
                  ..._recentTransactions.map((transaction) {
                    return HomeTransactionsList(
                      categoryName:
                          transaction['categoryName'] ?? 'Sem descrição',
                      amount: transaction['amount'] ?? 0.0,
                      date: transaction['date'] != null
                          ? transaction['date']
                              .toDate()
                              .toString() // Formate a data conforme necessário
                          : 'Data desconhecida',
                      type: transaction['type'] ??
                          'outro', // Obtem o tipo correto
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
