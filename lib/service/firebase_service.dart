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
  Future<User?> signUp(String email, String password, String fullName,
      String phoneNumber) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar informações do usuário no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Erro ao criar conta: ${e.message}');
      return null;
    } catch (e) {
      print('Erro inesperado: $e');
      return null;
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
    } catch (e) {
      throw 'Erro ao fazer login com Google: $e';
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

  Future<void> _saveUserToFirestore(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    // Verifica se o usuário já existe no Firestore
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': user.displayName,
        'email': user.email,
        'phoneNumber': null, // O Google não fornece o número de telefone
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> createDefaultCategories() async {
    final QuerySnapshot categoriesSnapshot =
        await _firestore.collection('categories').get();
    if (categoriesSnapshot.docs.isEmpty) {
      List<Map<String, dynamic>> defaultCategories = [
        {'name': 'Mercado', 'type': 'transaction'},
        {'name': 'Farmácia', 'type': 'transaction'},
        {'name': 'Transporte', 'type': 'transaction'},
        {'name': 'Aluguel', 'type': 'transaction'},
        {'name': 'Entretenimento', 'type': 'transaction'},
        {'name': 'Reserva de emergência', 'type': 'goal'},
        {'name': 'Fazer uma viagem', 'type': 'goal'},
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
