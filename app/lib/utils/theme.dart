import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configurações de tema do MapGuaru
class AppTheme {
  // ==================== CORES DE MARCA E CATEGORIA ====================
  
  // Cores que permanecerão as mesmas em ambos os temas para consistência de marca
  static const Color primaryColor = Color(0xFF2563EB); // Azul
  static const Color secondaryColor = Color(0xFF1E40AF); // Azul escuro
  static const Color tertiaryColor = Color(0xFF2BAD26); // Verde claro para destaques
  static const Color accentColor = Color(0xFFF59E0B); // Laranja de destaque
  
  // Cores de categorias (mantidas para ambos os temas)
  static const Color healthColor = Color(0xFF4338CA); 
  static const Color educationColor = Color(0xFF059669); 
  static const Color communityColor = Color(0xFFDC2626); 
  static const Color securityColor = Color(0xFFF59E0B); 
  static const Color transportColor = Color(0xFF7C3AED); 
  static const Color cultureColor = Color(0xFFEA580C); 
  
  // Cores de status (mantidas para ambos os temas)
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ==================== CORES DO TEMA LIGHT (EXISTENTES) ====================
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textLightLight = Color(0xFF9CA3AF);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color cardBackgroundLight = Colors.white;

  // ==================== CORES DO TEMA DARK (NOVO!) ====================
  static const Color backgroundDark = Color(0xFF121212); // Fundo muito escuro
  static const Color cardBackgroundDark = Color(0xFF1E1E1E); // Superfície escura
  static const Color textPrimaryDark = Color(0xFFE5E7EB); // Texto claro
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Texto secundário claro
  static const Color textLightDark = Color(0xFF6B7280); // Texto terciário escuro
  
  // ==================== TEMA LIGHT (EXISTENTE) ====================
  
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light, 
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Helvetica',
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardBackgroundLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: 'Helvetica',
          color: textLightLight,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Helvetica',
          color: textSecondaryLight,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimaryLight,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Helvetica', fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryLight),
        displayMedium: TextStyle(fontFamily: 'Helvetica', fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryLight),
        displaySmall: TextStyle(fontFamily: 'Helvetica', fontSize: 24, fontWeight: FontWeight.bold, color: textPrimaryLight),
        headlineMedium: TextStyle(fontFamily: 'Helvetica', fontSize: 20, fontWeight: FontWeight.bold, color: textPrimaryLight),
        headlineSmall: TextStyle(fontFamily: 'Helvetica', fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleLarge: TextStyle(fontFamily: 'Helvetica', fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryLight),
        bodyLarge: TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: textPrimaryLight),
        bodyMedium: TextStyle(fontFamily: 'Helvetica', fontSize: 14, color: textSecondaryLight),
        bodySmall: TextStyle(fontFamily: 'Helvetica', fontSize: 12, color: textLightLight),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLightLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: error,
        background: backgroundLight,
        brightness: Brightness.light,
      ),
    );
  }

  // ==================== TEMA DARK (NOVO!) ====================
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark, // Importante para identificar o tema
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Helvetica',
      
      // AppBar Theme (Mantendo o azul de marca)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor, 
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme (Usando a superfície escura)
      cardTheme: CardThemeData(
        color: cardBackgroundDark,
        elevation: 4, // Aumenta a elevação no tema escuro
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme (Mantido para ser primário)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme (Mantido)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme (Ajustado para o tema escuro)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundDark, // Fundo do campo mais sutil
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textLightDark.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textLightDark.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: 'Helvetica',
          color: textLightDark,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Helvetica',
          color: textSecondaryDark,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimaryDark,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Helvetica', fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryDark),
        displayMedium: TextStyle(fontFamily: 'Helvetica', fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryDark),
        displaySmall: TextStyle(fontFamily: 'Helvetica', fontSize: 24, fontWeight: FontWeight.bold, color: textPrimaryDark),
        headlineMedium: TextStyle(fontFamily: 'Helvetica', fontSize: 20, fontWeight: FontWeight.bold, color: textPrimaryDark),
        headlineSmall: TextStyle(fontFamily: 'Helvetica', fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryDark),
        titleLarge: TextStyle(fontFamily: 'Helvetica', fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryDark),
        bodyLarge: TextStyle(fontFamily: 'Helvetica', fontSize: 16, color: textPrimaryDark),
        bodyMedium: TextStyle(fontFamily: 'Helvetica', fontSize: 14, color: textSecondaryDark),
        bodySmall: TextStyle(fontFamily: 'Helvetica', fontSize: 12, color: textLightDark),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackgroundDark, 
        selectedItemColor: primaryColor,
        unselectedItemColor: textLightDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: error,
        background: backgroundDark,
        brightness: Brightness.dark,
      ),
    );
  }

  // ==================== UTILIDADES DE ESTILO ====================
  // (Mantidas)
  
  /// Retorna a cor de acordo com o ID da categoria
  static Color getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1: return healthColor;
      case 2: return educationColor;
      case 3: return communityColor;
      case 4: return securityColor;
      case 5: return transportColor;
      case 6: return cultureColor;
      default: return primaryColor;
    }
  }
  
  /// Retorna o ícone de acordo com o nome da categoria
  static IconData getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'health': return Icons.local_hospital;
      case 'education': return Icons.school;
      case 'community': return Icons.people;
      case 'security': return Icons.security;
      case 'transport': return Icons.directions_bus;
      case 'culture': return Icons.theater_comedy;
      default: return Icons.place;
    }
  }

  // ==================== ESPAÇAMENTOS ====================
  
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  
  // ==================== BORDAS ====================
  
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  
  // ==================== SOMBRAS ====================
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}