import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserExpenseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addTransactionExpense(String categoryId, String categoryName,
      double amount, String? description, DateTime date) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw 'Usuário não autenticado.';
      }

      await _firestore.collection('transactions').add({
        'userId': user.uid,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'date': date,
        'amount': amount,
        'description': description,
        'type': 'expense',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true; // Retorna true se a transação foi bem-sucedida
    } catch (e) {
      print('Erro ao adicionar despesa: $e');
      return false; // Retorna false se houve um erro
    }
  }
}
