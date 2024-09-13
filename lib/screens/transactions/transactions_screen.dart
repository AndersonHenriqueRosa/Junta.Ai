import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juntaai/data/user_info.dart';
import 'package:juntaai/screens/transactions/expense_screen.dart';
import 'package:juntaai/screens/transactions/income_screen.dart';
import 'package:juntaai/widgets/custom_scaffold.dart';
import 'package:juntaai/widgets/income_expense_card.dart';
import 'package:juntaai/widgets/transaction_item_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final allTransactions = userdata.transaction
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
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8.0), // Espaço entre o ícone e o texto
                      Text(
                        "Transações",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 24.0, // Ajuste o tamanho da fonte conforme necessário
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0), // Espaço reduzido entre o texto e o saldo
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
                      "Transações",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16.0),
                    ...allTransactions
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
