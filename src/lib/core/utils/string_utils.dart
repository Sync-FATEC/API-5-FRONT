class StringUtils {
  static bool containsIgnoreCase(String haystack, String needle) {
    return haystack.toLowerCase().contains(needle.toLowerCase());
  }

  static List<T> filterByQuery<T>(List<T> items, String query, String Function(T) labelGetter) {
    final q = query.trim();
    if (q.isEmpty) return items;
    return items.where((e) => containsIgnoreCase(labelGetter(e), q)).toList();
  }
}

