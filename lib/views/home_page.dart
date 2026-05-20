import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/gold_price_viewmodel.dart';
import 'widgets/gold_card.dart';
import 'widgets/pulsing_dot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GoldPriceViewModel _vm;
  StreamSubscription<DocumentSnapshot>? _refreshSub;
  Timestamp? _lastRefreshTs;
  double _textScale = 1.0;

  static const _scaleKey = 'text_scale';

  @override
  void initState() {
    super.initState();
    _vm = GoldPriceViewModel();
    _vm.init();
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getDouble(_scaleKey);
      if (saved != null && mounted) setState(() => _textScale = saved);
    });
    _refreshSub = FirebaseFirestore.instance
        .collection('preise')
        .doc('n6SFfgb2zkKYG6LswSqf')
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists) return;
          final data = snapshot.data() as Map<String, dynamic>;
          final ts = data['refresh_zuletzt_gedrueckt'] as Timestamp?;
          if (ts != null && ts != _lastRefreshTs) {
            _lastRefreshTs = ts;
            _vm.fetchPrice();
          }
        });
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(_textScale)),
        child: Scaffold(
          backgroundColor: const Color(0xFFF5EFE6),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 6,
                                color: const Color(0xFF1F1B14),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _goldDivider(),
                                const SizedBox(width: 8),
                                Text(
                                  'J U W E L I E R',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 4,
                                    color: const Color(0xFF9C7C38),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _goldDivider(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Echtgold. Echte Preise. Jeden Tag.',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: const Color(0xFF7A6A52),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Section title + live badge ───────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Live Goldpreise',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F1B14),
                            ),
                          ),
                          const Spacer(),
                          _fontScaleButtons(),
                          const SizedBox(width: 8),
                          _liveBadge(),
                        ],
                      ),

                      const SizedBox(height: 2),
                      Text(
                        'Preise pro Gramm · Basis: Spotpreis XAU/EUR',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: const Color(0xFF9A8C78),
                        ),
                      ),

                      const SizedBox(height: 8),

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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
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
                                        foregroundColor: const Color(
                                          0xFF9C7C38,
                                        ),
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
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.1,
                            children: [
                              GoldCard(
                                title: '24 Karat',
                                purity: '999,9 ‰',
                                price: _vm.fmt(_vm.karatPrice(24)),
                                percent: _vm.fmtPct(_vm.changePercent),
                                trendUp: _vm.changePercent >= 0,
                                showTrendChip: true,
                              ),
                              GoldCard(
                                title: '22 Karat',
                                purity: '916 ‰',
                                price: _vm.fmt(_vm.karatPrice(22)),
                                percent: _vm.fmtPct(_vm.changePercent),
                                trendUp: _vm.changePercent >= 0,
                              ),
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('preise')
                                    .doc('n6SFfgb2zkKYG6LswSqf')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final String price21k;
                                  if (snapshot.hasData &&
                                      snapshot.data!.exists) {
                                    final data =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;
                                    final raw = data['gold_21k'];
                                    price21k = _vm.fmt((raw as num).toDouble());
                                  } else {
                                    price21k = _vm.fmt(_vm.karatPrice(21));
                                  }
                                  return GoldCard(
                                    title: '21 Karat',
                                    purity: '875 ‰',
                                    price: price21k,
                                    percent: _vm.fmtPct(_vm.changePercent),
                                    trendUp: _vm.changePercent >= 0,
                                    featured: true,
                                  );
                                },
                              ),
                              GoldCard(
                                title: '18 Karat',
                                purity: '750 ‰',
                                price: _vm.fmt(_vm.karatPrice(18)),
                                percent: _vm.fmtPct(_vm.changePercent),
                                trendUp: _vm.changePercent >= 0,
                              ),
                              GoldCard(
                                title: '14 Karat',
                                purity: '585 ‰',
                                price: _vm.fmt(_vm.karatPrice(14)),
                                percent: _vm.fmtPct(_vm.changePercent),
                                trendUp: _vm.changePercent >= 0,
                              ),
                              GoldCard(
                                title: 'Unze (Troy)',
                                purity: '31,1 g',
                                price: _vm.fmt(_vm.pricePerToz),
                                percent: _vm.fmtPct(_vm.changePercent),
                                trendUp: _vm.changePercent >= 0,
                                dark: true,
                                priceLabel: 'pro Unze',
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // ── Footer info bar ──────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE5D8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD0C5B1)),
                        ),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 6,
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

                      const SizedBox(height: 4),

                      Center(
                        child: Text(
                          '© 2026 Durrah Juwelier · Alle Rechte vorbehalten',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
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
      ),
    );
  }

  Widget _fontScaleButtons() => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFBF2E7),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFFD0C5B1)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _scaleBtn(
          icon: Icons.text_decrease_rounded,
          tooltip: 'Schrift verkleinern',
          onPressed: _textScale > 0.7
              ? () {
                  final v = double.parse((_textScale - 0.1).toStringAsFixed(1));
                  setState(() => _textScale = v);
                  SharedPreferences.getInstance().then(
                    (p) => p.setDouble(_scaleKey, v),
                  );
                }
              : null,
        ),
        Container(width: 1, height: 16, color: const Color(0xFFD0C5B1)),
        _scaleBtn(
          icon: Icons.text_increase_rounded,
          tooltip: 'Schrift vergrößern',
          onPressed: _textScale < 1.8
              ? () {
                  final v = double.parse((_textScale + 0.1).toStringAsFixed(1));
                  setState(() => _textScale = v);
                  SharedPreferences.getInstance().then(
                    (p) => p.setDouble(_scaleKey, v),
                  );
                }
              : null,
        ),
      ],
    ),
  );

  Widget _scaleBtn({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Icon(
          icon,
          size: 14,
          color: onPressed != null
              ? const Color(0xFF9C7C38)
              : const Color(0xFFD0C5B1),
        ),
      ),
    ),
  );

  Widget _goldDivider() => Container(
    width: 28,
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFE3BC58), Color(0xFFBF9B30)]),
    ),
  );

  Widget _liveBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        const SizedBox(width: 6),
        Text(
          _vm.lastUpdatedLabel,
          style: GoogleFonts.manrope(
            fontSize: 12,
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
      Icon(icon, size: 11, color: const Color(0xFF9C7C38)),
      const SizedBox(width: 4),
      Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          color: const Color(0xFF5C4F3A),
        ),
      ),
    ],
  );
}
