import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ActionButtons({
    super.key,
    required this.onClear,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (theme.brightness == Brightness.dark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            'CLEAR',
            AppTheme.warning,
            Icons.clear_rounded,
            onClear,
          ),
          _buildActionButton(
            context,
            'SAVE',
            AppTheme.success,
            Icons.save_rounded,
            onSave,
          ),
          _buildActionButton(
            context,
            'SHARE',
            AppTheme.info,
            Icons.share_rounded,
            onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String text,
      Color color,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            shadowColor: color.withOpacity(0.3),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}