import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:juntaai/service/planning_service.dart'; // Importe o service

class PlanningDetailScreen extends StatefulWidget {
  final String planningId;
  final String planningName;
  final double savedAmount;
  final double totalGoal;

  const PlanningDetailScreen({
    Key? key,
    required this.planningId,
    required this.planningName,
    required this.savedAmount,
    required this.totalGoal,
  }) : super(key: key);

  @override
  _PlanningDetailScreenState createState() => _PlanningDetailScreenState();
}

class _PlanningDetailScreenState extends State<PlanningDetailScreen> {
  final PlanningService _planningService = PlanningService();
  final List<Map<String, dynamic>> transactions = [];

  double currentSavedAmount = 0;

  late MoneyMaskedTextController savedAmountController;
  late MoneyMaskedTextController totalGoalController;

  @override
  void initState() {
    super.initState();

    currentSavedAmount = widget.savedAmount;

    savedAmountController = MoneyMaskedTextController(
      initialValue: currentSavedAmount,
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );

    totalGoalController = MoneyMaskedTextController(
      initialValue: widget.totalGoal,
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );

    _updateTransactions();
  }

  void _updateTransactions() async {
    try {
      List<Map<String, dynamic>> fetchedTransactions = await _planningService.fetchRevenues(widget.planningId);

      double updatedSavedAmount = await _planningService.getUpdatedSavedAmount(widget.planningId);

      setState(() {
        transactions.clear();
        transactions.addAll(fetchedTransactions);

        currentSavedAmount = updatedSavedAmount;
        savedAmountController.updateValue(currentSavedAmount);
      });
    } catch (e) {
      print('Erro ao buscar transações: $e');
    }
  }

  void addTransaction(double amount) async {
    try {
      await _planningService.addRevenueToPlanning(widget.planningId, amount);
      _updateTransactions();
    } catch (e) {
      print('Erro ao adicionar transação: $e');
    }
  }

  void showAddAmountDialog({required bool isRevenue}) {
    double newAmount = 0.0;
    MoneyMaskedTextController amountController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isRevenue ? 'Adicionar Receita' : 'Adicionar Despesa'),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              newAmount = amountController.numberValue;
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (newAmount > 0) {
                  addTransaction(isRevenue ? newAmount : -newAmount);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.planningName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.orange,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Objetivo: ${totalGoalController.text}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Total Poupado: ${savedAmountController.text}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        LinearProgressIndicator(
                          value: currentSavedAmount / widget.totalGoal,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${((currentSavedAmount / widget.totalGoal) * 100).toStringAsFixed(1)}% Concluído',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Movimentações',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: transactions.isEmpty
                              ? const Center(child: Text('Nenhuma receita ou despesa adicionada'))
                              : ListView.builder(
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    String formattedDate =
                                        DateFormat('dd/MM/yyyy').format(transactions[index]['date']);
                                    String formattedValue = MoneyMaskedTextController(
                                      initialValue: transactions[index]['value'].abs(),
                                      leftSymbol: 'R\$ ',
                                      decimalSeparator: ',',
                                      thousandSeparator: '.',
                                    ).text;

                                    bool isExpense = transactions[index]['value'] < 0;
                                    IconData arrowIcon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;
                                    Color valueColor = isExpense ? Colors.red : Colors.green;

                                    return ListTile(
                                      leading: Icon(
                                        arrowIcon,
                                        color: valueColor,
                                      ),
                                      title: Text(
                                        '${isExpense ? '-' : ''}$formattedValue',
                                        style: TextStyle(
                                          color: valueColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text('Data: $formattedDate'),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    showAddAmountDialog(isRevenue: true);
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    showAddAmountDialog(isRevenue: false);
                  },
                  child: const Icon(Icons.remove, color: Colors.white),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
