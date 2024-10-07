import 'package:flutter/material.dart';

class ExpenseData {
  final IconData icon;
  final String label;
  final String amount;
  const ExpenseData(this.icon, this.label, this.amount);
}

class IncomeExpenseCard extends StatelessWidget {
  final ExpenseData expenseData;
  final bool active; // Novo parâmetro active

  const IncomeExpenseCard({Key? key, required this.expenseData, this.active = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset.zero, spreadRadius: 3, blurRadius: 12)
        ],
        color: active // Muda a cor dependendo se está ativo ou não
            ? (expenseData.label == "Receita" ? Colors.green : Colors.red)
            : Colors.grey[300], // Cor inativa
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            expenseData.icon,
            color: active ? Colors.white : Colors.grey, // Ícone muda para cinza se inativo
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expenseData.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: active ? Colors.white : Colors.grey, // Texto muda para cinza se inativo
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    expenseData.amount,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: active ? Colors.white : Colors.grey, // Valor muda para cinza se inativo
                          fontSize: 20,
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
