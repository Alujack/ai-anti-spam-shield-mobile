class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator, use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator, use: 'http://localhost:3000/api/v1'
  // For physical device, use your computer's IP: 'http://192.168.x.x:3000/api/v1'
  
  static const int timeout = 30000; // 30 seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String historyRoute = '/history';
  static const String resultRoute = '/result';
  static const String settingsRoute = '/settings';
}

