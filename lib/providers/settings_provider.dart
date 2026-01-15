import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool isLoading;

  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.isLoading = false,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? isLoading,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
}

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    _loadSettings();
    return const AppSettingsState();
  }

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeModeString = prefs.getString(AppConstants.themeModeKey);
      ThemeMode themeMode = ThemeMode.system;
      if (themeModeString == 'dark') {
        themeMode = ThemeMode.dark;
      } else if (themeModeString == 'light') {
        themeMode = ThemeMode.light;
      }

      // Load notifications preference
      final notificationsEnabled =
          prefs.getBool(AppConstants.notificationsEnabledKey) ?? true;

      state = state.copyWith(
        themeMode: themeMode,
        notificationsEnabled: notificationsEnabled,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeModeString;
      switch (mode) {
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        default:
          themeModeString = 'system';
      }
      await prefs.setString(AppConstants.themeModeKey, themeModeString);
      state = state.copyWith(themeMode: mode);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.notificationsEnabledKey, enabled);
      state = state.copyWith(notificationsEnabled: enabled);
    } catch (e) {
      // Handle error silently
    }
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
  () => AppSettingsNotifier(),
);
