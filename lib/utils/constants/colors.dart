import 'package:flutter/material.dart';

class TColors{
  TColors._();

  // App Basic Colors
  static const Color primaryColor = Color(0xFF6E6E6E);
  static const Color secondary = Color(0xFFECE19E);
  static const Color accent = Color(0xFFFFF8E0);

  //Gradient
  static const Gradient linerGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [
      Color(0xffff9a9e),
      Color(0xffffad0c4),
      Color(0xffffad0c4),
    ],
  );


  //Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3D3D3D);
  static const Color textWhite = Color(0xFFFFFEFE);

  // Background Colors
  static const Color light = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF575757);
  static const Color primaryBackground = Color(0xFFEFEFEF);

  //Backgorund Container Class
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = TColors.white.withOpacity(0.1);

  //Button Colors
  static const Color buttonPrimary = Color(0xFF00B1FF);
  static const Color buttonSecondary = Color(0xFF797979);
  static const Color buttonDisabled = Color(0xFFFFFFFF);

  //Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFFFFFFF);

  //Error and Validation
  static const Color error = Color(0xFFFF0000);
  static const Color success = Color(0xFF797979);
  static const Color warning = Color(0xFF797979);
  static const Color info = Color(0xFF797979);

  //Neutral Shades
  static const Color black = Color(0xFF000000);
  static const Color darkergrey = Color(0xFF606060);
  static const Color darkgrey = Color(0xFF383838);
  static const Color grey = Color(0xFFA9A9A9);
  static const Color softgrey = Color(0xFFC2C2C2);
  static const Color lightgrey = Color(0xFFD9D9D9);
  static const Color white = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF00B1FF);

}