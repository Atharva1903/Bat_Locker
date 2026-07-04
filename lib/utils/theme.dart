import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kColorPrimary = Color(0xFF8B0000); // Crimson
const Color kColorSecondary = Color(0xFFD4AF37); // Gold
const Color kColorTertiary = Color(0xFF1A1A1A); // Dark Gray (Cards, Dialogs)
const Color kColorNeutral = Color(0xFFA0A0A0); // Medium Gray
const Color kColorBackground = Color(0xFF0D0D0D); // Near Black

ThemeData getAppTheme() {
  const Color bgColor = kColorBackground;
  const Color cardColor = kColorTertiary;
  const Color textColor = Colors.white;
  const Color secondaryTextColor = kColorNeutral;

  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: kColorPrimary,
    scaffoldBackgroundColor: bgColor,
    cardColor: cardColor,
    colorScheme: const ColorScheme.dark(
      primary: kColorPrimary,
      secondary: kColorSecondary,
      surface: kColorTertiary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardColor,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.anton(
        fontSize: 28,
        color: Colors.white,
        letterSpacing: 2,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kColorPrimary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kColorPrimary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kColorSecondary,
        textStyle: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.jetBrainsMono(color: secondaryTextColor),
      hintStyle: GoogleFonts.jetBrainsMono(color: secondaryTextColor.withAlpha(178)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: secondaryTextColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: kColorSecondary, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.anton(color: textColor, fontSize: 32),
      headlineMedium: GoogleFonts.anton(color: textColor, fontSize: 24),
      titleLarge: GoogleFonts.jetBrainsMono(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.jetBrainsMono(color: textColor, fontSize: 16),
      bodyMedium: GoogleFonts.jetBrainsMono(color: secondaryTextColor, fontSize: 14),
      labelLarge: GoogleFonts.jetBrainsMono(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
    ),
  );
}

class LockerTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final bool showBrackets;

  const LockerTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.maxLines,
    this.showBrackets = true,
  });

  @override
  State<LockerTextField> createState() => _LockerTextFieldState();
}

class _LockerTextFieldState extends State<LockerTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final bool useBrackets = widget.showBrackets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: const Color(0xFFFFA79A), // Peach
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF070707), // Dark terminal background
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: (widget.maxLines != null && widget.maxLines! > 1)
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (useBrackets) ...[
                    Text(
                      '> [ ',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFFFFA79A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      obscureText: _obscureText,
                      keyboardType: widget.keyboardType,
                      maxLines: widget.obscureText ? 1 : widget.maxLines,
                      onChanged: widget.onChanged,
                      autofocus: widget.autofocus,
                      focusNode: widget.focusNode,
                      onSubmitted: widget.onSubmitted,
                      cursorColor: const Color(0xFFD4AF37), // Gold
                      cursorWidth: 8,
                      cursorRadius: Radius.zero,
                      showCursor: true,
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: _obscureText ? 3.0 : 1.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintText: widget.hintText,
                        hintStyle: GoogleFonts.jetBrainsMono(
                          color: Colors.white.withAlpha(77),
                          fontSize: 15,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  if (useBrackets) ...[
                    Text(
                      ' ]',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFFFFA79A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (widget.obscureText) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: kColorPrimary, // Crimson color used in the app
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // White corner top-left
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 1.5),
                    left: BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
            // White corner bottom-right
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 1.5),
                    right: BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
