import 'package:flutter/material.dart';

/// Loading placeholder block/line — no spinner. Screens compose one or more
/// of these to sketch the shape of the content that's still loading.
///
/// ponytail: static block, no shimmer animation. Add one if the plain block
/// reads as broken UI rather than "loading" once it's in front of real users.
class SkeletonBlock extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const SkeletonBlock({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: borderRadius,
      ),
    );
  }
}
