import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

/// Meta SDK (Facebook App Events) を利用したアナリティクスサービス
/// Instagram広告の最適化やコンバージョントラッキングに使用
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();
  bool _isInitialized = false;

  /// アナリティクスを初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 広告トラッキングを有効化（ユーザーの同意を得た上で）
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      
      // 自動ログ収集を有効化
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('Facebook App Events initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Facebook App Events: $e');
      }
    }
  }

  /// アプリ起動イベントをログ
  Future<void> logAppOpen() async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'app_open',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log app open: $e');
      }
    }
  }

  /// カロリー記録イベントをログ
  Future<void> logCalorieRecord({
    required int calories,
    String? memo,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'calorie_record',
        parameters: {
          'calories': calories,
          'has_memo': memo != null && memo.isNotEmpty,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log calorie record: $e');
      }
    }
  }

  /// 目標設定イベントをログ
  Future<void> logGoalSet({
    required String goalType,
    required int targetValue,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'goal_set',
        parameters: {
          'goal_type': goalType,
          'target_value': targetValue,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log goal set: $e');
      }
    }
  }

  /// バッジ獲得イベントをログ
  Future<void> logBadgeUnlocked({
    required String badgeId,
    required String badgeName,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'badge_unlocked',
        parameters: {
          'badge_id': badgeId,
          'badge_name': badgeName,
        },
      );
      
      // 達成イベントとしても記録（広告最適化に有用）
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_achievement_unlocked',
        parameters: {
          'fb_description': badgeName,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log badge unlocked: $e');
      }
    }
  }

  /// 目標達成イベントをログ
  Future<void> logGoalAchieved({
    required String goalType,
    required int targetValue,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'goal_achieved',
        parameters: {
          'goal_type': goalType,
          'target_value': targetValue,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log goal achieved: $e');
      }
    }
  }

  /// シェアイベントをログ
  Future<void> logShare({
    required String contentType,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'share',
        parameters: {
          'content_type': contentType,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log share: $e');
      }
    }
  }

  /// 画面表示イベントをログ
  Future<void> logScreenView({
    required String screenName,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'screen_view',
        parameters: {
          'screen_name': screenName,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log screen view: $e');
      }
    }
  }

  /// カスタムイベントをログ
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log custom event: $e');
      }
    }
  }

  /// ユーザープロパティを設定
  Future<void> setUserProperty({
    required String key,
    required String value,
  }) async {
    try {
      await _facebookAppEvents.setUserData(
        email: key == 'email' ? value : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set user property: $e');
      }
    }
  }

  /// 累計カロリーをログ（定期的に呼び出す）
  Future<void> logTotalProgress({
    required int totalCalories,
    required int recordCount,
    required int currentStreak,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'total_progress',
        parameters: {
          'total_calories': totalCalories,
          'record_count': recordCount,
          'current_streak': currentStreak,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log total progress: $e');
      }
    }
  }
}
