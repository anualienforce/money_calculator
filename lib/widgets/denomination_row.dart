import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/denomination.dart';

class DenominationRow extends StatefulWidget {
  final Denomination denomination;
  final Function(int) onQuantityChanged;

  const DenominationRow({
    super.key,
    required this.denomination,
    required this.onQuantityChanged,
  });

  @override
  State<DenominationRow> createState() => _DenominationRowState();
}

class _DenominationRowState extends State<DenominationRow> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.denomination.quantity == 0 ? '' : widget.denomination.quantity.toString(),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DenominationRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.denomination.quantity != widget.denomination.quantity) {
      _controller.text = widget.denomination.quantity == 0 ? '' : widget.denomination.quantity.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(String value) {
    final quantity = int.tryParse(value) ?? 0;
    widget.onQuantityChanged(quantity);

    if (quantity > 0) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = widget.denomination.quantity > 0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: hasValue
                ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Denomination chip (₹10, ₹20, etc.)
              SizedBox(
                width: 80, // fixed width for alignment
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasValue
                          ? [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)]
                          : [theme.colorScheme.surfaceContainer, theme.colorScheme.surfaceContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: hasValue
                        ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      widget.denomination.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: hasValue
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Multiplication symbol
              SizedBox(
                width: 20,
                child: Text(
                  '×',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Quantity input field
              SizedBox(
                width: 70, // fixed width so all align
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasValue
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: hasValue ? 2 : 1,
                    ),
                    boxShadow: hasValue
                        ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onChanged: _onQuantityChanged,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Equals symbol
              SizedBox(
                width: 20,
                child: Text(
                  '=',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Total amount
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasValue
                        ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
                        : theme.colorScheme.surfaceContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.denomination.total.toStringAsFixed(
                        widget.denomination.value < 1 ? 2 : 0),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}