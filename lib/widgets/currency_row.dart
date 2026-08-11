import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/currency.dart';
import '../theme/app_theme.dart';
import '../utils/flag_emoji.dart';

class CurrencyRow extends StatefulWidget {
  final Currency currency;
  final String displayValue;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onTapSelector;

  const CurrencyRow({
    super.key,
    required this.currency,
    required this.displayValue,
    required this.isActive,
    required this.onActivate,
    required this.onTapSelector,
  });

  @override
  State<CurrencyRow> createState() => _CurrencyRowState();
}

class _CurrencyRowState extends State<CurrencyRow> {
  OverlayEntry? _copyPopup;

  void _showCopyPopup(BuildContext context) {
    if (widget.displayValue == '0') return;

    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _copyPopup?.remove();
    _copyPopup = OverlayEntry(
      builder: (ctx) => Positioned(
        left: offset.dx + size.width / 2 - 50,
        top: offset.dy - 48,
        child: _CopyBubble(
          value: widget.displayValue,
          onDone: () => _copyPopup?.remove(),
        ),
      ),
    );
    Overlay.of(context).insert(_copyPopup!);
  }

  @override
  void dispose() {
    _copyPopup?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 60;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onTapSelector,
            child: Container(
              height: rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.rowGrey,
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.currency.isCrypto
                        ? widget.currency.code.substring(0, 1)
                        : flagEmoji(widget.currency.icon),
                    style: TextStyle(
                      fontSize: widget.currency.isCrypto ? 18 : 22,
                      color: widget.currency.isCrypto ? AppColors.brandOrange : null,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.currency.code,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Tajawal',
                          fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: widget.onActivate,
              onLongPress: () => _showCopyPopup(context),
              child: Container(
                height: rowHeight,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: widget.isActive ? AppColors.activeRowBrown : AppColors.rowGrey,
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.displayValue,
                      style: TextStyle(
                        color: widget.isActive ? AppColors.brandOrange : Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyBubble extends StatefulWidget {
  final String value;
  final VoidCallback onDone;
  const _CopyBubble({required this.value, required this.onDone});

  @override
  State<_CopyBubble> createState() => _CopyBubbleState();
}

class _CopyBubbleState extends State<_CopyBubble> {
  bool _copied = false;

  Future<void> _handleTap() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _copied ? const Color(0xFF1A3A1A) : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _copied ? '✓ تم' : '📋 نسخ',
            style: TextStyle(
              color: _copied ? AppColors.success : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ),
    );
  }
}
