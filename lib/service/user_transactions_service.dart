import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTransactionsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>> fetchCategories() async {
    Map<String, String> categories = {}; 

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .where('type', isEqualTo: 'transaction')
          .get();

      for (var doc in snapshot.docs) {
        categories[doc.id] = doc['name'] as String;
      }

      print(categories); 
    } catch (e) {
      print('Erro ao buscar categorias: $e');
    }

    return categories; 
  }



Future<List<Map<String, dynamic>>> fetchRecentTransactions() async {
  User? user = _auth.currentUser; 
  List<Map<String, dynamic>> transactions = [];

  if (user == null) {
    throw 'Usuário não autenticado.'; 
  }

  try {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    QuerySnapshot snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid) 
        .where('date', isGreaterThanOrEqualTo: startOfMonth) 
        .where('date', isLessThanOrEqualTo: endOfMonth) 
        .orderBy('date', descending: true) 
        .limit(10) 
        .get();

    for (var doc in snapshot.docs) {
      transactions.add(doc.data() as Map<String, dynamic>);
    }

    return transactions; 
  } catch (e) {
    print('Erro ao buscar transações: $e');
    return transactions; 
  }
}



 Future<List<Map<String, dynamic>>> fetchTransactionsByMonth({
  required DateTime selectedMonth,
  required bool showOnlyIncome,
  required bool showOnlyExpense,
}) async {
  User? user = _auth.currentUser; 
  List<Map<String, dynamic>> transactions = [];

  if (user == null) {
    throw 'Usuário não autenticado.'; 
  }

  try {
    DateTime startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

    QuerySnapshot snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date', descending: true)
        .get();

    for (var doc in snapshot.docs) {
      transactions.add(doc.data() as Map<String, dynamic>);
    }

    if (showOnlyIncome) {
      transactions = transactions.where((t) => t['type'] == 'income').toList();
    } else if (showOnlyExpense) {
      transactions = transactions.where((t) => t['type'] == 'expense').toList();
    }

    return transactions;
  } catch (e) {
    print('Erro ao buscar transações: $e');
    return transactions;
  }
}


}
