import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/data_service.dart';
import '../services/admob_service.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(String)? onCurrencyChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    this.onCurrencyChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AppSettings settings;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final loadedSettings = await DataService.getSettings();
      setState(() {
        settings = loadedSettings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        settings = AppSettings();
        isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await DataService.saveSettings(settings);
      widget.onThemeChanged(settings.isDarkMode);
      if (widget.onCurrencyChanged != null) {
        widget.onCurrencyChanged!(settings.currencySymbol);
      }
      _showSnackBar('Settings saved successfully!');
      InterstitialAdManager.showInterstitialAd();
    } catch (e) {
      _showSnackBar('Error saving settings: $e', isError: true);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading settings...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Column(
          children: [
            // Save button header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save Settings'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Theme Settings
                  _buildSectionCard(
                    'Appearance',
                    Icons.palette_rounded,
                    [
                      _buildThemeSelector(),
                      const SizedBox(height: 8),
                      _buildSwitchTile(
                        'Show Amount in Words',
                        'Display total amount in words',
                        settings.showAmountInWords,
                            (value) => setState(() {
                          settings = settings.copyWith(showAmountInWords: value);
                        }),
                        Icons.text_fields_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Currency Settings - Enhanced
                  _buildSectionCard(
                    'Currency & Regional',
                    Icons.public_rounded,
                    [
                      _buildAdvancedCurrencySelector(),
                      const SizedBox(height: 12),
                      // _buildListTile(
                      //   'Regional Format',
                      //   'Number formatting: ${_getRegionalFormat()}',
                      //   Icons.format_list_numbered_rounded,
                      //       () => _showRegionalFormatDialog(),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // App Settings
                  _buildSectionCard(
                    'App Preferences',
                    Icons.settings_rounded,
                    [
                      _buildSwitchTile(
                        'Auto Save',
                        'Automatically save calculations',
                        settings.autoSave,
                            (value) => setState(() {
                          settings = settings.copyWith(autoSave: value);
                        }),
                        Icons.save_rounded,
                      ),
                      // _buildSwitchTile(
                      //   'Haptic Feedback',
                      //   'Vibration feedback on interactions',
                      //   settings.hapticFeedback ?? true,
                      //       (value) => setState(() {
                      //     settings = settings.copyWith(hapticFeedback: value);
                      //   }),
                      //   Icons.vibration_rounded,
                      // ),
                      _buildListTile(
                        'Language',
                        'English (More languages coming soon)',
                        Icons.language_rounded,
                            () => _showLanguageDialog(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Premium Features
                  _buildSectionCard(
                    'Premium',
                    Icons.diamond_rounded,
                    [
                      _buildListTile(
                        'Remove Ads',
                        'Enjoy ad-free experience',
                        Icons.block_rounded,
                            () => _showRemoveAdsDialog(),
                        isPremium: true,
                      ),
                      // _buildListTile(
                      //   'Advanced Features',
                      //   'Currency conversion, export formats & more',
                      //   Icons.star_rounded,
                      //       () => _showAdvancedFeaturesDialog(),
                      //   isPremium: true,
                      // ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Data Management
                  _buildSectionCard(
                    'Data Management',
                    Icons.storage_rounded,
                    [
                      _buildListTile(
                        'Clear All Data',
                        'Delete all transactions',
                        Icons.delete_forever_rounded,
                            () => _clearAllData(),
                        isDestructive: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // About Section
                  _buildSectionCard(
                    'About',
                    Icons.info_rounded,
                    [
                      _buildListTile(
                        'App Information',
                        'Version 1.0.0',
                        Icons.info_outline_rounded,
                            () => _showAboutDialog(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData titleIcon, List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    titleIcon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedCurrencySelector() {
    final theme = Theme.of(context);
    final currencies = CurrencyService.getAllCurrencies();
    final currentCurrency = currencies.firstWhere(
          (c) => c.symbol == settings.currencySymbol,
      orElse: () => currencies.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Currency',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Active: ${currentCurrency.code}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              // Current currency display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          currentCurrency.symbol,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentCurrency.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${currentCurrency.code} • ${currentCurrency.denominations.length} denominations',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showCurrencySelectionDialog(),
                      icon: const Icon(Icons.edit_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Quick currency options
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currencies.take(6).map((currency) {
                    final isSelected = settings.currencySymbol == currency.symbol;
                    return GestureDetector(
                      onTap: () => setState(() {
                        settings = settings.copyWith(currencySymbol: currency.symbol);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currency.symbol,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currency.code,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a currency and click "Save Settings" to apply changes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // String _getRegionalFormat() {
  //   switch (settings.currencySymbol) {
  //     case '₹': return 'Indian (1,23,456.78)';
  //     case '\$': return 'US (123,456.78)';
  //     case '€': return 'European (123.456,78)';
  //     default: return 'Standard (123,456.78)';
  //   }
  // }

  void _showCurrencySelectionDialog() {
    final currencies = CurrencyService.getAllCurrencies();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final isSelected = settings.currencySymbol == currency.symbol;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currency.symbol,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  title: Text(
                    currency.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('${currency.code} • ${currency.denominations.length} denominations'),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      settings = settings.copyWith(currencySymbol: currency.symbol);
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRegionalFormatDialog() {
    _showSnackBar('Regional formatting options coming in next update!');
  }

  // void _showAdvancedFeaturesDialog() {
  //   final theme = Theme.of(context);
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(4),
  //             decoration: BoxDecoration(
  //               color: Colors.amber,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
  //           ),
  //           const SizedBox(width: 8),
  //           const Text('Advanced Features'),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 colors: [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //               ),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Coming Soon!',
  //                   style: theme.textTheme.titleMedium?.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.amber[700],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 const Text('Advanced features are in development.'),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           const Text(
  //             'Advanced features will include:',
  //             style: TextStyle(fontWeight: FontWeight.w600),
  //           ),
  //           const SizedBox(height: 12),
  //           _buildFeatureItem('Real-time currency conversion'),
  //           _buildFeatureItem('Multiple export formats (PDF, Excel)'),
  //           _buildFeatureItem('Transaction categories & tags'),
  //           _buildFeatureItem('Advanced reporting & analytics'),
  //           _buildFeatureItem('Custom denomination sets'),
  //           _buildFeatureItem('Bulk transaction operations'),
  //         ],
  //       ),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Got it'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildThemeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      settings = settings.copyWith(isDarkMode: false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: !settings.isDarkMode
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.light_mode_rounded,
                          color: !settings.isDarkMode
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Light',
                          style: TextStyle(
                            color: !settings.isDarkMode
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      settings = settings.copyWith(isDarkMode: true);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: settings.isDarkMode
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dark_mode_rounded,
                          color: settings.isDarkMode
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dark',
                          style: TextStyle(
                            color: settings.isDarkMode
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      IconData icon,
      ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
        ),
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 18,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildListTile(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
        bool isPremium = false,
      }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.error.withOpacity(0.1)
                : isPremium
                ? Colors.amber.withOpacity(0.1)
                : theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? AppTheme.error
                : isPremium
                ? Colors.amber[700]
                : theme.colorScheme.primary,
            size: 18,
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDestructive ? AppTheme.error : null,
              ),
            ),
            if (isPremium) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDestructive
                ? AppTheme.error.withOpacity(0.7)
                : null,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageTile('English', 'en', Icons.language_rounded),
            _buildLanguageTile('Spanish (Coming Soon)', 'es', Icons.language_rounded, isDisabled: true),
            _buildLanguageTile('French (Coming Soon)', 'fr', Icons.language_rounded, isDisabled: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(String title, String code, IconData icon, {bool isDisabled = false}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isDisabled ? theme.disabledColor : theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isDisabled ? theme.disabledColor : null,
        ),
      ),
      onTap: isDisabled ? null : () {
        setState(() {
          settings = settings.copyWith(language: code);
        });
        Navigator.pop(context);
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Cash Calculator',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.calculate_rounded,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: [
        const Text('A comprehensive cash calculation app with multi-currency support.'),
        const SizedBox(height: 16),
        const Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('• Multi-currency calculations'),
        const Text('• Save and manage transactions'),
        const Text('• Export data functionality'),
        const Text('• Customizable denominations'),
        const Text('• Dark and light themes'),
        const Text('• Amount in words conversion'),
      ],
    );
  }

  void _exportData() {
    _showSnackBar('Export feature coming soon!');
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.error),
            const SizedBox(width: 8),
            const Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your transactions. This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Clear all transactions by saving an empty list
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('transactions');

                _showSnackBar('All data cleared successfully');
                InterstitialAdManager.showInterstitialAd();
              } catch (e) {
                _showSnackBar('Error clearing data: $e', isError: true);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showRemoveAdsDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('Premium Features'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coming Soon!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('We\'re working on bringing you premium features.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Premium features will include:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('No advertisements'),
            _buildFeatureItem('Advanced analytics'),
            _buildFeatureItem('Cloud backup & sync'),
            _buildFeatureItem('Priority customer support'),
            _buildFeatureItem('Exclusive themes'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}