
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanningService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addPlanning(String planningName, double goalAmount) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        print('Usuário não autenticado.');
        throw 'Usuário não autenticado.';
      }

      print('Adicionando planejamento: $planningName, Meta: $goalAmount');

      await _firestore.collection('planning').add({
        'userId': user.uid, 
        'planningName': planningName, 
        'goalAmount': goalAmount, 
        'savedAmount': 0.0, 
        'createdAt': FieldValue.serverTimestamp(), 
      });

      print('Planejamento adicionado com sucesso');
      return true; 
    } catch (e) {
      print('Erro ao adicionar planejamento: $e');
      return false; 
    }
  }

  Future<List<Map<String, dynamic>>> fetchPlannings() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        print('Usuário não autenticado.');
        throw 'Usuário não autenticado.';
      }

      print('Buscando planejamentos para o usuário: ${user.uid}');

      QuerySnapshot snapshot = await _firestore
          .collection('planning')
          .where('userId', isEqualTo: user.uid)
          .get();

      print('Planejamentos encontrados: ${snapshot.docs.length}');

      List<Map<String, dynamic>> plannings = snapshot.docs.map((doc) {
        print('Planejamento: ${doc['planningName']}');
        return {
          'id': doc.id,
          'planningName': doc['planningName'],
          'savedAmount': (doc['savedAmount'] as num).toDouble(),
          'goalAmount': (doc['goalAmount'] as num).toDouble(),
        };
      }).toList();

      print('Retornando lista de planejamentos');
      return plannings;
    } catch (e) {
      print('Erro ao buscar planejamentos: $e');
      throw e; 
    }
  }


   Future<void> addRevenueToPlanning(String planningId, double amount) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw 'Usuário não autenticado.';
      }

      DocumentReference planningRef = _firestore.collection('planning').doc(planningId);

      await _firestore.runTransaction((transaction) async {
        await _firestore.collection('planning').doc(planningId).collection('revenues').add({
          'amount': amount,
          'date': FieldValue.serverTimestamp(),
        });

        QuerySnapshot revenuesSnapshot = await _firestore
            .collection('planning')
            .doc(planningId)
            .collection('revenues')
            .get();

        double newSavedAmount = revenuesSnapshot.docs.fold(0.0, (sum, doc) {
          return sum + (doc['amount'] as num).toDouble();
        });

        transaction.update(planningRef, {'savedAmount': newSavedAmount});
      });
    } catch (e) {
      print('Erro ao adicionar receita ao planejamento e recalcular o valor: $e');
      throw e;
    }
  }


   Future<List<Map<String, dynamic>>> fetchRevenues(String planningId) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw 'Usuário não autenticado.';
      }

      QuerySnapshot snapshot = await _firestore
          .collection('planning')
          .doc(planningId)
          .collection('revenues')
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> revenues = snapshot.docs.map((doc) {
        return {
          'value': (doc['amount'] as num).toDouble(),
          'date': (doc['date'] as Timestamp).toDate(),
        };
      }).toList();

      return revenues;
    } catch (e) {
      print('Erro ao buscar histórico de receitas: $e');
      throw e;
    }
  }

 Future<double> getUpdatedSavedAmount(String planningId) async {
    try {
      DocumentSnapshot planningSnapshot = await _firestore.collection('planning').doc(planningId).get();

      if (!planningSnapshot.exists) {
        throw 'Planejamento não encontrado';
      }

      double updatedSavedAmount = (planningSnapshot['savedAmount'] as num).toDouble();

      return updatedSavedAmount;
    } catch (e) {
      print('Erro ao buscar savedAmount: $e');
      throw e;
    }
  }  
}