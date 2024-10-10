import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa a biblioteca intl para formatação de moeda

class ExpenseData {
  final IconData icon;
  final String label;
  final double amount; // Modificado para double, pois iremos formatar como moeda
  const ExpenseData(this.icon, this.label, this.amount);
}

class IncomeExpenseCard extends StatelessWidget {
  final ExpenseData expenseData;
  final bool active;

  const IncomeExpenseCard({Key? key, required this.expenseData, this.active = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obter o tamanho da tela para ajustar dinamicamente os elementos
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.1; // Tamanho adaptativo do ícone
    double labelFontSize = screenWidth * 0.04; // Tamanho adaptativo do texto
    double amountFontSize = screenWidth * 0.04; // Tamanho adaptativo do valor

    // Formata o valor para o formato de moeda brasileira
    final String formattedAmount = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(expenseData.amount);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03), // Padding adaptativo
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset.zero, spreadRadius: 3, blurRadius: 12)
        ],
        color: active
            ? (expenseData.label == "Receita" ? Colors.green : Colors.red)
            : Colors.grey[300], // Cor inativa
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            expenseData.icon,
            size: iconSize, // Ícone com tamanho adaptativo
            color: active ? Colors.white : Colors.grey, // Ícone muda para cinza se inativo
          ),
          const SizedBox(width: 12), // Espaçamento entre o ícone e o texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expenseData.label,
                  style: TextStyle(
                    fontSize: labelFontSize, // Tamanho adaptativo do texto
                    color: active ? Colors.white : Colors.grey, // Texto muda para cinza se inativo
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    formattedAmount, // Exibe o valor formatado como moeda brasileira
                    style: TextStyle(
                      fontSize: amountFontSize, // Tamanho adaptativo do valor
                      color: active ? Colors.white : Colors.grey, // Valor muda para cinza se inativo
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
