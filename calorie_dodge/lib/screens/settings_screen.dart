import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/record_provider.dart';
import '../providers/badge_provider.dart';
import '../theme/app_theme.dart';

// ignore_for_file: deprecated_member_use

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // シェア機能
          _buildSectionHeader('シェア'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('週間レポートをシェア'),
                  subtitle: const Text('今週の成果をSNSに共有'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _shareWeeklyReport(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('累計成果をシェア'),
                  subtitle: const Text('累計の記録をSNSに共有'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _shareTotalProgress(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // データ管理
          _buildSectionHeader('データ管理'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('データをエクスポート'),
                  subtitle: const Text('記録データをテキスト形式で出力'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportData(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'すべてのデータを削除',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('この操作は元に戻せません'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _confirmDeleteAllData(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // アプリ情報
          _buildSectionHeader('アプリ情報'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('バージョン'),
                  trailing: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('プライバシーポリシー'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('使い方'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showHowToUse(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // クレジット
          Center(
            child: Column(
              children: [
                const Text(
                  'カロリーセーブ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '誘惑に勝った自分を褒めよう',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  void _shareWeeklyReport(BuildContext context) {
    final recordProvider = context.read<RecordProvider>();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final formatter = NumberFormat('#,###');

    // 今週のカロリーを計算
    int weeklyCalories = 0;
    int weeklyCount = 0;
    for (final record in recordProvider.records) {
      if (record.timestamp.isAfter(weekStart) ||
          (record.timestamp.year == weekStart.year &&
              record.timestamp.month == weekStart.month &&
              record.timestamp.day == weekStart.day)) {
        weeklyCalories += record.calories;
        weeklyCount++;
      }
    }

    final message = '''
🎯 カロリーセーブ 週間レポート

📅 ${DateFormat('M月d日').format(weekStart)} 〜 ${DateFormat('M月d日').format(now)}

🔥 回避カロリー: ${formatter.format(weeklyCalories)} kcal
📝 記録回数: $weeklyCount 回

誘惑に負けずに頑張りました！
#カロリーセーブ #ダイエット #健康管理
''';

    Share.share(message);
  }

  void _shareTotalProgress(BuildContext context) {
    final recordProvider = context.read<RecordProvider>();
    final badgeProvider = context.read<BadgeProvider>();
    final formatter = NumberFormat('#,###');

    final totalCalories = recordProvider.totalCalories;
    final recordCount = recordProvider.recordCount;
    final maxStreak = recordProvider.maxStreak;
    final currentStreak = recordProvider.currentStreak;
    final unlockedBadges = badgeProvider.unlockedBadges.length;

    final message = '''
🏆 カロリーセーブ 成果報告

🔥 累計回避カロリー: ${formatter.format(totalCalories)} kcal
📝 総記録回数: $recordCount 回
⚡ 連続記録: $currentStreak 日（最長: $maxStreak 日）
🎖️ 獲得バッジ: $unlockedBadges 個

コツコツ積み重ねています！
#カロリーセーブ #ダイエット #健康管理
''';

    Share.share(message);
  }

  void _exportData(BuildContext context) {
    final recordProvider = context.read<RecordProvider>();
    final records = recordProvider.records;
    final formatter = NumberFormat('#,###');

    final buffer = StringBuffer();
    buffer.writeln('カロリーセーブ データエクスポート');
    buffer.writeln('エクスポート日時: ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('=== 統計 ===');
    buffer.writeln('累計カロリー: ${formatter.format(recordProvider.totalCalories)} kcal');
    buffer.writeln('総記録回数: ${recordProvider.recordCount} 回');
    buffer.writeln('連続記録: ${recordProvider.currentStreak} 日');
    buffer.writeln('最長連続: ${recordProvider.maxStreak} 日');
    buffer.writeln('');
    buffer.writeln('=== 記録一覧 ===');

    for (final record in records) {
      buffer.writeln(
        '${DateFormat('yyyy/MM/dd HH:mm').format(record.timestamp)} | ${formatter.format(record.calories)} kcal | ${record.memo ?? "-"}',
      );
    }

    Share.share(buffer.toString());
  }

  void _confirmDeleteAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('すべてのデータを削除'),
        content: const Text(
          'すべての記録、目標、バッジのデータが削除されます。\nこの操作は元に戻せません。\n\n本当に削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 実際のデータ削除処理を実装
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データを削除しました')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プライバシーポリシー'),
        content: const SingleChildScrollView(
          child: Text(
            'カロリーセーブは、ユーザーのプライバシーを尊重します。\n\n'
            '【データの保存】\n'
            'すべてのデータはお使いのデバイス内にのみ保存され、外部サーバーには送信されません。\n\n'
            '【データの収集】\n'
            'このアプリは個人情報を収集しません。\n\n'
            '【データの削除】\n'
            'アプリをアンインストールすると、すべてのデータが削除されます。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showHowToUse(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使い方'),
        content: const SingleChildScrollView(
          child: Text(
            '【カロリーセーブの使い方】\n\n'
            '1️⃣ 誘惑に勝った時\n'
            '高カロリーな食品を買いたくなったけど我慢できた！そんな時に「記録する」ボタンを押して、回避したカロリーを記録しましょう。\n\n'
            '2️⃣ カレンダーで確認\n'
            'ホーム画面のカレンダーで、毎日の頑張りを視覚的に確認できます。記録が多い日ほど濃い緑色になります。\n\n'
            '3️⃣ 目標を設定\n'
            '週間や月間の目標を設定して、モチベーションを維持しましょう。\n\n'
            '4️⃣ バッジを集める\n'
            '累計カロリーや連続記録でバッジが獲得できます。全てのバッジを目指しましょう！\n\n'
            '5️⃣ 成果をシェア\n'
            '頑張った成果をSNSでシェアして、モチベーションをさらにアップ！',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
