import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:juntaai/screens/forget_passsword_screen.dart';
import 'package:juntaai/screens/home/home_screen.dart';
import 'package:juntaai/screens/signup_screen.dart';
import 'package:juntaai/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String? _errorMessage;

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Bem Vindo',
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            const String emailPattern =
                                r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
                            final RegExp regex = RegExp(emailPattern);
                            if (value == null || value.isEmpty) {
                              return 'Entre com Email';
                            } else if (!regex.hasMatch(value)) {
                              return 'Entre com um Email válido';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entre com a Senha';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Entre com a Senha',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const ForgetPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50.0),
                        SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formSignInKey.currentState!.validate()) {
                                _showLoading();
                                try {
                                  User? user = await _firebaseService.signIn(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                  if (user != null) {
                                    _hideLoading();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (e) => const HomeScreen(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  _hideLoading();
                                  setState(() {
                                    _errorMessage = e.toString();
                                  });
                                }
                              }
                            },
                             style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange, 
                              foregroundColor: Colors.white, 
                            ),
                            child: const Text('Entrar'),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.black38,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('OU'),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: 250,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              _showLoading();
                              try {
                                User? user =
                                    await _firebaseService.signInWithGoogle();
                                if (user != null) {
                                  _hideLoading();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const HomeScreen(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                _hideLoading();
                                setState(() {
                                  _errorMessage = e.toString();
                                  print(_errorMessage);
                                });
                              }
                            },
                            icon: SvgPicture.asset(
                              'assets/logo/googleLogo.svg',
                              height: 20,
                              width: 20,
                            ),
                            label: const Text('Entrar com google'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black54,
                              side: const BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Não tem uma conta? ',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Criar conta',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
