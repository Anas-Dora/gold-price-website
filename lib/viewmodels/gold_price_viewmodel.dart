import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/gold_rate.dart';
import '../server/gold_price_service.dart';

const _gramsPerTroyOz = 31.1034768;

class GoldPriceViewModel extends ChangeNotifier {
  final _service = GoldPriceService();
  GoldRate? _rate;
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _lastUpdated;
  Timer? _fetchTimer; // fires every 30 min → API call

  // ── Getters ──────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  double get changePercent => _rate?.changePercent ?? 0;
  double get pricePerToz => _rate?.price ?? 0;

  double get _gramPrice24k => pricePerToz / _gramsPerTroyOz;
  double karatPrice(int karat) => _gramPrice24k * karat / 24;

  String get lastUpdatedLabel {
    if (_lastUpdated == null) return 'Wird geladen…';
    final diff = DateTime.now().difference(_lastUpdated!);
    if (diff.inSeconds < 60) return 'Gerade aktualisiert';
    if (diff.inMinutes == 1) return 'Vor 1 Minute aktualisiert';
    if (diff.inMinutes < 60) {
      return 'Vor ${diff.inMinutes} Minuten aktualisiert';
    }
    if (diff.inHours == 1) return 'Vor 1 Stunde aktualisiert';
    return 'Vor ${diff.inHours} Stunden aktualisiert';
  }

  // ── Formatters ───────────────────────────────────────────────────────────

  String fmt(double price) {
    final parts = price.toStringAsFixed(2).split('.');
    final integer = parts[0];
    final decimal = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buf.write('.');
      buf.write(integer[i]);
    }
    return '$buf,$decimal €';
  }

  String fmtPct(double pct) =>
      '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)} %';

  // ── Lifecycle ────────────────────────────────────────────────────────────

  void init() {
    fetchPrice();
    _fetchTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => fetchPrice(),
    );
  }

  Future<void> fetchPrice() async {
    if (_rate == null) _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _rate = await _service.fetchSpotPrice();
      _isLoading = false;
      _lastUpdated = DateTime.now();
    } catch (_) {
      _hasError = true;
      _isLoading = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }
}
