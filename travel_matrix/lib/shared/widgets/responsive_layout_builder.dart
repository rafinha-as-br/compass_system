import 'package:flutter/widgets.dart';

/// Breakpoints oficiais do Travel Matrix (largura disponível, em px).
abstract final class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
}

enum ScreenSize {
  mobile,
  tablet,
  desktop;

  static ScreenSize fromWidth(double width) {
    if (width >= Breakpoints.desktop) return desktop;
    if (width >= Breakpoints.tablet) return tablet;
    return mobile;
  }
}

/// Escolhe o layout pela largura disponível no ponto de uso (constraints do
/// widget, não a janela inteira). [tablet] é opcional e cai para [mobile].
class ResponsiveLayoutBuilder extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (ScreenSize.fromWidth(constraints.maxWidth)) {
          ScreenSize.desktop => desktop(context),
          ScreenSize.tablet => (tablet ?? mobile)(context),
          ScreenSize.mobile => mobile(context),
        };
      },
    );
  }
}
