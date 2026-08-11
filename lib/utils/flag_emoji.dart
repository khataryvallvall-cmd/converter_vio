String flagEmoji(String countryCode) {
  if (countryCode.length != 2) return '🏳️';
  final code = countryCode.toUpperCase();
  final first = 0x1F1E6 + (code.codeUnitAt(0) - 'A'.codeUnitAt(0));
  final second = 0x1F1E6 + (code.codeUnitAt(1) - 'A'.codeUnitAt(0));
  return String.fromCharCode(first) + String.fromCharCode(second);
}
