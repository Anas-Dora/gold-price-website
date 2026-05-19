class GoldRate {
  final double price;
  final double changePercent;

  const GoldRate({required this.price, required this.changePercent});

  factory GoldRate.fromJson(Map<String, dynamic> json) {
    final rate = json['rate'] as Map<String, dynamic>;
    return GoldRate(
      price: (rate['price'] as num).toDouble(),
      changePercent: (rate['change_percent'] as num).toDouble(),
    );
  }
}
