import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juntaai/data/user_info.dart';
import 'package:juntaai/take_right.dart';
import 'package:juntaai/widgets/custom_scaffold.dart';
import 'package:juntaai/widgets/income_expense_card.dart';
import 'package:juntaai/widgets/transaction_item_tile.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    // Obtém os últimos 10 itens da lista e inverte a lista para mostrar o mais recente primeiro
    final recentTransactions = userdata.transaction
        .takeRight(10) // Obtém os últimos 10 itens da lista
        .toList()
        .reversed // Inverte a lista para mostrar o mais recente primeiro
        .toList();

    return CustomScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.orange, // Cor do fundo da seção superior
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      "Olá, ${userdata.name}!",
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      child: Image.asset("assets/imgs/anderson.jpeg"),
                    ),
                    trailing: const Icon(CupertinoIcons.bell_solid, color: Colors.white),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Saldo Atual",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          userdata.totalBalance,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18.0, fontWeight: FontWeight.w800, color: Colors.white),
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
                            userdata.inFlow,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: IncomeExpenseCard(
                          expenseData: ExpenseData(
                            Icons.arrow_downward_rounded,
                            "Despesa",
                            userdata.outFlow,
                          ),
                        ),
                      ),
                    ],
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    Text(
                      "Transações Recentes",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16.0),
                    ...recentTransactions
                        .map((transaction) => TransactionItemTile(transaction: transaction))
                        .toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


