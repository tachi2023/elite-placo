import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double titleSize;
  final bool centered;

  const BrandLogo({
    super.key,
    this.titleSize = 18,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text.rich(
          TextSpan(
            text: 'Élite Placo ',
            children: [
              TextSpan(
                text: '&',
                style: TextStyle(color: AppTheme.or),
              ),
              const TextSpan(text: ' Déco'),
            ],
          ),
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.cormorantGaramond(
            color: AppTheme.or,
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PAR PRIMA BTP',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.48),
            fontSize: titleSize < 17 ? 7 : 9,
            fontWeight: FontWeight.w400,
            letterSpacing: 2.1,
            height: 1,
          ),
        ),
      ],
    );
  }
}
