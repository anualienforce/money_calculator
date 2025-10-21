import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/denomination.dart';
import '../models/transaction.dart';
import '../models/app_settings.dart';
import '../services/data_service.dart';
import '../services/admob_service.dart';
import '../services/currency_service.dart';
import '../widgets/denomination_row.dart';
import '../widgets/total_section.dart';
import '../widgets/action_buttons.dart';
import '../widgets/save_transaction_dialog.dart';
import '../widgets/edit_denominations_dialog.dart';
import '../utils/amount_in_words.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class CashCalculatorScreen extends StatefulWidget {
  const CashCalculatorScreen({super.key});

  @override
  State<CashCalculatorScreen> createState() => _CashCalculatorScreenState();
}

class _CashCalculatorScreenState extends State<CashCalculatorScreen> with TickerProviderStateMixin {
  List<Denomination> denominations = [];
  AppSettings? settings;
  String currentCurrency = 'INR';
  double onlineAmount = 0.0;
  int totalQuantity = 0;
  double totalAmount = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoadingSettings = true;

  // Auto-save related
  Timer? _autoSaveTimer;
  String? _lastAutoSaveId;
  DateTime? _lastAutoSaveTime;
  // New: Debounce timer for scheduling the save operation
  Timer? _debounceTimer;
  // ⬅️ CHANGE THIS VALUE: Set to 10 seconds (or any other value you want)
  static const int _debounceDurationSeconds = 10;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndInitialize();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel(); // Cancel debounce timer on dispose
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettingsAndInitialize() async {
    try {
      final loadedSettings = await DataService.getSettings();
      setState(() {
        settings = loadedSettings;
        currentCurrency = _getCurrencyFromSymbol(loadedSettings.currencySymbol);
        _initializeDenominations();
        isLoadingSettings = false;
        _updateTotals();
      });
    } catch (e) {
      setState(() {
        settings = AppSettings();
        currentCurrency = 'INR';
        _initializeDenominations();
        isLoadingSettings = false;
        _updateTotals();
      });
    }
  }

  String _getCurrencyFromSymbol(String symbol) {
    switch (symbol) {
      case '\$': return 'USD';
      case '€': return 'EUR';
      case '£': return 'GBP';
      case '¥': return 'JPY';
      case '₽': return 'RUB';
      case '₹':
      default:
        return 'INR';
    }
  }

