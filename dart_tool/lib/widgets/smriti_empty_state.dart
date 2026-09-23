import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SmritiEmptyState extends StatelessWidget {
  const SmritiEmptyState({super.key, required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(AppSpace.xLarge), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 42, color: AppColors.teal),
    const SizedBox(height: AppSpace.medium),
    Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: AppSpace.xSmall),
    Text(detail, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
  ])));
}
