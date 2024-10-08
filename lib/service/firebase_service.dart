import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//-------
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await createDefaultCategories();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email' || e.code == 'invalid-credential') {
        throw 'Usuário ou senha incorretos. Tente novamente';
      } else if (e.code == 'too-many-requests') {
        throw 'Conta temporariamente desativada devido a muitas tentativas falhas. Tente novamente mais tarde ou redefina sua senha.';
      } else {
        throw 'Erro de autenticação: ${e.message}';
      }
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  //-----------
Future<User?> signUp(String email, String password, String fullName) async {
  try {
    // Criação da conta de usuário no Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    // Atualiza o displayName no perfil do usuário no Firebase Authentication
    await user?.updateDisplayName(fullName);
    await user?.reload(); // Atualiza o usuário para garantir que o nome seja aplicado

    // Salvar as informações do usuário no Firestore
    await _firestore.collection('users').doc(user!.uid).set({
      'fullName': fullName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      throw 'O e-mail já está em uso por outra conta. Tente outro e-mail.';
    } else if (e.code == 'invalid-email') {
      throw 'O e-mail informado é inválido. Verifique o formato e tente novamente.';
    } else if (e.code == 'weak-password') {
      throw 'A senha é muito fraca. Tente uma senha mais forte.';
    } else if (e.code == 'operation-not-allowed') {
      throw 'O serviço de criação de contas está desativado. Entre em contato com o suporte.';
    } else {
      throw 'Erro ao criar conta: ${e.message}';
    }
  } catch (e) {
    throw 'Erro inesperado: $e';
  }
}


//-----------

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId:
            '412508417412-nvccerm29qpcqbkp7tmspn0noh0us0ll.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      await _saveUserToFirestore(user!);
      await createDefaultCategories();
      return user;
    } on FirebaseAuthException catch (e) {
      throw 'Erro de autenticação: ${e.message}';
    } catch (e) {
      if (e.toString().contains('popup_closed')) {
        throw 'O processo de login foi cancelado. Por favor, tente novamente';
      } else {
        throw 'Erro ao fazer login com Google: $e';
      }
    }
  }

  //-----------
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erro ao sair: $e');
    }
  }
  //------------------

  User? getCurrentUser() {
    return _auth.currentUser;
  }
//-------------------------

Future<void> sendPasswordResetEmail(String email) async {
  try {
    print('Tentando enviar e-mail para: $email');
    await _auth.sendPasswordResetEmail(email: email);
    print('E-mail de redefinição enviado com sucesso.');
  } on FirebaseAuthException catch (e) {
    print('Erro de FirebaseAuthException: ${e.code} - ${e.message}');
    if (e.code == 'invalid-email') {
      throw 'O e-mail fornecido é inválido. Verifique o formato e tente novamente.';
    } else if (e.code == 'user-not-found') {
      throw 'Nenhuma conta foi encontrada com este e-mail. Verifique se o e-mail está correto.';
    } else {
      throw 'Erro ao enviar e-mail de recuperação: ${e.message}';
    }
  } catch (e) {
    print('Erro inesperado: $e');
    throw 'Erro inesperado: $e';
  }
}


//--------------------------


  Future<void> _saveUserToFirestore(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': user.displayName,
        'email': user.email,
        'phoneNumber': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

Future<void> createDefaultCategories() async {
  final QuerySnapshot categoriesSnapshot =
      await _firestore.collection('categories').get();
  if (categoriesSnapshot.docs.isEmpty) {
    List<Map<String, dynamic>> defaultCategories = [
      // Receitas (income)
      {'name': 'Salário', 'type': 'income'},
      {'name': 'Freelance', 'type': 'income'},
      {'name': 'Investimentos', 'type': 'income'},
      {'name': 'Bônus', 'type': 'income'},
      {'name': 'Aluguel de Imóveis', 'type': 'income'},
      
      // Despesas (expense)
      {'name': 'Mercado', 'type': 'expense'},
      {'name': 'Farmácia', 'type': 'expense'},
      {'name': 'Transporte', 'type': 'expense'},
      {'name': 'Aluguel', 'type': 'expense'},
      {'name': 'Entretenimento', 'type': 'expense'},
      {'name': 'Educação', 'type': 'expense'},
      {'name': 'Restaurantes', 'type': 'expense'},
      {'name': 'Viagem', 'type': 'expense'},
    ];

    for (var category in defaultCategories) {
      await _firestore.collection('categories').add({
        'name': category['name'],
        'type': category['type'],
      });
    }
  }
}

}
