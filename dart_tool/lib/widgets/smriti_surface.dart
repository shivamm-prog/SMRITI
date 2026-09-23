import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// A restrained white surface for content which benefits from visual grouping.
/// Most layouts should still use whitespace and dividers before reaching for this.
class SmritiSurface extends StatelessWidget {
  const SmritiSurface({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpace.medium)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: child,
      );
}
