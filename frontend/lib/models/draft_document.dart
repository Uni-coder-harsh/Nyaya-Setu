class DraftDocument {
  final String rawText;
  final List<String> placeholders;

  DraftDocument({required this.rawText, required this.placeholders});

  static DraftDocument fromRaw(String text) {
    // Optimized Regex for placeholder detection
    final regExp = RegExp(r'\[([^\]]+)\]');
    final matches = regExp.allMatches(text);
    final unique = matches.map((m) => m.group(0)!).toSet().toList();
    return DraftDocument(rawText: text, placeholders: unique);
  }

  String applyValues(Map<String, String> values) {
    String processed = rawText;
    values.forEach((key, value) {
      processed = processed.replaceAll(key, value.isEmpty ? key : value);
    });
    return processed;
  }
}