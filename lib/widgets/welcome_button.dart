import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.color = Colors.white, // Cor padrão
    this.textColor = Colors.black, // Cor do texto padrão
  });

  final String buttonText;
  final VoidCallback onTap; // Define o tipo do callback como VoidCallback
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Executa a função quando o botão é pressionado
      child: Container(
        width: 200.0, // Largura fixa do botão
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0), // Padding uniforme
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30), // Todas as bordas arredondadas
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0, // Tamanho do texto ajustado
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
