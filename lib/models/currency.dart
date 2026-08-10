class Currency {
  final String code;
  final String nameAr;
  final String nameEn;
  final String nameFr;
  final String icon;
  final bool isCrypto;

  const Currency({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
    required this.icon,
    required this.isCrypto,
  });

  String nameFor(String langCode) {
    switch (langCode) {
      case 'en':
        return nameEn;
      case 'fr':
        return nameFr;
      case 'ar':
      default:
        return nameAr;
    }
  }

  @override
  String toString() => 'Currency($code)';
}
