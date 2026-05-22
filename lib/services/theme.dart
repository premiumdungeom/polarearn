import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color green = Color(0xFF1a9e3f);
  static const Color greenDark = Color(0xFF157a32);
  static const Color greenLight = Color(0xFFe8f5ec);
  static const Color greenMid = Color(0xFF2db85a);
  static const Color textDark = Color(0xFF111111);
  static const Color textGray = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color border = Color(0xFFe8e8e8);
  static const Color bg = Color(0xFFf5f5f5);
  static const Color red = Color(0xFFe53935);
  static const Color redLight = Color(0xFFfdecea);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        textTheme: GoogleFonts.dmSansTextTheme(),
        scaffoldBackgroundColor: bg,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          iconTheme: const IconThemeData(color: textDark),
        ),
      );
}
