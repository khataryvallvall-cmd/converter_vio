class Converter {
  final Map<String, double> fiatRates;
  final Map<String, double> cryptoPrices;

  Converter({required this.fiatRates, required this.cryptoPrices});

  bool _isCrypto(String code) => cryptoPrices.containsKey(code);

  double convert(double amount, String fromCode, String toCode) {
    if (fromCode == toCode) return amount;
    if (amount.isNaN || amount.isInfinite) return 0;

    double amountInUsd;
    if (_isCrypto(fromCode)) {
      final price = cryptoPrices[fromCode];
      if (price == null || price <= 0) return 0;
      amountInUsd = amount * price;
    } else {
      final rate = fiatRates[fromCode];
      if (rate == null || rate <= 0) return 0;
      amountInUsd = amount / rate;
    }

    if (_isCrypto(toCode)) {
      final price = cryptoPrices[toCode];
      if (price == null || price <= 0) return 0;
      return amountInUsd / price;
    } else {
      final rate = fiatRates[toCode];
      if (rate == null || rate <= 0) return 0;
      return amountInUsd * rate;
    }
  }
}
