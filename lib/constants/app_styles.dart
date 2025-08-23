import 'package:flutter/material.dart';

class AppStyles {
  // Colors
  static const Color lesothoBlue = Color(0xFF003366);
  static const Color lesothoGreen = Color(0xFF009933);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  // Gradients
  static final Gradient lesothoGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lesothoBlue, lesothoGreen],
  );

  // Border Radius
  static const BorderRadius borderRadius12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadius16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius borderRadius20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius borderRadiusBottom20 = BorderRadius.only(
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  );

  // Box Shadows
  static final BoxShadow subtleShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    spreadRadius: 2,
  );

  static final List<BoxShadow> cardShadow = [subtleShadow];

  // Button Styles
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: lesothoBlue,
      foregroundColor: white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: borderRadius12),
      elevation: 3,
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: white,
      foregroundColor: lesothoBlue,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: borderRadius12),
      elevation: 3,
    );
  }

  // Text Styles
  static const TextStyle appTitleTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static const TextStyle appSubtitleTextStyle = TextStyle(
    fontSize: 16,
    color: white70,
  );

  static TextStyle formTitleTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  static const TextStyle formSubtitleTextStyle = TextStyle(
    color: grey600,
  );

  static const TextStyle programNameTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: lesothoBlue,
  );

  static TextStyle universityNameTextStyle = TextStyle(
    fontSize: 16,
    color: grey700,
    fontWeight: FontWeight.w500,
  );

  // Input Decoration
  static InputDecoration textInputDecoration(String labelText, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: borderRadius12),
      filled: true,
      fillColor: grey50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: suffixIcon,
    );
  }

  // Card Decoration
  static BoxDecoration whiteCardDecoration = BoxDecoration(
    color: white,
    borderRadius: borderRadius20,
    boxShadow: cardShadow,
  );
}