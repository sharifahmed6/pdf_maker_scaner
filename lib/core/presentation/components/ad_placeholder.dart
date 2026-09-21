import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdPlaceholder extends StatelessWidget {
  final double height;
  final String label;

  const AdPlaceholder({
    super.key,
    this.height = 60,
    this.label = 'Banner Ad Placeholder',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}
