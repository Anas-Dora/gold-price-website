import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoldCard extends StatelessWidget {
  const GoldCard({
    super.key,
    required this.title,
    required this.purity,
    required this.price,
    required this.percent,
    required this.icon,
    required this.trendUp,
    this.featured = false,
    this.dark = false,
    this.priceLabel = 'pro Gramm',
  });

  final String title;
  final String purity;
  final String price;
  final String percent;
  final IconData icon;
  final bool trendUp;
  final bool featured;
  final bool dark;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2C2720) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: featured ? const Color(0xFFE3BC58) : const Color(0xFFE0D8CC),
          width: featured ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: featured
                ? const Color(0xFFE3BC58).withOpacity(0.18)
                : Colors.black.withOpacity(0.05),
            blurRadius: featured ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (featured)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE3BC58), Color(0xFFBF9B30)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  'Beliebt',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF251A00),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featured) const SizedBox(height: 8),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: dark
                                ? const Color(0xFFF8F0E4)
                                : const Color(0xFF1F1B14),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          purity,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: dark
                                ? const Color(0xFFB09A6A)
                                : const Color(0xFF9A8C78),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: dark
                            ? const Color(0xFF3D3628)
                            : const Color(0xFFFBF2E7),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        icon,
                        color: dark
                            ? const Color(0xFFE3BC58)
                            : const Color(0xFF9C7C38),
                        size: 13,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Price
                Text(
                  price,
                  style: GoogleFonts.manrope(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: dark
                        ? const Color(0xFFF8F0E4)
                        : const Color(0xFF1F1B14),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  priceLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: dark
                        ? const Color(0xFFB09A6A)
                        : const Color(0xFFB0A08A),
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 4),

                // Trend chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 11,
                        color: trendUp
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        percent,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trendUp
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
