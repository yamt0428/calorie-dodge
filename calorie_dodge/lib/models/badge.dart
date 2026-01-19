import 'package:hive/hive.dart';

part 'badge.g.dart';

@HiveType(typeId: 4)
class AppBadge extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  BadgeType type;

  @HiveField(3)
  int threshold;

  @HiveField(4)
  bool isUnlocked;

  @HiveField(5)
  DateTime? unlockedAt;

  @HiveField(6)
  String description;

  @HiveField(7)
  String icon;

  AppBadge({
    required this.id,
    required this.name,
    required this.type,
    required this.threshold,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.description,
    required this.icon,
  });

  AppBadge copyWith({
    String? id,
    String? name,
    BadgeType? type,
    int? threshold,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? description,
    String? icon,
  }) {
    return AppBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      threshold: threshold ?? this.threshold,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}

@HiveType(typeId: 5)
enum BadgeType {
  @HiveField(0)
  calories, // 累計カロリーバッジ

  @HiveField(1)
  streak, // 連続記録日数バッジ

  @HiveField(2)
  count, // 記録回数バッジ
}

/// 初期バッジ定義
class BadgeDefinitions {
  static List<AppBadge> getAllBadges() {
    return [
      // 累計カロリーバッジ
      AppBadge(
        id: 'calories_1000',
        name: '1,000kcal回避',
        type: BadgeType.calories,
        threshold: 1000,
        description: '累計1,000kcalを回避しました！',
        icon: '🥉',
      ),
      AppBadge(
        id: 'calories_5000',
        name: '5,000kcal回避',
        type: BadgeType.calories,
        threshold: 5000,
        description: '累計5,000kcalを回避しました！',
        icon: '🥈',
      ),
      AppBadge(
        id: 'calories_10000',
        name: '10,000kcal回避',
        type: BadgeType.calories,
        threshold: 10000,
        description: '累計10,000kcalを回避しました！',
        icon: '🥇',
      ),
      AppBadge(
        id: 'calories_30000',
        name: '30,000kcal回避',
        type: BadgeType.calories,
        threshold: 30000,
        description: '累計30,000kcalを回避しました！',
        icon: '🏆',
      ),
      AppBadge(
        id: 'calories_50000',
        name: '50,000kcal回避',
        type: BadgeType.calories,
        threshold: 50000,
        description: '累計50,000kcalを回避しました！',
        icon: '👑',
      ),

      // 連続記録日数バッジ
      AppBadge(
        id: 'streak_3',
        name: '3日連続',
        type: BadgeType.streak,
        threshold: 3,
        description: '3日連続で記録しました！',
        icon: '🔥',
      ),
      AppBadge(
        id: 'streak_7',
        name: '7日連続',
        type: BadgeType.streak,
        threshold: 7,
        description: '7日連続で記録しました！',
        icon: '🔥',
      ),
      AppBadge(
        id: 'streak_14',
        name: '14日連続',
        type: BadgeType.streak,
        threshold: 14,
        description: '14日連続で記録しました！',
        icon: '🔥',
      ),
      AppBadge(
        id: 'streak_30',
        name: '30日連続',
        type: BadgeType.streak,
        threshold: 30,
        description: '30日連続で記録しました！',
        icon: '🔥',
      ),
      AppBadge(
        id: 'streak_100',
        name: '100日連続',
        type: BadgeType.streak,
        threshold: 100,
        description: '100日連続で記録しました！',
        icon: '💎',
      ),

      // 記録回数バッジ
      AppBadge(
        id: 'count_10',
        name: '10回記録',
        type: BadgeType.count,
        threshold: 10,
        description: '10回記録しました！',
        icon: '⭐',
      ),
      AppBadge(
        id: 'count_50',
        name: '50回記録',
        type: BadgeType.count,
        threshold: 50,
        description: '50回記録しました！',
        icon: '⭐',
      ),
      AppBadge(
        id: 'count_100',
        name: '100回記録',
        type: BadgeType.count,
        threshold: 100,
        description: '100回記録しました！',
        icon: '🌟',
      ),
      AppBadge(
        id: 'count_300',
        name: '300回記録',
        type: BadgeType.count,
        threshold: 300,
        description: '300回記録しました！',
        icon: '🌟',
      ),
      AppBadge(
        id: 'count_500',
        name: '500回記録',
        type: BadgeType.count,
        threshold: 500,
        description: '500回記録しました！',
        icon: '💫',
      ),
    ];
  }
}
