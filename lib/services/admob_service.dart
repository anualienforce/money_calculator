import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  static bool _isInitialized = false;
  static bool adsRemoved = false; // This will be managed by in-app purchase later

  // Test Ad Unit IDs (Android only)
  static String get bannerAdUnitId {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test banner
  }

  static String get interstitialAdUnitId {

      return 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial

  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  static bool get shouldShowAds => !adsRemoved;

  static void removeAds() {
    adsRemoved = true;
  }

  static void restoreAds() {
    adsRemoved = false;
  }
}

class BannerAdWidget {
  static BannerAd? _bannerAd;
  static bool _isLoaded = false;

  static BannerAd? createBannerAd() {
    if (!AdMobService.shouldShowAds) return null;

    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isLoaded = false;
          ad.dispose();
        },
      ),
    );
    return _bannerAd;
  }

  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  static bool get isLoaded => _isLoaded;
}

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isLoaded = false;
  static int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  static Future<void> loadInterstitialAd() async {
    if (!AdMobService.shouldShowAds) return;

    await InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _isLoaded = true;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          _isLoaded = false;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (!AdMobService.shouldShowAds || !_isLoaded || _interstitialAd == null) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
    _isLoaded = false;
  }

  static bool get isLoaded => _isLoaded;

  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoaded = false;
  }
}
