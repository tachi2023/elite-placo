import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System de l'application Élite Placo & Déco.
/// Inspiré du site vitrine : Luxe, Plâtrerie, Décoration haut de gamme.
/// Couleurs principales : Anthracite profond (fond), Or/Laiton (accents).
class AppTheme {
  // --- Palette de Couleurs ---
  static const Color anthracite = Color(0xFF161618); // Fond principal
  static const Color anthraciteClair = Color(0xFF232326); // Cartes, surfaces
  static const Color or =
      Color(0xFFD4AF37); // Laiton/Or pour les accents (boutons, icônes)
  static const Color orSombre = Color(0xFFB5952F);
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color grisClair = Color(0xFFE0E0E0);
  static const Color grisFonce = Color(0xFF888888);

  static const Color rouge = Color(0xFFE05555);
  static const Color orange = Color(0xFFE0B84C);
  static const Color vert = Color(0xFF4CAF7D);
  static const Color erreur = Color(0xFFCF6679);
  static const Color succes = Color(0xFF4CAF50);

  // --- Typographie ---
  static TextTheme get _textTheme {
    // Utilisation de Outfit (très moderne, ronde et géométrique)
    // ou Inter (épurée) pour un aspect haut de gamme.
    return GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        color: blanc,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        color: blanc,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.outfit(
        color: or,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: grisClair,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: grisClair,
        fontSize: 14,
      ),
    );
  }

  // --- Thème Global (Dark Mode par défaut pour l'aspect premium) ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: anthracite,
      primaryColor: or,
      colorScheme: const ColorScheme.dark(
        primary: or,
        secondary: orSombre,
        surface: anthraciteClair,
        error: erreur,
        onPrimary: anthracite,
        onSecondary: blanc,
        onSurface: blanc,
      ),
      textTheme: _textTheme,

      // Style des AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: anthracite,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: or),
        titleTextStyle: _textTheme.titleLarge?.copyWith(color: blanc),
      ),

      // Style des Cartes (Glassmorphism léger ou Flat Anthracite)
      cardTheme: CardThemeData(
        color: anthraciteClair,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Boutons principaux
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: or,
          foregroundColor: anthracite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Boutons texte/secondaires
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: or,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: anthraciteClair,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: or, width: 1.5),
        ),
        labelStyle: const TextStyle(color: grisFonce),
        hintStyle: const TextStyle(color: grisFonce),
      ),

      // Icônes
      iconTheme: const IconThemeData(
        color: or,
        size: 24,
      ),
    );
  }
}
