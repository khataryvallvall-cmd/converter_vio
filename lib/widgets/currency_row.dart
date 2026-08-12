import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/flag_icons.dart';
import '../models/currency.dart';
import '../theme/app_theme.dart';

OverlayEntry? _globalCopyPopup;

String _withThousandsSeparator(String value) {
  final isNegative = value.startsWith('-');
  final clean = isNegative ? value.substring(1) : value;
  final parts = clean.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
  }
  final result = parts.length > 1 ? '${buffer.toString()}.${parts[1]}' : buffer.toString();
  return isNegative ? '-$result' : result;
}

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
  void _showCopyPopup(BuildContext context) {
    if (widget.displayValue == '0') return;

    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _globalCopyPopup?.remove();
    _globalCopyPopup = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: offset.dx + size.width / 2 - 55,
        top: offset.dy - 56,
        child: _CopyBubble(
          value: widget.displayValue,
          onDone: () {
            if (_globalCopyPopup == entry) {
              entry.remove();
              _globalCopyPopup = null;
            }
          },
        ),
      ),
    );
    _globalCopyPopup = entry;
    Overlay.of(context).insert(entry);
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
                  ClipOval(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: widget.currency.isCrypto
                          ? Container(
                              color: AppColors.brandOrange.withOpacity(0.2),
                              alignment: Alignment.center,
                              child: Text(
                                widget.currency.code.substring(0, 1),
                                style: const TextStyle(
                                    color: AppColors.brandOrange,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13),
                              ),
                            )
                          : (flagIcons[widget.currency.icon] != null
                              ? SvgPicture.string(
                                  flagIcons[widget.currency.icon]!,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.white24)),
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
                      _withThousandsSeparator(widget.displayValue),
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
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = _copied ? const Color(0xFF1A3A1A) : const Color(0xFF2A2A2A);
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _copied ? 'تم' : '📋 نسخ',
                style: TextStyle(
                  color: _copied ? AppColors.success : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            CustomPaint(
              size: const Size(14, 7),
              painter: _TrianglePainter(color: bg),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}
