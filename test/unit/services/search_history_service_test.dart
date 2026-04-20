import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhaven/core/services/search_history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchHistoryService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initialize loads history from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'search_history': ['nature', 'ocean', 'sunset'],
      });

      await SearchHistoryService.initialize();

      expect(SearchHistoryService.history.length, 3);
      expect(SearchHistoryService.history.first, 'nature');
    });

    test('initialize handles empty storage', () async {
      SharedPreferences.setMockInitialValues({});

      await SearchHistoryService.initialize();

      expect(SearchHistoryService.history, isEmpty);
    });

    test('addToHistory inserts query at front and deduplicates', () async {
      SharedPreferences.setMockInitialValues({});
      await SearchHistoryService.initialize();

      await SearchHistoryService.addToHistory('ocean');
      await SearchHistoryService.addToHistory('nature');
      await SearchHistoryService.addToHistory('ocean'); // duplicate → move to front

      expect(SearchHistoryService.history.first, 'ocean');
      expect(SearchHistoryService.history.length, 2);
    });

    test('addToHistory ignores empty query', () async {
      SharedPreferences.setMockInitialValues({});
      await SearchHistoryService.initialize();

      await SearchHistoryService.addToHistory('');
      await SearchHistoryService.addToHistory('   ');

      expect(SearchHistoryService.history, isEmpty);
    });

    test('addToHistory respects maxHistory limit', () async {
      SharedPreferences.setMockInitialValues({});
      await SearchHistoryService.initialize();

      for (int i = 0; i < 25; i++) {
        await SearchHistoryService.addToHistory('query_$i');
      }

      expect(SearchHistoryService.history.length, 20);
      expect(SearchHistoryService.history.first, 'query_24');
      expect(SearchHistoryService.history.last, 'query_5');
    });

    test('removeFromHistory removes specific query', () async {
      SharedPreferences.setMockInitialValues({});
      await SearchHistoryService.initialize();

      await SearchHistoryService.addToHistory('nature');
      await SearchHistoryService.addToHistory('ocean');
      await SearchHistoryService.removeFromHistory('nature');

      expect(SearchHistoryService.history, ['ocean']);
    });

    test('clearHistory removes all queries', () async {
      SharedPreferences.setMockInitialValues({});
      await SearchHistoryService.initialize();

      await SearchHistoryService.addToHistory('a');
      await SearchHistoryService.addToHistory('b');
      await SearchHistoryService.addToHistory('c');

      await SearchHistoryService.clearHistory();

      expect(SearchHistoryService.history, isEmpty);
    });

    test('history returns unmodifiable list', () async {
      SharedPreferences.setMockInitialValues({});
      await SearchHistoryService.initialize();

      await SearchHistoryService.addToHistory('test');

      expect(
        () => (SearchHistoryService.history as List).add('should_fail'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('hotSearches contains expected keywords', () {
      expect(SearchHistoryService.hotSearches, contains('nature'));
      expect(SearchHistoryService.hotSearches, contains('mountain'));
      expect(SearchHistoryService.hotSearches, contains('city'));
    });
  });
}
