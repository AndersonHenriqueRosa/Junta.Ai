import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCategory(String name, String type) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      await _firestore.collection('categories').add({
        'userId': userId,
        'name': name,
        'type': type,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUserCategories() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getIncomeCategories(String userId) async {
    try {
      // Referência à coleção de categorias de receita do usuário
      final incomeCategoriesRef = _firestore
          .collection('categories')
          .doc(userId)
          .collection('incomeCategories');

      // Obtém todos os documentos da subcoleção
      final querySnapshot = await incomeCategoriesRef.get();

      // Mapeia os documentos para uma lista de mapas
      final categories = querySnapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      return categories;
    } catch (e) {
      print('Erro ao buscar categorias de receita: $e');
      return [];
    }
  }

  collection(String s) {}
}
