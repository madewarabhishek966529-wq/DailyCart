import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/core/navigation/app_router.dart';
import 'package:dailycart/core/theme/app_theme.dart';
import 'package:dailycart/providers/database_provider.dart';
import 'package:dailycart/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: DailyCartApp()));
}

class DailyCartApp extends ConsumerWidget {
  const DailyCartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(databaseProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = settingsAsync.maybeWhen(
      data: (s) => s.themeMode,
      orElse: () => ThemeMode.system,
    );
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DailyCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
