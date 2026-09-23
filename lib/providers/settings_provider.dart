import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailycart/core/constants/app_constants.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.notificationsEnabled = true,
    this.appLockEnabled = false,
    this.onboardingDone = false,
    this.defaultListView = 'list',
  });
  final ThemeMode themeMode;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool notificationsEnabled;
  final bool appLockEnabled;
  final bool onboardingDone;
  final String defaultListView;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? notificationsEnabled,
    bool? appLockEnabled,
    bool? onboardingDone,
    String? defaultListView,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      defaultListView: defaultListView ?? this.defaultListView,
    );
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return _load(prefs);
  }

  AppSettings _load(SharedPreferences prefs) {
    final idx = prefs.getInt(AppConstants.keyThemeMode) ?? 0;
    return AppSettings(
      themeMode: ThemeMode.values[idx],
      hapticsEnabled: prefs.getBool(AppConstants.keyHapticsEnabled) ?? true,
      reducedMotion: prefs.getBool(AppConstants.keyReducedMotion) ?? false,
      notificationsEnabled:
          prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true,
      appLockEnabled: prefs.getBool(AppConstants.keyAppLockEnabled) ?? false,
      onboardingDone: prefs.getBool(AppConstants.keyOnboardingDone) ?? false,
      defaultListView:
          prefs.getString(AppConstants.keyDefaultListView) ?? 'list',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setInt(AppConstants.keyThemeMode, mode.index);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setOnboardingDone() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    state = AsyncData(state.value!.copyWith(onboardingDone: true));
  }

  Future<void> setHaptics(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(AppConstants.keyHapticsEnabled, value);
    state = AsyncData(state.value!.copyWith(hapticsEnabled: value));
  }

  Future<void> setReducedMotion(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(AppConstants.keyReducedMotion, value);
    state = AsyncData(state.value!.copyWith(reducedMotion: value));
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(AppConstants.keyNotificationsEnabled, value);
    state = AsyncData(state.value!.copyWith(notificationsEnabled: value));
  }

  Future<void> setAppLock(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(AppConstants.keyAppLockEnabled, value);
    state = AsyncData(state.value!.copyWith(appLockEnabled: value));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
