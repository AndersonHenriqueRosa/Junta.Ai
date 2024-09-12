import 'package:flutter/material.dart';
import 'package:juntaai/data/user_info.dart';
import 'package:juntaai/widgets/income_expense_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:juntaai/widgets/transaction_item_tile.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(250.0), // Ajuste a altura da AppBar
        child: AppBar(
          backgroundColor: Colors.orange,
          leading: null, // Remove o ícone de retorno
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text("Olá! ${userdata.name}!"),
                  leading: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Image.asset("assets/imgs/anderson.jpeg"),
                  ),
                  trailing: const Icon(CupertinoIcons.bell, color: Colors.white),
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
                        userdata.totalBalance,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18.0, fontWeight: FontWeight.w800),
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
                        expenseData: ExpenseData(Icons.arrow_upward_rounded, "Receita", userdata.inFlow),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: IncomeExpenseCard(
                        expenseData: ExpenseData(Icons.arrow_downward_rounded, "Despesa", userdata.outFlow),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.orange, // Cor de fundo da tela
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Cor de fundo do conteúdo
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32.0),
                    Text(
                      "Transações Recentes",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16.0),
                    ...userdata.transaction
                        .map((transaction) => TransactionItemTile(transaction: transaction))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
