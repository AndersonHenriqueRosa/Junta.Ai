import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erro ao sair: $e');
    }
  }

  // Future<User?> signUp(String email, String password) async {
  //   try {
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return userCredential.user;
  //   } on FirebaseAuthException catch (e) {
  //     print('Erro ao criar conta: ${e.message}');
  //     return null;
  //   } catch (e) {
  //     print('Erro inesperado: $e');
  //     return null;
  //   }
  // }

  Future<User?> signUp(String email, String password, String fullName,
      String phoneNumber) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateProfile(displayName: fullName);

        await user.reload();
        user = _auth.currentUser;

        print('Conta criada com sucesso: ${user?.displayName}');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Erro ao criar conta: ${e.message}');
      return null;
    } catch (e) {
      print('Erro inesperado: $e');
      return null;
    }
  }

  // Future<User?> signUp(String email, String password, String fullName,
  //     String phoneNumber) async {
  //   try {
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     User? user = userCredential.user;

  //     if (user != null) {
  //       await _firestore.collection('users').doc(user.uid).set({
  //         'phoneNumber': phoneNumber,
  //       });
  //     }

  //     return user;
  //   } on FirebaseAuthException catch (e) {
  //     print('Erro ao criar conta: ${e.message}');
  //     return null;
  //   } catch (e) {
  //     print('Erro inesperado: $e');
  //     return null;
  //   }
  // }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId:
            '412508417412-nvccerm29qpcqbkp7tmspn0noh0us0ll.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // Usuário cancelou o login
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
      return userCredential.user;
    } catch (e) {
      throw 'Erro ao fazer login com Google: $e';
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
