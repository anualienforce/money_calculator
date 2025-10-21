import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.background,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
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
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.help_center_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How can we help you?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions below',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FAQs Section
            _buildSectionHeader('Frequently Asked Questions', Icons.quiz_rounded),
            const SizedBox(height: 12),

            _buildFAQCard(
              0,
              'How do I calculate cash denominations?',
              'Simply enter the quantity of each denomination in the calculator screen. The app will automatically calculate the total amount for you. You can also add online/digital payment amounts.',
              Icons.calculate_rounded,
            ),

            _buildFAQCard(
              1,
              'How do I save my calculations?',
              'After entering your denominations, tap the "Save" button at the bottom. You can add a title and notes to your transaction. Enable "Auto Save" in settings for automatic saving.',
              Icons.save_rounded,
            ),

            _buildFAQCard(
              2,
              'How can I change the currency?',
              'Go to Settings → Currency & Regional section. You can select from multiple currencies including INR, USD, EUR, GBP, JPY, and RUB. Your denomination values will update automatically.',
              Icons.monetization_on_rounded,
            ),

            _buildFAQCard(
              3,
              'What is Auto Save feature?',
              'When enabled in Settings, Auto Save automatically saves your calculations as you work. It helps prevent data loss if you accidentally close the app.',
              Icons.cloud_sync_rounded,
            ),

            _buildFAQCard(
              4,
              'How do I edit denominations?',
              'Tap the edit icon (✏️) next to the currency selector on the calculator screen. You can add custom denominations, remove existing ones, or reset to default values for your selected currency.',
              Icons.edit_rounded,
            ),

            _buildFAQCard(
              5,
              'How do I view transaction history?',
              'Navigate to the History tab from the bottom navigation bar. Here you can view all your saved transactions, search through them, and sort by date, amount, or title.',
              Icons.history_rounded,
            ),

            _buildFAQCard(
              6,
              'How does Dark Mode work?',
              'Go to Settings → Appearance and toggle between Light and Dark themes. The app uses your selected theme across all screens for a consistent experience.',
              Icons.dark_mode_rounded,
            ),

            _buildFAQCard(
              7,
              'What is "Amount in Words" feature?',
              'This feature displays your total amount in written form (e.g., "Five Thousand Rupees Only"). You can enable/disable it in Settings → Appearance → Show Amount in Words.',
              Icons.text_fields_rounded,
            ),

            _buildFAQCard(
              8,
              'How do I delete a saved transaction?',
              'Go to History tab, tap on any transaction card, and then tap the delete icon. You\'ll be asked to confirm before deletion to prevent accidental data loss.',
              Icons.delete_rounded,
            ),

            _buildFAQCard(
              9,
              'Can I view transaction details?',
              'Yes! In the History tab, tap on any transaction card to view detailed breakdown including denomination-wise quantities, cash vs online amounts, notes, and timestamps.',
              Icons.info_rounded,
            ),

            _buildFAQCard(
              10,
              'How do I clear all data?',
              'Go to Settings → Data Management → Clear All Data. Note: This will permanently delete all your saved transactions and cannot be undone, so use with caution.',
              Icons.cleaning_services_rounded,
            ),

            _buildFAQCard(
              11,
              'Does the app work offline?',
              'Yes! The Cash Calculator works completely offline. All your data is stored locally on your device, ensuring privacy and allowing you to use the app without an internet connection.',
              Icons.cloud_off_rounded,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
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
    );
  }

  Widget _buildFAQCard(int index, String question, String answer, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}