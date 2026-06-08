class RegPatterns {
  static final RegExp url = RegExp(r'https?://\S+');
  static final RegExp email = RegExp(r'\S+@\S+');
  static final RegExp phone = RegExp(r'\+?\d[\d\s-]{8,}\d');

  static final RegExp any = RegExp(
    '(?:${url.pattern})|'
    '(?:${email.pattern})|'
    '(?:${phone.pattern})',
  );
}

extension RegPatternsExtension on String {
  String? firstUrl() => RegPatterns.url.firstMatch(this)?.group(0);

  String? firstEmail() => RegPatterns.email.firstMatch(this)?.group(0);

  String? firstPhone() => RegPatterns.phone.firstMatch(this)?.group(0);
}

List<String> matches(String text, RegExp regExp) {
  return regExp.allMatches(text).map((m) => m.group(0)!).toList();
}
