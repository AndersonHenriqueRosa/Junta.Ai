import 'package:flutter/material.dart';
import 'package:juntaai/screens/transactions/expense_screen.dart';
import 'package:juntaai/screens/transactions/income_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncomeScreen(),
                  ),
                );
              },
              child: Container(
                width: 150, // Largura do botão
                height: 50, // Altura padrão do botão
                decoration: BoxDecoration(
                  color: Colors.green, // Cor de fundo do botão
                  borderRadius: BorderRadius.circular(30), // Bordas arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Receita',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Cor do texto
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10), // Espaçamento entre os botões
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpenseScreen(),
                  ),
                );
              },
              child: Container(
                width: 150, // Largura do botão
                height: 50, // Altura padrão do botão
                decoration: BoxDecoration(
                  color: Colors.red, // Cor de fundo do botão
                  borderRadius: BorderRadius.circular(30), // Bordas arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Despesa',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Cor do texto
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
