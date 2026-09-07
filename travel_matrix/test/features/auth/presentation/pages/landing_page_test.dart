import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/auth/presentation/pages/landing_page.dart';

void main() {
  group('computeBannerLayout', () {
    test('em janelas largas, usa o padding e a largura máximos', () {
      final layout = computeBannerLayout(const Size(1600, 900));

      expect(layout.padding, const EdgeInsets.symmetric(horizontal: 230, vertical: 162));
      expect(layout.logoWidth, 400);
    });

    test('em janelas estreitas, reduz padding e logo sem estourar o espaço disponível', () {
      const availableSize = Size(900, 700);

      final layout = computeBannerLayout(availableSize);

      final totalWidthUsed = layout.padding.horizontal + layout.logoWidth;
      expect(totalWidthUsed, lessThanOrEqualTo(availableSize.width));
      expect(layout.padding.horizontal, greaterThanOrEqualTo(24 * 2));
      expect(layout.logoWidth, greaterThanOrEqualTo(120));
    });

    test('nunca deixa o padding ou a logo abaixo do mínimo, mesmo em janelas minúsculas', () {
      final layout = computeBannerLayout(const Size(100, 100));

      expect(layout.padding, const EdgeInsets.symmetric(horizontal: 24, vertical: 24));
      expect(layout.logoWidth, 120);
    });
  });
}
