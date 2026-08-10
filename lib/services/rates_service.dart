import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RatesService {
  static const _fiatCacheKey = 'fiatRatesCache';
  static const _fiatCacheTimeKey = 'fiatRatesCacheTime';
  static const _cryptoCacheKey = 'cryptoRatesCache';

  static const Map<String, String> geckoIds = {
    'BTC': 'bitcoin', 'ETH': 'ethereum', 'USDT': 'tether', 'XRP': 'ripple',
    'BNB': 'binancecoin', 'SOL': 'solana', 'USDC': 'usd-coin', 'DOGE': 'dogecoin',
    'TRX': 'tron', 'ADA': 'cardano', 'HYPE': 'hyperliquid', 'XLM': 'stellar',
    'SUI': 'sui', 'LINK': 'chainlink', 'BCH': 'bitcoin-cash', 'HBAR': 'hedera-hashgraph',
    'AVAX': 'avalanche-2', 'LTC': 'litecoin', 'TON': 'the-open-network', 'SHIB': 'shiba-inu',
    'DOT': 'polkadot', 'XMR': 'monero', 'UNI': 'uniswap', 'ETC': 'ethereum-classic',
    'APT': 'aptos', 'NEAR': 'near', 'ICP': 'internet-computer', 'PEPE': 'pepe',
    'AAVE': 'aave', 'CRO': 'crypto-com-chain',
  };

  Future<Map<String, double>?> fetchFiatRates() async {
    Map<String, double>? result;

    Future<Map<String, double>?> tryUrl(String url) async {
      try {
        final r = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 8));
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body);
          final usd = data['usd'] as Map<String, dynamic>?;
          if (usd != null && usd.length > 100) {
            final rates = <String, double>{'USD': 1};
            usd.forEach((k, v) {
              final val = (v as num).toDouble();
              rates[k.toUpperCase()] = val;
            });
            return rates;
          }
        }
      } catch (_) {}
      return null;
    }

    result = await tryUrl(
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json');
    result ??= await tryUrl(
        'https://latest.currency-api.pages.dev/v1/currencies/usd.min.json');

    if (result != null) {
      final eur = result['EUR'];
      if (eur != null) {
        result['XOF'] = eur * 655.957;
        result['XAF'] = eur * 655.957;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fiatCacheKey, jsonEncode(result));
      await prefs.setString(
          _fiatCacheTimeKey, DateTime.now().millisecondsSinceEpoch.toString());
      return result;
    }

    return await _loadCachedFiat();
  }

  Future<Map<String, double>?> _loadCachedFiat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_fiatCacheKey);
      if (saved != null) {
        final parsed = jsonDecode(saved) as Map<String, dynamic>;
        return parsed.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, double>?> fetchCryptoRates() async {
    try {
      final ids = geckoIds.values.join(',');
      final r = await http
          .get(Uri.parse(
              'https://api.coingecko.com/api/v3/simple/price?ids=$ids&vs_currencies=usd'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        if (data['bitcoin'] != null && data['bitcoin']['usd'] != null) {
          final cache = <String, double>{};
          geckoIds.forEach((code, gid) {
            final entry = data[gid];
            cache[code] = entry != null && entry['usd'] != null
                ? (entry['usd'] as num).toDouble()
                : 0;
          });
          cache['USDT'] = cache['USDT'] == 0 ? 1 : cache['USDT']!;
          cache['USDC'] = cache['USDC'] == 0 ? 1 : cache['USDC']!;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cryptoCacheKey, jsonEncode(cache));
          return cache;
        }
      }
    } catch (_) {}

    try {
      const symbols = [
        'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'XRPUSDT', 'DOGEUSDT',
        'ADAUSDT', 'TRXUSDT', 'AVAXUSDT', 'LINKUSDT', 'TONUSDT', 'LTCUSDT',
        'BCHUSDT', 'DOTUSDT', 'ETCUSDT', 'SHIBUSDT', 'UNIUSDT',
      ];
      final r = await http
          .get(Uri.parse(
              'https://api.binance.com/api/v3/ticker/price?symbols=${jsonEncode(symbols)}'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as List<dynamic>;
        final pm = <String, double>{};
        for (final item in data) {
          pm[item['symbol']] = double.tryParse(item['price']) ?? 0;
        }
        if (pm['BTCUSDT'] != null) {
          final cache = <String, double>{
            'BTC': pm['BTCUSDT'] ?? 0, 'ETH': pm['ETHUSDT'] ?? 0, 'USDT': 1,
            'BNB': pm['BNBUSDT'] ?? 0, 'SOL': pm['SOLUSDT'] ?? 0,
            'XRP': pm['XRPUSDT'] ?? 0, 'USDC': 1, 'DOGE': pm['DOGEUSDT'] ?? 0,
            'ADA': pm['ADAUSDT'] ?? 0, 'TRX': pm['TRXUSDT'] ?? 0,
            'AVAX': pm['AVAXUSDT'] ?? 0, 'LINK': pm['LINKUSDT'] ?? 0,
            'TON': pm['TONUSDT'] ?? 0, 'LTC': pm['LTCUSDT'] ?? 0,
            'BCH': pm['BCHUSDT'] ?? 0, 'DOT': pm['DOTUSDT'] ?? 0,
            'ETC': pm['ETCUSDT'] ?? 0, 'SHIB': pm['SHIBUSDT'] ?? 0,
            'UNI': pm['UNIUSDT'] ?? 0,
            'HYPE': 0, 'XLM': 0, 'SUI': 0, 'HBAR': 0, 'XMR': 0, 'APT': 0,
            'NEAR': 0, 'ICP': 0, 'PEPE': 0, 'AAVE': 0, 'CRO': 0,
          };
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cryptoCacheKey, jsonEncode(cache));
          return cache;
        }
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_cryptoCacheKey);
      if (saved != null) {
        final parsed = jsonDecode(saved) as Map<String, dynamic>;
        final cache = parsed.map((k, v) => MapEntry(k, (v as num).toDouble()));
        if ((cache['BTC'] ?? 0) > 100) return cache;
      }
    } catch (_) {}
    return null;
  }
}
