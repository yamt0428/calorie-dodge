import 'package:flutter/foundation.dart';
import '../models/badge.dart';
import '../services/storage_service.dart';

class BadgeProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<AppBadge> _badges = [];
  AppBadge? _newlyUnlockedBadge;

  BadgeProvider(this._storageService) {
    _loadBadges();
  }

  List<AppBadge> get badges => _badges;

  List<AppBadge> get unlockedBadges => _badges.where((b) => b.isUnlocked).toList();

  List<AppBadge> get lockedBadges => _badges.where((b) => !b.isUnlocked).toList();

  AppBadge? get newlyUnlockedBadge => _newlyUnlockedBadge;

  void clearNewlyUnlockedBadge() {
    _newlyUnlockedBadge = null;
    notifyListeners();
  }

  void _loadBadges() {
    _badges = _storageService.getAllBadges();
    notifyListeners();
  }

  /// バッジの達成状況をチェックして更新
  Future<void> checkAndUpdateBadges({
    required int totalCalories,
    required int currentStreak,
    required int recordCount,
  }) async {
    for (final badge in _badges) {
      if (badge.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (badge.type) {
        case BadgeType.calories:
          shouldUnlock = totalCalories >= badge.threshold;
          break;
        case BadgeType.streak:
          shouldUnlock = currentStreak >= badge.threshold;
          break;
        case BadgeType.count:
          shouldUnlock = recordCount >= badge.threshold;
          break;
      }

      if (shouldUnlock) {
        await _storageService.unlockBadge(badge.id);
        _newlyUnlockedBadge = badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
        _loadBadges();
        notifyListeners();
        return; // 1つずつ通知
      }
    }
  }

  /// バッジの進捗率を取得
  double getBadgeProgress(AppBadge badge, {
    required int totalCalories,
    required int currentStreak,
    required int recordCount,
  }) {
    if (badge.isUnlocked) return 1.0;

    int currentValue;
    switch (badge.type) {
      case BadgeType.calories:
        currentValue = totalCalories;
        break;
      case BadgeType.streak:
        currentValue = currentStreak;
        break;
      case BadgeType.count:
        currentValue = recordCount;
        break;
    }

    return (currentValue / badge.threshold).clamp(0.0, 1.0);
  }

  /// バッジタイプ別に取得
  List<AppBadge> getBadgesByType(BadgeType type) {
    return _badges.where((b) => b.type == type).toList()
      ..sort((a, b) => a.threshold.compareTo(b.threshold));
  }
}
