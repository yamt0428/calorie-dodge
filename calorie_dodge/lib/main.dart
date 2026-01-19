import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'services/storage_service.dart';
import 'providers/record_provider.dart';
import 'providers/badge_provider.dart';
import 'providers/goal_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 日本語ロケールの初期化
  await initializeDateFormatting('ja');
  
  // ストレージサービスの初期化
  final storageService = StorageService();
  await storageService.init();
  
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecordProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => BadgeProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(storageService),
        ),
      ],
      child: MaterialApp(
        title: 'カロリーセーブ',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigation(),
      ),
    );
  }
}
