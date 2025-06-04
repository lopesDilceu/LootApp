import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importe o pacote SVG
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/splash_controller.dart'; // Seu controller

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("[SplashScreen] build() chamado.");

    const double logoSize = 100.0; // Defina o tamanho do seu logo
    const double spinnerSize =
        logoSize + 40.0; // Spinner um pouco maior que o logo
    const double spinnerStrokeWidth = 3.0;

    return Scaffold(
      // Defina uma cor de fundo se desejar, ex: Theme.of(context).scaffoldBackgroundColor
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Seu Logo SVG
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: SvgPicture.asset(
                    'assets/images/logos/logo-binoculars-text-light.svg', // <<< CAMINHO PARA SEU ARQUIVO SVG
                    width: logoSize,
                    height: logoSize,
                    semanticsLabel: 'Logo do Loot App',
                    // Opcional: se seu SVG precisar de uma cor específica e não tiver cor própria
                    // colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                  ),
                ),
                // CircularProgressIndicator ao redor
                SizedBox(
                  width: spinnerSize,
                  height: spinnerSize,
                  child: CircularProgressIndicator(
                    strokeWidth: spinnerStrokeWidth,
                    // Opcional: defina a cor do spinner
                    // valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Carregando Loot...",
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
