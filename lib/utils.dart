import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle boldtextsyle({required double size, Color? color, bool? shadow}) {
  return GoogleFonts.sourceSans3(
    fontSize: size,
    color: (color == null) ? Colors.black : color,
    shadows: (shadow != null)
        ? [
            const Shadow(
              blurRadius: 2.5,
              color: Colors.grey,
            )
          ]
        : null,
    fontWeight: FontWeight.bold,
  );
}

TextStyle normaltextsyle({required double size, Color? color}) {
  return GoogleFonts.sourceSans3(
    fontSize: size,
    color: (color == null) ? Colors.black : color,
  );
}

TextStyle mediumtextsyle({required double size, Color? color}) {
  return GoogleFonts.sourceSans3(
    fontSize: size,
    color: (color == null) ? Colors.black : color,
    fontWeight: FontWeight.w500,
  );
}
