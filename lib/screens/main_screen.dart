import 'dart:async';
import 'package:flutter/material.dart';
import '../data/fiat_currencies.dart';
import '../models/currency.dart';
import '../services/calculator_engine.dart';
import '../services/converter.dart';
import '../services/rates_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/currency_row.dart';
import '../widgets/keypad.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final RatesService _ratesService = RatesService();
  final CalculatorEngine _calc = CalculatorEngine();

  Map<String, double> _fiatRates = {'USD': 1};
  Map<String, double> _cryptoPrices = {};

  final List<Currency> _rowCurrencies = [
    fiatCurrencies.firstWhere((c) => c.code == 'USD'),
    fiatCurrencies.firstWhere((c) => c.code == 'EUR'),
    fiatCurrencies.firstWhere((c) => c.code == 'GBP'),
    fiatCurrencies.firstWhere((c) => c.code == 'CNY'),
  ];

  int _activeRowIndex = 0;
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _loadRates();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  String get _formattedNow {
    final d = _now;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}   $hh:$mm';
  }

  Future<void> _loadRates() async {
    final fiat = await _ratesService.fetchFiatRates();
    final crypto = await _ratesService.fetchCryptoRates();
    if (!mounted) return;
    setState(() {
      if (fiat != null) _fiatRates = fiat;
      if (crypto != null) _cryptoPrices = crypto;
    });
  }

  Converter get _converter =>
      Converter(fiatRates: _fiatRates, cryptoPrices: _cryptoPrices);

  String _valueForRow(int index) {
    if (index == _activeRowIndex) {
      return _calc.displayValue;
    }
    final activeValue = double.tryParse(_calc.displayValue) ?? 0;
    final converted = _converter.convert(
      activeValue,
      _rowCurrencies[_activeRowIndex].code,
      _rowCurrencies[index].code,
    );
    return _formatConverted(converted);
  }

  String _formatConverted(double v) {
    if (v == 0) return '0';
    final rounded = double.parse(v.toStringAsFixed(v.abs() < 1 ? 6 : 2));
    if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
    return rounded.toString();
  }

  void _onDigit(String d) => setState(() => _calc.inputDigit(d));
  void _onDecimal() => setState(() => _calc.inputDecimal());
  void _onClear() => setState(() => _calc.handleClear());
  void _onBackspace() => setState(() => _calc.handleBackspace());
  void _onPercent() => setState(() => _calc.handlePercent());
  void _onEqual() => setState(() => _calc.handleEqual());

  void _onOperator(String opName) {
    final op = {
      'add': CalcOperator.add,
      'subtract': CalcOperator.subtract,
      'multiply': CalcOperator.multiply,
      'divide': CalcOperator.divide,
    }[opName]!;
    setState(() => _calc.handleOperator(op));
  }

  void _activateRow(int index) {
    if (index == _activeRowIndex) return;
    setState(() {
      final currentDisplayed = _valueForRow(index);
      _activeRowIndex = index;
      _calc.displayValue = currentDisplayed == '0' ? '0' : currentDisplayed;
      _calc.firstOperand = null;
      _calc.operator = null;
      _calc.waitingForSecondOperand = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.appMaxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildTopIcons(),
                  const SizedBox(height: 10),
                  Column(
                    children: List.generate(_rowCurrencies.length, (i) {
                      return CurrencyRow(
                        currency: _rowCurrencies[i],
                        displayValue: _valueForRow(i),
                        isActive: i == _activeRowIndex,
                        onActivate: () => _activateRow(i),
                        onTapSelector: () {},
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Keypad(
                      onDigit: _onDigit,
                      onDecimal: _onDecimal,
                      onClear: _onClear,
                      onBackspace: _onBackspace,
                      onPercent: _onPercent,
                      onOperator: _onOperator,
                      onEqual: _onEqual,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 14),
                    child: Column(
                      children: [
                        const Text(
                          'Converter Vio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            _formattedNow,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              Color(0x38FF9800),
              Color(0x1AFF9800),
              Color(0x00FF9800),
            ]),
          ),
          child: Center(child: AppIcons.bank(size: 22)),
        ),
        const SizedBox(width: 12),
        AppIcons.gear(size: 24),
      ],
    );
  }
}
