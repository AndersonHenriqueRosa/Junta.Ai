import 'package:flutter/material.dart';

class HomeTransactionsList extends StatelessWidget {
  final String categoryName;
  final double amount;
  final String date;
  final String type;

  const HomeTransactionsList({
    Key? key,
    required this.categoryName,
    required this.amount,
    required this.date,
    required this.type,
  }) : super(key: key);

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Mercado':
        return Icons.fastfood;
      case 'transporte':
        return Icons.directions_car;
      case 'conta':
        return Icons.house;
      case 'entretenimento':
        return Icons.movie; // Exemplo de novo tipo
      default:
        return Icons.category; // Ícone padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset.zero,
            blurRadius: 10,
            spreadRadius: 4,
          ),
        ],
        color: const Color(0XFFf8fafb),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.orange, // Cor do fundo alterada para laranja
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Icon(
            _getCategoryIcon(categoryName),
            color: Colors.white,
          ), // Usar ícone baseado na categoria
        ),
        title: Text(
          categoryName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0XFF3a4d62),
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "R\$ ${amount.toStringAsFixed(2)}", // Formata o valor
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: type == 'income'
                        ? Colors.green // Cor verde se for income
                        : Colors.red, // Cor vermelha se for expense
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              date,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0XFF3a4d62),
                    fontSize: 12.0,
                  ),
            ),
          ],
        ),
        trailing: type == 'income' // Exibe a seta para cima se for "income"
            ? Icon(Icons.arrow_upward, color: Colors.green)
            : type == 'expense' // Exibe a seta para baixo se for "expense"
                ? Icon(Icons.arrow_downward, color: Colors.red)
                : null, // Sem ícone se não for income nem expense
      ),
    );
  }
}
