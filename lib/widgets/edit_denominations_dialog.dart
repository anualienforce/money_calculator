import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/denomination.dart';
import '../services/currency_service.dart';

class EditDenominationsDialog extends StatefulWidget {
  final List<Denomination> denominations;
  final String currentCurrency;

  const EditDenominationsDialog({
    super.key,
    required this.denominations,
    this.currentCurrency = 'INR',
  });

  @override
  State<EditDenominationsDialog> createState() => _EditDenominationsDialogState();
}

class _EditDenominationsDialogState extends State<EditDenominationsDialog> {
  late List<Denomination> editedDenominations;
  late String selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.currentCurrency;
    editedDenominations = widget.denominations
        .map((d) => d.copyWith())
        .toList();
  }

  void _resetToDefault() {
    setState(() {
      editedDenominations = CurrencyService.getDenominations(selectedCurrency);
    });
  }

  void _addCustomDenomination() {
    final valueController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Denomination'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Value',
                prefixText: CurrencyService.getCurrency(selectedCurrency).symbol,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., 25, 75, Custom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(valueController.text);
              final label = labelController.text.trim();

              if (value != null && value > 0 && label.isNotEmpty) {
                setState(() {
                  editedDenominations.add(
                    Denomination(
                      value: value,
                      label: label,
                      currencySymbol: CurrencyService.getCurrency(selectedCurrency).symbol,
                    ),
                  );
                  // Sort by value descending
                  editedDenominations.sort((a, b) => b.value.compareTo(a.value));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeDenomination(int index) {
    setState(() {
      editedDenominations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Calculate responsive dimensions
    final screenWidth = mediaQuery.size.width;
    final dialogWidth = screenWidth * 0.9; // 90% of screen width
    final maxDialogWidth = 500.0; // Maximum width constraint
    final isNarrowScreen = screenWidth < 400;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Denominations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyService.getCurrency(selectedCurrency).name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth.clamp(300.0, maxDialogWidth),
        height: mediaQuery.size.height * 0.7, // 70% of screen height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Controls Row - Conditional layout based on screen width
            isNarrowScreen
                ? Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _resetToDefault,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset to Default'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addCustomDenomination,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Custom'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetToDefault,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset to Default'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _addCustomDenomination,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Custom'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Denominations List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: editedDenominations.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    final denomination = editedDenominations[index];
                    return _DenominationItem(
                      denomination: denomination,
                      theme: theme,
                      onRemove: () => _removeDenomination(index),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap "Reset to Default" to restore standard denominations for ${CurrencyService.getCurrency(selectedCurrency).name}.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(editedDenominations),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Apply Changes'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }
}

// Extracted denomination item widget
class _DenominationItem extends StatelessWidget {
  final Denomination denomination;
  final ThemeData theme;
  final VoidCallback onRemove;

  const _DenominationItem({
    required this.denomination,
    required this.theme,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Drag Handle
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.drag_indicator_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),

          const SizedBox(width: 12),

          // Denomination Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency Symbol & Value
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${denomination.currencySymbol}${denomination.label}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Value Details
                  Text(
                    'Value: ${denomination.value.toStringAsFixed(denomination.value < 1 ? 2 : 0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (denomination.value != double.tryParse(denomination.label))
                    Text(
                      'Label: ${denomination.label}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Delete Button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
              foregroundColor: theme.colorScheme.error,
            ),
            tooltip: 'Remove denomination',
          ),
        ],
      ),
    );
  }
}