import 'package:flutter/material.dart';

class LoadingCardWidget extends StatelessWidget {
  final double height;
  final double width;

  const LoadingCardWidget({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Color.fromARGB(50, 150, 150, 150),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // "Sombra" com Gradiente animado para simular a luz
          Positioned.fill(
            child: ClipRect( // ClipRect limita a área do gradiente para os limites do card
              child: AnimatedGradient(
                width: width,
                height: height,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradient extends StatefulWidget {
  final double width;
  final double height;

  const AnimatedGradient({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  _AnimatedGradientState createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient>
    with TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,  // 'this' agora é um TickerProvider, pois a classe implementa TickerProviderStateMixin
    )..repeat(reverse: true); // Repetir animação

    _animation = Tween<Offset>(
      begin: Offset(-1.0, 0), // Começar fora da tela
      end: Offset(1.0, 0),    // Terminar no final da tela
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        width: widget.width,  // Definindo a largura do gradiente
        height: widget.height,  // Definindo a altura do gradiente
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              const Color.fromARGB(255, 121, 121, 121).withOpacity(0.2),
              Colors.transparent,
            ],
            stops: [0.3, 0.5, 0.7],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
