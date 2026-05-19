import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'viewmodels/gold_price_viewmodel.dart';
import 'widgets/gold_card.dart';
import 'widgets/pulsing_dot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GoldPriceViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = GoldPriceViewModel();
    _vm.init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFFF5EFE6),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 72,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'DURRAH',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 96,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 12,
                              color: const Color(0xFF1F1B14),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _goldDivider(),
                              const SizedBox(width: 18),
                              Text(
                                'J U W E L I E R',
                                style: GoogleFonts.manrope(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 8,
                                  color: const Color(0xFF9C7C38),
                                ),
                              ),
                              const SizedBox(width: 18),
                              _goldDivider(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Echtgold. Echte Preise. Jeden Tag.',
                            style: GoogleFonts.manrope(
                              fontSize: 22,
                              color: const Color(0xFF7A6A52),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 72),

                    // ── Section title + live badge ───────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Live Goldpreise',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F1B14),
                          ),
                        ),
                        const Spacer(),
                        _liveBadge(),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Preise pro Gramm · Basis: Spotpreis XAU/EUR',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        color: const Color(0xFF9A8C78),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Price grid ──────────────────────────────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth < 500
                            ? 1
                            : constraints.maxWidth < 800
                            ? 2
                            : 3;

                        if (_vm.isLoading) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF9C7C38),
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }

                        if (_vm.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 40,
                                    color: Color(0xFF9A8C78),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Preise konnten nicht geladen werden.',
                                    style: GoogleFonts.manrope(
                                      color: const Color(0xFF7A6A52),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: _vm.fetchPrice,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Erneut versuchen'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF9C7C38),
                                      side: const BorderSide(
                                        color: Color(0xFF9C7C38),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return GridView.count(
                          crossAxisCount: cols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.1,
                          children: [
                            GoldCard(
                              title: '24 Karat',
                              purity: '999,9 ‰',
                              price: _vm.fmt(_vm.karatPrice(24)),
                              percent: _vm.fmtPct(_vm.changePercent),
                              icon: Icons.stars_rounded,
                              trendUp: _vm.changePercent >= 0,
                            ),
                            GoldCard(
                              title: '22 Karat',
                              purity: '916 ‰',
                              price: _vm.fmt(_vm.karatPrice(22)),
                              percent: _vm.fmtPct(_vm.changePercent),
                              icon: Icons.stars_rounded,
                              trendUp: _vm.changePercent >= 0,
                            ),
                            GoldCard(
                              title: '21 Karat',
                              purity: '875 ‰',
                              price: _vm.fmt(_vm.karatPrice(21)),
                              percent: _vm.fmtPct(_vm.changePercent),
                              icon: Icons.workspace_premium_rounded,
                              trendUp: _vm.changePercent >= 0,
                              featured: true,
                            ),
                            GoldCard(
                              title: '18 Karat',
                              purity: '750 ‰',
                              price: _vm.fmt(_vm.karatPrice(18)),
                              percent: _vm.fmtPct(_vm.changePercent),
                              icon: Icons.diamond_rounded,
                              trendUp: _vm.changePercent >= 0,
                            ),
                            GoldCard(
                              title: '14 Karat',
                              purity: '585 ‰',
                              price: _vm.fmt(_vm.karatPrice(14)),
                              percent: _vm.fmtPct(_vm.changePercent),
                              icon: Icons.hexagon_outlined,
                              trendUp: _vm.changePercent >= 0,
                            ),
                            GoldCard(
                              title: 'Unze (Troy)',
                              purity: '31,1 g',
                              price: _vm.fmt(_vm.pricePerToz),
                              percent: _vm.fmtPct(_vm.changePercent),
                              icon: Icons.monetization_on_rounded,
                              trendUp: _vm.changePercent >= 0,
                              dark: true,
                              priceLabel: 'pro Unze',
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 60),

                    // ── Footer info bar ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE5D8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD0C5B1)),
                      ),
                      child: Wrap(
                        spacing: 48,
                        runSpacing: 16,
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          _infoChip(
                            Icons.info_outline_rounded,
                            'Alle Preise zzgl. MwSt.',
                          ),
                          _infoChip(
                            Icons.sync_rounded,
                            'Aktualisierung alle 30 Min.',
                          ),
                          _infoChip(
                            Icons.store_rounded,
                            'Abholpreis im Geschäft',
                          ),
                          _infoChip(
                            Icons.verified_outlined,
                            'Zertifiziertes Echtgold',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    Center(
                      child: Text(
                        '© 2026 Durrah Juwelier · Alle Rechte vorbehalten',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          color: const Color(0xFFB0A08A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _goldDivider() => Container(
    width: 72,
    height: 2.5,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFE3BC58), Color(0xFFBF9B30)]),
    ),
  );

  Widget _liveBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
    decoration: BoxDecoration(
      color: const Color(0xFFFBF2E7),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFFD0C5B1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PulsingDot(),
        const SizedBox(width: 12),
        Text(
          _vm.lastUpdatedLabel,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4D4637),
          ),
        ),
      ],
    ),
  );

  Widget _infoChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 22, color: const Color(0xFF9C7C38)),
      const SizedBox(width: 10),
      Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 18,
          color: const Color(0xFF5C4F3A),
        ),
      ),
    ],
  );
}
