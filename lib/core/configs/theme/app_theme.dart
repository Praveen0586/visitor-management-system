import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors + background for visitor status chip.
@immutable
class StatusStyle {
  final Color fg;
  final Color bg;
  const StatusStyle({required this.fg, required this.bg});

  static StatusStyle lerp(StatusStyle a, StatusStyle b, double t) =>
      StatusStyle(fg: Color.lerp(a.fg, b.fg, t)!, bg: Color.lerp(a.bg, b.bg, t)!);
}

/// ThemeExtension for status colors used with:
/// `Theme.of(context).extension<StatusColors>()!`
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final StatusStyle registered;
  final StatusStyle checkedIn;
  final StatusStyle checkedOut;

  const StatusColors({
    required this.registered,
    required this.checkedIn,
    required this.checkedOut,
  });

  StatusStyle forStatus(String status) {
    switch (status.trim()) {
      case 'Checked In':
        return checkedIn;
      case 'Checked Out':
        return checkedOut;
      case 'Registered':
      default:
        return registered;
    }
  }

  @override
  StatusColors copyWith({
    StatusStyle? registered,
    StatusStyle? checkedIn,
    StatusStyle? checkedOut,
  }) =>
      StatusColors(
        registered: registered ?? this.registered,
        checkedIn: checkedIn ?? this.checkedIn,
        checkedOut: checkedOut ?? this.checkedOut,
      );

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      registered: StatusStyle.lerp(registered, other.registered, t),
      checkedIn: StatusStyle.lerp(checkedIn, other.checkedIn, t),
      checkedOut: StatusStyle.lerp(checkedOut, other.checkedOut, t),
    );
  }
}

class AppTheme {
  AppTheme._();

  // Primary Palette
  static const Color navy = Color(0xFF16233B);
  static const Color navyLight = Color(0xFF1E2A44);
  static const Color gold = Color(0xFFF7C35F);
  static const Color goldDark = Color(0xFFD99B26);
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);

  // Status colors
  static const StatusColors lightStatusColors = StatusColors(
    registered: StatusStyle(fg: Color(0xFF2563EB), bg: Color(0xFFEFF6FF)),
    checkedIn: StatusStyle(fg: Color(0xFF16A34A), bg: Color(0xFFDCFCE7)),
    checkedOut: StatusStyle(fg: Color(0xFF64748B), bg: Color(0xFFF1F5F9)),
  );

  static const StatusColors darkStatusColors = StatusColors(
    registered: StatusStyle(fg: Color(0xFF60A5FA), bg: Color(0xFF1E293B)),
    checkedIn: StatusStyle(fg: Color(0xFF4ADE80), bg: Color(0xFF14532D)),
    checkedOut: StatusStyle(fg: Color(0xFF94A3B8), bg: Color(0xFF334155)),
  );

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: navy,
      onPrimary: Colors.white,
      secondary: gold,
      onSecondary: navy,
      surface: cardBg,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      extensions: const [lightStatusColors],
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: gold,
      onPrimary: navy,
      secondary: gold,
      onSecondary: navy,
      surface: Color(0xFF1E293B),
      onSurface: Colors.white,
      error: Color(0xFFF87171),
      onError: Colors.black,
      outline: Color(0xFF334155),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      extensions: const [darkStatusColors],
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
    );
  }
}
