import 'package:flutter/material.dart';
import 'package:juntaai/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; 
  String? _errorMessage; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Center(
                child: Text(
                  'Esqueci a Minha Senha',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Entre com o seu Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Entre com o seu Email',
                          hintText: 'example@example.com',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 50.0),

                      SizedBox(
                        width: 250, 
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignInKey.currentState?.validate() ?? false) {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });

                              try {
                                FirebaseService firebaseService = FirebaseService();
                                await firebaseService.sendPasswordResetEmail(
                                  _emailController.text,
                                );

                                setState(() {
                                  _isLoading = false;
                                });

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Sucesso'),
                                      content: const Text(
                                          'Um e-mail de recuperação foi enviado. Verifique sua caixa de entrada.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); 
                                            Navigator.pop(context); 
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  _isLoading = false;
                                  if (e.code == 'user-not-found') {
                                    _errorMessage = 'Usuário não encontrado. Verifique o e-mail digitado.';
                                  } else if (e.code == 'invalid-email') {
                                    _errorMessage = 'E-mail inválido. Verifique o formato e tente novamente.';
                                  } else {
                                    _errorMessage = 'Erro ao enviar e-mail de recuperação: ${e.message}';
                                  }
                                });
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = 'Erro inesperado: $e';
                                });
                              }
                            }
                          },
                          child: const Text('Próximo Passo'),
                        ),
                      ),

                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

