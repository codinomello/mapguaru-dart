import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart'; 

// Enum para gerenciar as opções de tema
enum ThemeModeOption {
  system, // Segue a preferência do dispositivo
  light,  // Tema claro forçado
  dark,   // Tema escuro forçado
}

class ThemeProvider with ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.system;

  ThemeModeOption get themeModeOption => _themeMode;
  
  /// Mapeia a opção selecionada para o ThemeMode do Flutter
  ThemeMode get themeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Carrega a preferência de tema salva
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Assume 'system' como padrão se nada estiver salvo
      final savedTheme = prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeModeOption.light;
          break;
        case 'dark':
          _themeMode = ThemeModeOption.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeModeOption.system;
          break;
      }
      notifyListeners();
    } catch (e) {
      // Falha ao carregar, mantém o padrão 'system'
    }
  }

  /// Define e salva a nova preferência de tema
  Future<void> setThemeMode(ThemeModeOption newMode) async {
    if (newMode == _themeMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;
  
      switch (newMode) {
        case ThemeModeOption.light:
          modeString = 'light';
          break;
        case ThemeModeOption.dark:
          modeString = 'dark';
          break;
        default:
          modeString = 'system';
          break;
      }
  
      await prefs.setString(AppConstants.keyThemeMode, modeString);
      _themeMode = newMode;
      notifyListeners();
    } catch (e) {
      // Falha ao salvar
    }
  }
}