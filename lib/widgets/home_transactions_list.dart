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
        return Icons.movie; 
      default:
        return Icons.category; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
      color: const Color(0XFFf8fafb),
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.orange, 
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Icon(
            _getCategoryIcon(categoryName),
            color: Colors.white,
          ), 
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
              "R\$ ${amount.toStringAsFixed(2)}", 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: type == 'income'
                        ? Colors.green 
                        : Colors.red, 
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
        trailing: type == 'income' 
            ? Icon(Icons.arrow_upward, color: Colors.green)
            : type == 'expense' 
                ? Icon(Icons.arrow_downward, color: Colors.red)
                : null, 
      ),
    );
  }
}
