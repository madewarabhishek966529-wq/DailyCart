// DailyCart - App Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'DailyCart';
  static const String appTagline = 'Plan. Shop. Done.';
  static const String currency = '\u20b9'; // ₹
  static const String currencyCode = 'INR';

  // SharedPreferences keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';
  static const String keyHapticsEnabled = 'haptics_enabled';
  static const String keyReducedMotion = 'reduced_motion';
  static const String keyDefaultListView = 'default_list_view';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyAppLockEnabled = 'app_lock_enabled';

  static const List<String> units = [
    'piece',
    'kg',
    'g',
    'litre',
    'ml',
    'pack',
    'dozen',
    'bag',
    'box',
    'bottle',
    'can',
    'bunch',
  ];

  // Animation durations (ms)
  static const int microDuration = 150;
  static const int standardDuration = 280;
  static const int majorDuration = 450;
  static const int completionDuration = 700;
}
