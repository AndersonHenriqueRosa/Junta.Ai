import 'package:flutter/material.dart';
import 'package:juntaai/screens/signin_screen.dart';
import 'package:juntaai/screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100, // Fundo claro
      body: Center( // Centraliza todo o conteúdo
        child: Column(
          mainAxisSize: MainAxisSize.min, // Isso permite que a coluna ocupe o espaço necessário
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza os itens verticalmente
          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
          children: [
            // Ícone do logo
            Icon(
              Icons.show_chart,
              size: 100, // Tamanho menor para aproximar mais dos textos
              color: Colors.black,
            ),
            
            const SizedBox(height: 20), // Espaço entre o ícone e o texto "Junta.AI"
            
            // Texto "Junta.AI"
            const Text(
              'Junta.AI',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Subtítulo
            const Text(
              'Sua plataforma de finanças!',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 40), // Espaço entre o subtítulo e os botões
            
            // Botão "Entrar"
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              },
              child: Container(
                width: 250.0,
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                decoration: BoxDecoration(
                  color: Colors.orange, // Cor de fundo laranja
                  borderRadius: BorderRadius.circular(30.0), // Bordas arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Cor do texto
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 10), // Espaço entre os botões
            
            // Botão "Criar Conta"
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
              child: Container(
                width: 250.0,
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Cor de fundo verde claro
                  borderRadius: BorderRadius.circular(30.0), // Bordas arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Criar Conta',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Cor do texto
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
