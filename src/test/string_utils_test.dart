import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/core/utils/string_utils.dart';

void main() {
  group('StringUtils.containsIgnoreCase', () {
    test('matches case-insensitive contains', () {
      expect(StringUtils.containsIgnoreCase('Maria Souza', 'maria'), true);
      expect(StringUtils.containsIgnoreCase('João Silva', 'SIL'), true);
      expect(StringUtils.containsIgnoreCase('Exame de Sangue', 'de s'), true);
      expect(StringUtils.containsIgnoreCase('Teste', 'xyz'), false);
    });
  });

  group('StringUtils.filterByQuery', () {
    test('filters by substring ignoring case', () {
      final items = ['Ana Paula', 'Bruno', 'Carlos', 'Paula'];
      final filtered = StringUtils.filterByQuery<String>(items, 'paul', (s) => s);
      expect(filtered, ['Ana Paula', 'Paula']);
    });

    test('returns all when query empty', () {
      final items = ['A', 'B'];
      final filtered = StringUtils.filterByQuery<String>(items, '', (s) => s);
      expect(filtered, items);
    });
  });
}