  void _initializeDenominations() {
    denominations = CurrencyService.getDenominations(currentCurrency);
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      denominations[index].quantity = quantity;
      _updateTotals();
      _scheduleAutoSaveWithDebounce();
    });
  }

  void _updateOnlineAmount(double amount) {
    setState(() {
      onlineAmount = amount;
      _updateTotals();
      _scheduleAutoSaveWithDebounce();
    });
  }

  void _updateTotals() {
    totalQuantity = denominations.fold(0, (sum, denom) => sum + denom.quantity);
    totalAmount = denominations.fold(0.0, (sum, denom) => sum + denom.total) + onlineAmount;
  }

  // Auto-save logic
  void _scheduleAutoSaveWithDebounce() {
    if (settings?.autoSave != true || totalAmount == 0) {
      _debounceTimer?.cancel();
      return;
    }

    // Cancel the existing timer upon any new input
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Start a new timer for the longer duration
    _debounceTimer = Timer(const Duration(seconds: _debounceDurationSeconds), () {
      _performAutoSave();
    });
  }

  Future<void> _performAutoSave() async {
    if (settings?.autoSave != true || totalAmount == 0) return;

    try {
      // Check if we should update existing auto-save or create new one
      final now = DateTime.now();
      final shouldCreateNew = _lastAutoSaveId == null ||
          _lastAutoSaveTime == null ||
          now.difference(_lastAutoSaveTime!).inMinutes > 5;

      final transaction = Transaction(
        id: shouldCreateNew ? DateTime.now().millisecondsSinceEpoch.toString() : _lastAutoSaveId!,
        title: 'Auto-saved ${CurrencyService.getCurrency(currentCurrency).code}',
        denominations: denominations.map((d) => d.copy()).toList(),
        onlineAmount: onlineAmount,
        totalAmount: totalAmount,
        timestamp: now,
        notes: 'Automatically saved calculation',
        currencySymbol: CurrencyService.getCurrency(currentCurrency).symbol,
        currencyCode: currentCurrency,
      );

      if (shouldCreateNew) {
        await DataService.saveTransaction(transaction);
        _lastAutoSaveId = transaction.id;
      } else {
        // Update existing auto-save
        await DataService.deleteTransaction(_lastAutoSaveId!);
        await DataService.saveTransaction(transaction);
      }

      _lastAutoSaveTime = now;

      // Show subtle feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_done_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text('Auto-saved', style: TextStyle(fontSize: 13)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Silent fail for auto-save
      debugPrint('Auto-save error: $e');
    }
  }

  void _clearAll() {
    setState(() {
      for (var denom in denominations) {
        denom.quantity = 0;
      }
      onlineAmount = 0.0;
      _updateTotals();
      _lastAutoSaveId = null;
      _lastAutoSaveTime = null;
      _autoSaveTimer?.cancel();
    });

    HapticFeedback.lightImpact();
    _animationController.reset();
    _animationController.forward();
  }

  void _saveCalculation() async {
    if (totalAmount == 0) {
      _showSnackBar('No amount to save', isError: true);
      return;
    }

    final transaction = await showDialog<Transaction>(
      context: context,
      builder: (context) => SaveTransactionDialog(
        denominations: denominations,
        onlineAmount: onlineAmount,
        totalAmount: totalAmount,
        currencySymbol: CurrencyService.getCurrency(currentCurrency).symbol,
      ),
    );

    if (transaction != null) {
      try {
        // If there's an auto-save, delete it since we're doing a manual save
        if (_lastAutoSaveId != null) {
          await DataService.deleteTransaction(_lastAutoSaveId!);
          _lastAutoSaveId = null;
          _lastAutoSaveTime = null;
        }

        await DataService.saveTransaction(transaction);
        _showSnackBar('Transaction saved successfully!');
        HapticFeedback.heavyImpact();
        InterstitialAdManager.showInterstitialAd();
      } catch (e) {
        _showSnackBar('Error saving transaction: $e', isError: true);
      }
    }
  }

  void _shareCalculation() {
    _showSnackBar('Share functionality coming soon!');
  }

  void _editDenominations() async {
    final result = await showDialog<List<Denomination>>(
      context: context,
      builder: (context) => EditDenominationsDialog(
        denominations: denominations,
        currentCurrency: currentCurrency,
      ),
    );

    if (result != null) {
      setState(() {
        denominations = result;
        _updateTotals();
        _scheduleAutoSaveWithDebounce();
      });
    }
  }

  void _changeCurrency() async {
    final currencies = CurrencyService.getAllCurrencies();
    final selectedCurrency = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final isSelected = currentCurrency == currency.code;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currency.symbol,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(currency.name),
                  subtitle: Text(currency.code),
                  selected: isSelected,
                  onTap: () => Navigator.pop(context, currency.code),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedCurrency != null && selectedCurrency != currentCurrency) {
      setState(() {
        currentCurrency = selectedCurrency;
        _initializeDenominations();
        _updateTotals();
        _lastAutoSaveId = null;
        _lastAutoSaveTime = null;
      });

      if (settings != null) {
        final updatedSettings = settings!.copyWith(
          currencySymbol: CurrencyService.getCurrency(currentCurrency).symbol,
        );
        await DataService.saveSettings(updatedSettings);
        setState(() {
          settings = updatedSettings;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getAmountInWords() {
    if (settings?.showAmountInWords == false) {
      return 'Amount in words disabled in settings';
    }
    return CurrencyService.formatAmountInWords(totalAmount, currentCurrency);
  }

  String _formatAmount(double amount) {
    return CurrencyService.formatAmount(amount, currentCurrency);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoadingSettings) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading calculator...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Auto-save indicator
              if (settings?.autoSave == true && totalAmount > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_sync_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Auto-save enabled',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Currency selection and amount in words section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [theme.colorScheme.surfaceContainer, theme.colorScheme.surface]
                        : [theme.colorScheme.primaryContainer.withOpacity(0.1), theme.colorScheme.surface],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            CurrencyService.getCurrency(currentCurrency).symbol,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyService.getCurrency(currentCurrency).name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Total: ${_formatAmount(totalAmount)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: _changeCurrency,
                          icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                          ),
                          tooltip: 'Change Currency',
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _editDenominations,
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                          ),
                          tooltip: 'Edit Denominations',
                        ),
                      ],
                    ),
                    if (settings?.showAmountInWords != false) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.text_fields_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Amount in Words',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getAmountInWords(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Denominations section
              Container(
                height: 450,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Denominations (${CurrencyService.getCurrency(currentCurrency).code})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Value × Qty = Total',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: denominations.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: theme.dividerColor.withOpacity(0.5),
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          return DenominationRow(
                            denomination: denominations[index],
                            onQuantityChanged: (quantity) => _updateQuantity(index, quantity),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              TotalSection(
                totalQuantity: totalQuantity,
                totalAmount: totalAmount,
                onlineAmount: onlineAmount,
                onOnlineAmountChanged: _updateOnlineAmount,
                currencySymbol: CurrencyService.getCurrency(currentCurrency).symbol,
              ),

              const SizedBox(height: 16),

              ActionButtons(
                onClear: _clearAll,
                onSave: _saveCalculation,
                onShare: _shareCalculation,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}