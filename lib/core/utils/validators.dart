class AppValidators {
 

  // ──────────────────────── REGEX PATTERNS ────────────────────────
  /// Regex for full name: allows letters, spaces, dots, hyphens, and apostrophes (min 2 chars).
  static final RegExp nameRegex = RegExp(r"^[a-zA-Z\s.'-]{2,50}$");

  /// Standard 10-digit Indian mobile number regex (starts with 6-9, followed by 9 digits).
  static final RegExp mobileRegex = RegExp(r'^[6-9]\d{9}$');

  /// Digits-only regex.
  static final RegExp digitsOnlyRegex = RegExp(r'^\d+$');

  /// RFC 5322 standard email regex pattern.
  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  // ──────────────────────── FIELD VALIDATORS ────────────────────────

  /// Validates visitor full name.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required for guest badge creation';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Please enter a valid full name (letters only)';
    }
    return null;
  }

  /// Validates 10-digit mobile number and provides real-time remaining count feedback.
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a valid 10-digit mobile number (10 remaining)';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (!digitsOnlyRegex.hasMatch(cleaned)) {
      return 'Mobile number must contain digits only';
    }
    if (cleaned.length < 10) {
      final remaining = 10 - cleaned.length;
      return 'Enter a valid 10-digit mobile number ($remaining remaining)';
    }
    if (cleaned.length > 10) {
      return 'Mobile number cannot exceed 10 digits';
    }
    if (!mobileRegex.hasMatch(cleaned)) {
      return 'Must be a valid 10-digit mobile starting with 6, 7, 8, or 9';
    }
    return null;
  }

  /// Validates optional email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final trimmed = value.trim();
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates purpose of visit (max 120 chars, not empty).
  static String? validatePurpose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Purpose of visit is required';
    }
    final trimmed = value.trim();
    if (trimmed.length > 120) {
      return 'Purpose cannot exceed 120 characters';
    }
    return null;
  }

  /// Validates project / estate selection.
  static String? validateProject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a project / estate';
    }
    return null;
  }

  /// Validates visitor category selection.
  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a visitor category';
    }
    return null;
  }
}
