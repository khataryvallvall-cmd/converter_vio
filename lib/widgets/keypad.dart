import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Keypad extends StatelessWidget {
  final void Function(String digit) onDigit;
  final void Function() onDecimal;
  final void Function() onClear;
  final void Function() onBackspace;
  final void Function() onPercent;
  final void Function(String op) onOperator;
  final void Function() onEqual;

  const Keypad({
    super.key,
    required this.onDigit,
    required this.onDecimal,
    required this.onClear,
    required this.onBackspace,
    required this.onPercent,
    required this.onOperator,
    required this.onEqual,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Row(children: [
          _KeyButton(label: 'C', style: _KeyStyle.muted, onTap: onClear),
          _KeyButton(icon: Icons.arrow_back, style: _KeyStyle.muted, onTap: onBackspace),
          _KeyButton(label: '%', style: _KeyStyle.muted, onTap: onPercent),
          _KeyButton(label: '÷', style: _KeyStyle.operatorKey, onTap: () => onOperator('divide')),
        ])),
        Expanded(child: Row(children: [
          _KeyButton(label: '7', onTap: () => onDigit('7')),
          _KeyButton(label: '8', onTap: () => onDigit('8')),
          _KeyButton(label: '9', onTap: () => onDigit('9')),
          _KeyButton(label: '×', style: _KeyStyle.operatorKey, onTap: () => onOperator('multiply')),
        ])),
        Expanded(child: Row(children: [
          _KeyButton(label: '4', onTap: () => onDigit('4')),
          _KeyButton(label: '5', onTap: () => onDigit('5')),
          _KeyButton(label: '6', onTap: () => onDigit('6')),
          _KeyButton(label: '−', style: _KeyStyle.operatorKey, onTap: () => onOperator('subtract')),
        ])),
        Expanded(child: Row(children: [
          _KeyButton(label: '1', onTap: () => onDigit('1')),
          _KeyButton(label: '2', onTap: () => onDigit('2')),
          _KeyButton(label: '3', onTap: () => onDigit('3')),
          _KeyButton(label: '+', style: _KeyStyle.operatorKey, onTap: () => onOperator('add')),
        ])),
        Expanded(child: Row(children: [
          _KeyButton(label: '0', onTap: () => onDigit('0')),
          _KeyButton(label: '.', onTap: onDecimal),
          _KeyButton(label: '=', style: _KeyStyle.operatorKey, onTap: onEqual),
          const _KeySpacer(),
        ])),
      ],
    );
  }
}

enum _KeyStyle { normal, muted, operatorKey }

class _KeySpacer extends StatelessWidget {
  const _KeySpacer();
  @override
  Widget build(BuildContext context) => const Expanded(child: SizedBox());
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final int flex;
  final _KeyStyle style;
  final VoidCallback onTap;

  const _KeyButton({
    this.label,
    this.icon,
    this.flex = 1,
    this.style = _KeyStyle.normal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (style) {
      case _KeyStyle.muted:
        bg = AppColors.secondaryGrey;
        fg = Colors.black;
        break;
      case _KeyStyle.operatorKey:
        bg = AppColors.brandOrange;
        fg = Colors.white;
        break;
      case _KeyStyle.normal:
        bg = AppColors.rowGrey;
        fg = Colors.white;
        break;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: fg, size: 26)
                  : Text(
                      label ?? '',
                      style: TextStyle(
                        color: fg,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Tajawal',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
