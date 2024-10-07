import 'package:flutter/material.dart';
import 'package:juntaai/screens/signin_screen.dart';
import 'package:juntaai/screens/signup_screen.dart';
import 'package:juntaai/widgets/custom_scaffold.dart';
import 'package:juntaai/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      backgroundColor: Colors.orange,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
        children: [
          Expanded(
            flex: 1, // Ajuste o espaço para o texto
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Junta.AI\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10), // Reduzido para diminuir o espaço entre o texto e os botões
          Expanded(
            flex: 1, // Ajuste o espaço para os botões
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões verticalmente
              children: [
                WelcomeButton(
                  buttonText: 'Entrar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(), // Navega para a tela de login
                      ),
                    );
                  },
                ),
                SizedBox(height: 10), // Espaçamento entre os botões
                WelcomeButton(
                  buttonText: 'Criar Conta',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpScreen(), // Navega para a tela de cadastro
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
