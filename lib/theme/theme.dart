import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color lightPrimary = Color(0xFF20B2AA);
const Color darkPrimary = Color(0xFF121212);

ThemeData lightTheme = ThemeData(
  primaryColor: lightPrimary,
  brightness: Brightness.light,
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: const ColorScheme.light(
    primary: lightPrimary,
    secondary: Colors.tealAccent,
  ),
);

ThemeData darkTheme = ThemeData(
  primaryColor: darkPrimary,
  brightness: Brightness.dark,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  colorScheme: const ColorScheme.dark(
    primary: darkPrimary,
    secondary: Colors.tealAccent,
  ),
);
