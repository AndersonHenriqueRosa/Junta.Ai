import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanningService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para adicionar planejamento
  Future<bool> addPlanning(String planningName, double goalAmount) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw 'Usuário não autenticado.';
      }

      // Adiciona o planejamento ao Firestore
      await _firestore.collection('planejamento').add({
        'userId': user.uid, // UID do usuário autenticado
        'planningName': planningName, // Nome do planejamento
        'goalAmount': goalAmount, // Meta financeira
        'savedAmount': 0.0, // Inicia o valor poupado como 0
        'createdAt': FieldValue.serverTimestamp(), // Timestamp do servidor
      });

      return true; // Retorna sucesso
    } catch (e) {
      print('Erro ao adicionar planejamento: $e');
      return false; // Retorna falha
    }
  }

  // Função para buscar todos os planejamentos do usuário autenticado
  Stream<QuerySnapshot> getPlannings() {
    User? user = _auth.currentUser;

    if (user == null) {
      throw 'Usuário não autenticado.';
    }

    // Retorna o stream com os planejamentos do usuário
    return _firestore
        .collection('planejamento')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Função para atualizar o valor poupado de um planejamento
  Future<void> updateSavedAmount(String planningId, double newSavedAmount) async {
    try {
      await _firestore.collection('planejamento').doc(planningId).update({
        'savedAmount': newSavedAmount,
      });
    } catch (e) {
      print('Erro ao atualizar valor poupado: $e');
    }
  }

  // Função para excluir um planejamento
  Future<void> deletePlanning(String planningId) async {
    try {
      await _firestore.collection('planejamento').doc(planningId).delete();
    } catch (e) {
      print('Erro ao excluir planejamento: $e');
    }
  }
}
