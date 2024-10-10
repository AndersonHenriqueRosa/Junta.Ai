import 'package:flutter/material.dart';
import 'package:juntaai/screens/planning/add_planning_screen.dart';
import 'package:juntaai/screens/planning/planning_detail_screen.dart';
import 'package:juntaai/service/planning_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; // Importe a biblioteca

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final PlanningService _planningService = PlanningService();
  User? get currentUser => FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> plannings = [];
  bool isLoading = true;
  double totalSavedAmount = 0.0;
  double totalGoalAmount = 0.0;

  // Controladores para os valores formatados em Real
  late MoneyMaskedTextController totalSavedController;
  late MoneyMaskedTextController totalGoalController;

  @override
  void initState() {
    super.initState();
    _fetchPlannings(); // Chama a função de buscar dados ao inicializar

    // Inicializa os controladores de valor com zero
    totalSavedController = MoneyMaskedTextController(
      initialValue: totalSavedAmount,
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );

    totalGoalController = MoneyMaskedTextController(
      initialValue: totalGoalAmount,
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );
  }

  // Função para obter os planejamentos e calcular os totais
  void _fetchPlannings() async {
    setState(() {
      isLoading = true;
    });

    if (currentUser == null) {
      print('Usuário não autenticado.');
      setState(() {
        isLoading = false;
        plannings = [];
      });
      return;
    }

    try {
      List<Map<String, dynamic>> fetchedPlannings = await _planningService.fetchPlannings();
      double saved = 0.0;
      double goal = 0.0;

      for (var planning in fetchedPlannings) {
        saved += planning['savedAmount'] ?? 0.0;
        goal += planning['goalAmount'] ?? 0.0;
      }

      setState(() {
        plannings = fetchedPlannings;
        totalSavedAmount = saved;
        totalGoalAmount = goal;

        // Atualiza os controladores de valor com os novos totais
        totalSavedController.updateValue(totalSavedAmount);
        totalGoalController.updateValue(totalGoalAmount);

        isLoading = false;
      });
    } catch (e) {
      print('Erro ao buscar planejamentos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = totalGoalAmount > 0
        ? totalSavedAmount / totalGoalAmount
        : 0.0; // Calcula a porcentagem da barra de progresso

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Planejamentos",
          style: TextStyle(color: Colors.white),
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
            color: Colors.orange, // Fundo laranja
          ),
          Column(
            children: [
              // Card com o total dos planejamentos
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
                        const Text(
                          'Resumo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Exibição dos valores formatados em Real
                        Text('Total Poupado: ${totalSavedController.text}'),
                        Text('Meta Total: ${totalGoalController.text}'),
                        const SizedBox(height: 16.0),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 8.0),
                        Text('${(progress * 100).toStringAsFixed(1)}% Concluído'),
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
                  padding: const EdgeInsets.all(16.0),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: plannings.length + 1, // Inclui o botão de adicionar
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => addPlanningScreen(),
                                    ),
                                  ).then((_) {
                                    _fetchPlannings(); // Atualiza os dados ao voltar
                                  });
                                },
                                child: Card(
                                  elevation: 4.0,
                                  color: Colors.orange,
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              Map<String, dynamic> planning = plannings[index - 1];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlanningDetailScreen(
                                        planningId: planning['id'],
                                        planningName: planning['planningName'],
                                        savedAmount: planning['savedAmount'],
                                        totalGoal: planning['goalAmount'],
                                      ),
                                    ),
                                  ).then((_) {
                                    _fetchPlannings();
                                  });
                                },
                                child: Card(
                                  elevation: 4.0,
                                  child: Center(
                                    child: Text(
                                      planning['planningName'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
