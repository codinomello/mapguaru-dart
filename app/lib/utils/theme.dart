import 'package:flutter/material.dart';

/// Configurações de tema do MapGuaru
/// 
/// Define cores, tipografia e estilos visuais consistentes
/// em todo o aplicativo, seguindo o design fornecido
class AppTheme {
  // ==================== CORES ====================
  
  /// Cor primária - Azul do MapGuaru
  static const Color primaryColor = Color(0xFF2563EB); // Azul
  
  /// Cor secundária - Azul escuro
  static const Color secondaryColor = Color(0xFF1E40AF);
  
  /// Cor de destaque - Laranja
  static const Color accentColor = Color(0xFFF59E0B);
  
  /// Cores das categorias (conforme design)
  static const Color healthColor = Color(0xFF4338CA); // Saúde - Roxo escuro
  static const Color educationColor = Color(0xFF059669); // Educação - Verde
  static const Color communityColor = Color(0xFFDC2626); // Comunidade - Vermelho
  static const Color securityColor = Color(0xFFF59E0B); // Segurança - Amarelo
  static const Color transportColor = Color(0xFF7C3AED); // Transporte - Roxo
  static const Color cultureColor = Color(0xFFEA580C); // Cultura - Laranja
  
  /// Cores de texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  
  /// Cores de fundo
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Colors.white;
  
  /// Cores de status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ==================== TEMA PRINCIPAL ====================
  
  /// Retorna o tema configurado para o app
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: background,
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
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardBackground,
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
        fillColor: Colors.white,
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
        hintStyle: TextStyle(
          fontFamily: 'Helvetica',
          color: textLight,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Helvetica',
          color: textSecondary,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 12,
          color: textLight,
        ),
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
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: error,
        background: background,
      ),
    );
  }

  // ==================== UTILIDADES DE ESTILO ====================
  
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