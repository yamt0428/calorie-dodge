import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  // テスト広告ID（本番環境では実際の広告IDに置き換えてください）
  // Android
  static const String _androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // iOS
  static const String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';

  /// バナー広告のユニットID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// インタースティシャル広告のユニットID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// AdMobを初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
    
    if (kDebugMode) {
      print('AdMob initialized');
    }
  }

  /// バナー広告を作成
  BannerAd createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
          if (kDebugMode) {
            print('Banner ad failed to load: $error');
          }
        },
      ),
    );
  }

  /// インタースティシャル広告をロード
  Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;
    
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          if (kDebugMode) {
            print('Interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Interstitial ad failed to load: $error');
          }
        },
      ),
    );
    
    return interstitialAd;
  }
}

/// 本番環境用の広告ID設定クラス
/// 実際のAdMobアカウントの広告IDをここに設定してください
class AdConfig {
  // TODO: 本番環境では以下のIDを実際のAdMob広告IDに置き換えてください
  
  // Android広告ID
  static const String androidAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';
  static const String androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String androidInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // iOS広告ID
  static const String iosAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';
  static const String iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String iosInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
}
