import 'package:flutter/material.dart';
import 'package:juntaai/data/user_info.dart';

class TransactionItemTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionItemTile({Key? key, required this.transaction}) : super(key: key);

  String getSign(TransactionType type) {
    return type == TransactionType.inFlow ? "+" : "-";
  }

  Icon _getCategoryIcon(ItemCategoryType categoryType) {
    switch (categoryType) {
      case ItemCategoryType.alimento:
        return const Icon(Icons.fastfood);
      case ItemCategoryType.transporte:
        return const Icon(Icons.directions_car);
      case ItemCategoryType.conta:
        return const Icon(Icons.house);
      default:
        return const Icon(Icons.category); // Ícone padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset.zero,
            blurRadius: 10,
            spreadRadius: 4,
          ),
        ],
        color: Color(0XFFf8fafb),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: _getCategoryIcon(transaction.categoryType), // Usa ícone baseado na categoria
        ),
        title: Text(transaction.itemCategoryName,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  color: const Color(0XFF3a4d62),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                )),
        subtitle: Text(
          transaction.itemName,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
                color: const Color(0XFF3a4d62),
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${getSign(transaction.transactionType)}${transaction.amount}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: transaction.transactionType == TransactionType.outFlow
                        ? Colors.red
                        : const Color(0xFF3a4d62),
                    fontSize: 13.0,
                  ),
            ),
            Text(
              transaction.date,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: const Color(0XFF3a4d62), fontSize: 13.0),
            ),
          ],
        ),
      ),
    );
  }
}
