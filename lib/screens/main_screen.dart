import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cash_calculator_screen.dart';
import 'help_support_screen.dart';
import 'transactions_screen.dart';
import 'settings_screen.dart';
import '../models/app_settings.dart';
import '../services/data_service.dart';
import '../services/admob_service.dart';
import '../widgets/banner_ad_widget.dart' as ad_widgets;

class MainScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const MainScreen({super.key, required this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late AppSettings settings;
  int _screenChangeCount = 0;
  static const int _interstitialAdInterval = 3;

  late List<Widget> _screens;

  final List<String> _titles = [
    'Cash Calculator',
    'History',
    'Settings',
  ];

  final List<IconData> _icons = [
    Icons.calculate_rounded,
    Icons.history_rounded,
    Icons.settings_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadInterstitialAd();

    _screens = [
      const CashCalculatorScreen(),
      const TransactionsScreen(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];
  }

  void _loadInterstitialAd() {
    InterstitialAdManager.loadInterstitialAd();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      _screenChangeCount++;

      if (_screenChangeCount >= _interstitialAdInterval) {
        InterstitialAdManager.showInterstitialAd();
        _screenChangeCount = 0;
      }

      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final loadedSettings = await DataService.getSettings();
      setState(() {
        settings = loadedSettings;
      });
    } catch (e) {
      setState(() {
        settings = AppSettings();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: theme.colorScheme.primary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: _currentIndex == 0 ? [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: FilledButton.tonal(
              onPressed: () => setState(() => _currentIndex = 1),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 16),
                  const SizedBox(width: 4),
                  const Text('History', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ] : null,
      ),
      drawer: _buildDrawer(),
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
        child: Column(
          children: [
            Expanded(child: _screens[_currentIndex]),
            const ad_widgets.BannerAdWidget(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.calculate_rounded, 0),
                activeIcon: _buildNavIcon(Icons.calculate_rounded, 0, isActive: true),
                label: 'Calculate',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.history_rounded, 1),
                activeIcon: _buildNavIcon(Icons.history_rounded, 1, isActive: true),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.settings_rounded, 2),
                activeIcon: _buildNavIcon(Icons.settings_rounded, 2, isActive: true),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildDrawer() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [theme.colorScheme.surface, theme.colorScheme.surfaceContainer]
                    : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                      ),
                      child: Image.asset("assets/icon/app_icon.png",
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cash Calculator',
                      style: TextStyle(
                        color: isDark ? theme.colorScheme.onSurface : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.calculate_rounded,
                  title: 'Calculate',
                  subtitle: 'Calculate cash denominations',
                  onTap: () => _navigateToScreen(0),
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'History',
                  subtitle: 'View saved calculations',
                  onTap: () => _navigateToScreen(1),
                ),
                _buildDrawerItem(
                  icon: Icons.help_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                    );
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'App preferences and configuration',
                  onTap: () => _navigateToScreen(2),
                ),

                Divider(color: theme.dividerColor),

                _buildDrawerItem(
                  icon: Icons.info_rounded,
                  title: 'About',
                  subtitle: 'App information and version',
                  onTap: () => _showAboutDialog(),
                ),
                _buildDrawerItem(
                  icon: Icons.star_rounded,
                  title: 'Rate App',
                  subtitle: 'Rate us on the app store',
                  onTap: () => _rateApp(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToScreen(int index) {
    if (index != _currentIndex) {
      _screenChangeCount++;

      if (_screenChangeCount >= _interstitialAdInterval) {
        InterstitialAdManager.showInterstitialAd();
        _screenChangeCount = 0;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showComingSoon(String feature) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _rateApp() async {
    const String packageName = 'com.Lts.MoneyCalculator';
    final Uri playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    try {
      if (await canLaunchUrl(playStoreUrl)) {
        await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Play Store: $e')),
      );
    }
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
        const Text('A simple and efficient cash calculation app.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Calculate cash denominations'),
        const Text('• Save and manage transactions'),
        const Text('• Multiple currency support'),
        const Text('• Dark mode support'),
        const Text('• Export and backup data'),
      ],
    );
  }
}