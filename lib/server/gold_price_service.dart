import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/gold_rate.dart';

const _apiKey = 'GMDBOXJDJDO7Z0SKBEYS960SKBEYS';

class GoldPriceService {
  Future<GoldRate> fetchSpotPrice() async {
    final uri = Uri.https('api.metals.dev', '/v1/metal/spot', {
      'api_key': _apiKey,
      'metal': 'gold',
      'currency': 'EUR',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return GoldRate.fromJson(data);
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }
}
