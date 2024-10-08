import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juntaai/screens/planning/add_planning_screen.dart';
import 'package:juntaai/screens/planning/planning_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juntaai/service/planning_service.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PlanningService _planningService = PlanningService.instance;


  User? get currentUser => _auth.currentUser;

  // Função para obter os planejamentos do Firestore usando fetch único
  Stream<QuerySnapshot<Object?>> _getPlannings() {
    return _planningService.getPlannings();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Define o fundo branco da tela principal
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
          // Container laranja no fundo
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.orange, // Fundo laranja
          ),
          // Coluna principal com o conteúdo
          Column(
            children: [
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
                  child: FutureBuilder<QuerySnapshot>(
                    future: _getPlannings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text("Erro ao carregar os planejamentos"));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Nenhum planejamento encontrado"));
                      }

                      // Extrai os dados dos planejamentos
                      var planningDocs = snapshot.data!.docs;

                      double totalSaved = planningDocs.fold(0.0, (sum, doc) => sum + (doc['savedAmount'] as double));
                      double totalGoal = planningDocs.fold(0.0, (sum, doc) => sum + (doc['goalAmount'] as double));
                      double progress = totalSaved / totalGoal;

                      return Column(
                        children: [
                          Text(
                            'Saldo Total: R\$${totalSaved.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Meta Total: R\$${totalGoal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: totalGoal > 0 ? progress : 0,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}% Poupado',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Falta: R\$${(totalGoal - totalSaved).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Grid de planejamentos
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: planningDocs.length + 1, // Inclui o botão de adicionar
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Primeiro quadrado é o botão de adicionar planejamento
                                  return GestureDetector(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => addPlanningScreen(),
                                        ),
                                      );
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
                                  // Demais quadrados são os planejamentos
                                  var planning = planningDocs[index - 1];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlanningDetailScreen(
                                            planningName: planning['planningName'],
                                            savedAmount: planning['savedAmount'],
                                            totalGoal: planning['goalAmount'],
                                          ),
                                        ),
                                      );
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
                        ],
                      );
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
