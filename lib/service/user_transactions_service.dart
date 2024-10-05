import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTransactionsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>> fetchCategories() async {
    Map<String, String> categories = {}; // Mapa para armazenar ID e nome

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .where('type', isEqualTo: 'transaction')
          .get();

      for (var doc in snapshot.docs) {
        // Armazena o ID como chave e o nome como valor
        categories[doc.id] = doc['name'] as String;
      }

      print(categories); // Imprime o mapa de categorias
    } catch (e) {
      print('Erro ao buscar categorias: $e');
    }

    return categories; // Retorna o mapa
  }

  Future<List<Map<String, dynamic>>> fetchRecentTransactions() async {
    User? user = _auth.currentUser; // Obtém o usuário atual
    List<Map<String, dynamic>> transactions =
        []; // Lista para armazenar as transações
    // Map<String, String> categoryNames =
    //     {}; // Mapa para armazenar os nomes das categorias

    if (user == null) {
      throw 'Usuário não autenticado.'; // Lança um erro se o usuário não estiver autenticado
    }

    try {
      // 1. Busca as transações
      QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId',
              isEqualTo: user.uid) // Filtra as transações pelo ID do usuário
          .orderBy('date',
              descending: true) // Ordena pelas transações mais recentes
          .limit(10) // Limita a busca às 10 transações mais recentes
          .get();

      // 2. Armazena as transações
      for (var doc in snapshot.docs) {
        transactions.add(doc.data() as Map<String, dynamic>);
      }

      // // 3. Obtém os IDs de categoria
      // Set<String> categoryIds =
      //     transactions.map((tx) => tx['categoryId'] as String).toSet();

      // // 4. Busca os nomes das categorias com base nos IDs
      // if (categoryIds.isNotEmpty) {
      //   QuerySnapshot categorySnapshot = await _firestore
      //       .collection('categories')
      //       .where(FieldPath.documentId,
      //           whereIn: categoryIds.toList()) // Busca categorias pelos IDs
      //       .get();

      //   for (var categoryDoc in categorySnapshot.docs) {
      //     categoryNames[categoryDoc.id] =
      //         categoryDoc['name'] as String; // Armazena o nome da categoria
      //   }
      // }

      // // 5. Adiciona o nome da categoria a cada transação
      // for (var transaction in transactions) {
      //   transaction['categoryName'] =
      //       categoryNames[transaction['categoryId']] ??
      //           'Categoria Desconhecida'; // Adiciona o nome da categoria
      // }

      return transactions; // Retorna a lista de transações
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return transactions; // Retorna uma lista vazia em caso de erro
    }
  }
}
