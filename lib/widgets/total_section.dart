import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TotalSection extends StatefulWidget {
  final int totalQuantity;
  final double totalAmount;
  final double onlineAmount;
  final Function(double) onOnlineAmountChanged;
  final String currencySymbol;

  const TotalSection({
    super.key,
    required this.totalQuantity,
    required this.totalAmount,
    required this.onlineAmount,
    required this.onOnlineAmountChanged,
    this.currencySymbol = '₹',
  });

  @override
  State<TotalSection> createState() => _TotalSectionState();
}

class _TotalSectionState extends State<TotalSection> with SingleTickerProviderStateMixin {
  late TextEditingController _onlineController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _onlineController = TextEditingController(
      text: widget.onlineAmount == 0 ? '' : widget.onlineAmount.toStringAsFixed(2),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TotalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onlineAmount != widget.onlineAmount && widget.onlineAmount == 0) {
      _onlineController.clear();
    }

    // Trigger pulse animation when total changes
    if (oldWidget.totalAmount != widget.totalAmount && widget.totalAmount > 0) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _onlineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onOnlineAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    widget.onOnlineAmountChanged(amount);
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) { // 1 Crore
      return '${widget.currencySymbol}${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) { // 1 Lakh
      return '${widget.currencySymbol}${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) { // 1 Thousand
      return '${widget.currencySymbol}${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    } else {
      return '${widget.currencySymbol}${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
    }
  }

  String _formatFullCurrency(double amount) {
    return '${widget.currencySymbol}${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cashAmount = widget.totalAmount - widget.onlineAmount;
    final hasOnlineAmount = widget.onlineAmount > 0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.secondaryContainer.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Total Summary',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Cash Amount Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.payments_rounded,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Amount',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${widget.totalQuantity} notes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(cashAmount),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (cashAmount >= 1000)
                          Text(
                            _formatFullCurrency(cashAmount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Online Amount Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasOnlineAmount
                      ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
                      : theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasOnlineAmount
                        ? theme.colorScheme.secondary.withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.2),
                    width: hasOnlineAmount ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasOnlineAmount
                            ? theme.colorScheme.secondaryContainer
                            : theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: hasOnlineAmount
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Online Amount',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: TextField(
                              controller: _onlineController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: hasOnlineAmount
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter online amount',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                                prefixText: widget.currencySymbol,
                                prefixStyle: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onChanged: _onOnlineAmountChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total Amount (Grand Total)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grand Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(widget.totalAmount),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (widget.totalAmount >= 1000)
                            Text(
                              _formatFullCurrency(widget.totalAmount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}