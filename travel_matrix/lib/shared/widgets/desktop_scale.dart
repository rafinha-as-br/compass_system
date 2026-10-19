import 'package:flutter/material.dart';
import 'package:travel_matrix/shared/widgets/responsive_layout_builder.dart';

/// Fator de ampliação de texto e ícones em desktop.
const double kDesktopScale = 1.15;

/// Amplia texto e ícones por [kDesktopScale] quando a janela é desktop
/// (largura >= [Breakpoints.desktop]); abaixo disso não altera nada.
///
/// Usa o `textScaler` do [MediaQuery] (alcança também `fontSize` fixos nas telas)
/// e liga `applyTextScaling` nos ícones. Compõe com a escala de texto do sistema.
class DesktopScale extends StatelessWidget {
  final Widget child;

  const DesktopScale({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;
    final scaler = MediaQuery.textScalerOf(context);

    // Estrutura de widgets fixa: trocar a árvore ao cruzar o breakpoint
    // remontaria o app inteiro (perda de estado) ao redimensionar a janela.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: isDesktop
            ? TextScaler.linear(scaler.scale(1) * kDesktopScale)
            : scaler,
      ),
      child: IconTheme.merge(
        data: IconThemeData(applyTextScaling: isDesktop ? true : null),
        child: child,
      ),
    );
  }
}
