import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String trendValue;
  final bool isTrendUp;
  final Color? baseColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.trendValue,
    required this.isTrendUp,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNeutral = trendValue == '0' || trendValue == '0%';
    
    // Cores adaptativas para a tendência
    final Color trendColor;
    final Color trendBgColor;
    
    if (isNeutral) {
      trendColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
      trendBgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]!;
    } else if (isTrendUp) {
      trendColor = isDark ? Colors.greenAccent[400]! : Colors.green[700]!;
      trendBgColor = isDark ? Colors.greenAccent.withValues(alpha: 0.1) : Colors.green[50]!;
    } else {
      trendColor = isDark ? Colors.redAccent[200]! : Colors.red[700]!;
      trendBgColor = isDark ? Colors.redAccent.withValues(alpha: 0.1) : Colors.red[50]!;
    }

    final trendIcon = isNeutral ? null : (isTrendUp ? Icons.arrow_upward : Icons.arrow_downward);

    final iconColor = baseColor ?? theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      trendValue,
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (trendIcon != null) ...[
                      const SizedBox(width: 2),
                      Icon(trendIcon, color: trendColor, size: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
