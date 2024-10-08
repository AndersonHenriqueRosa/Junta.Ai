import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class PlanningDetailScreen extends StatefulWidget {
  final String planningName;
  final double savedAmount;
  final double totalGoal;

  const PlanningDetailScreen({
    Key? key,
    required this.planningName,
    required this.savedAmount,
    required this.totalGoal,
  }) : super(key: key);

  @override
  _PlanningDetailScreenState createState() => _PlanningDetailScreenState();
}

class _PlanningDetailScreenState extends State<PlanningDetailScreen> {
  late double currentSaved;
  final List<Map<String, dynamic>> revenues = []; 

  @override
  void initState() {
    super.initState();
    currentSaved = widget.savedAmount;
  }

  // Função para adicionar receita com valor e data
  void addRevenue(double amount) {
    setState(() {
      currentSaved += amount;
      revenues.add({
        'value': amount,
        'date': DateTime.now(), // Armazena a data da receita
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planningName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Categoria: ${widget.planningName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Total Objetivo: \$${widget.totalGoal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Total Poupado: \$${currentSaved.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: currentSaved / widget.totalGoal,
              minHeight: 10,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    double newAmount = 0.0;
                    return AlertDialog(
                      title: Text('Adicionar Receita'),
                      content: TextField(
                        decoration: InputDecoration(labelText: 'Valor'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          newAmount = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            if (newAmount > 0) {
                              addRevenue(newAmount);
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('Adicionar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancelar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Adicionar Receita'),
            ),
            SizedBox(height: 24),
            Text(
              'Receitas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Lista de receitas
            Expanded(
              child: revenues.isEmpty
                  ? Center(child: Text('Nenhuma receita adicionada'))
                  : ListView.builder(
                      itemCount: revenues.length,
                      itemBuilder: (context, index) {
                        // Formatação da data
                        String formattedDate = DateFormat('dd/MM/yyyy').format(revenues[index]['date']);
                        return ListTile(
                          title: Text('Valor: \$${revenues[index]['value'].toStringAsFixed(2)}'),
                          subtitle: Text('Data: $formattedDate'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
