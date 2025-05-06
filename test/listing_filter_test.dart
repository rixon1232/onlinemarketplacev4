import 'package:flutter_test/flutter_test.dart';

/// Mirror your widget’s filter logic here
List<Map<String, dynamic>> filterListings(
    List<Map<String, dynamic>> all,
    String query,
    ) {
  final q = query.toLowerCase();
  return all.where((data) {
    final title = (data['title'] ?? '').toString().toLowerCase();
    final desc  = (data['description'] ?? '').toString().toLowerCase();
    return title.contains(q) || desc.contains(q);
  }).toList();
}

void main() {
  final sample = [
    {'title': 'Red car',    'description': 'Fast and light'},
    {'title': 'Blue boat', 'description': 'big boat'},
    {'title': 'Green Coat',  'description': 'Waterproof'},
  ];

  group('filterListings', () {
    test('empty query returns all', () {
      expect(filterListings(sample, ''), sample);
    });
    test('matches title only', () {
      final out = filterListings(sample, 'bike');
      expect(out.length, 1);
      expect(out.first['title'], 'Red Bike');
    });
    test('matches description only', () {
      final out = filterListings(sample, 'waterproof');
      expect(out.length, 1);
      expect(out.first['title'], 'Green Coat');
    });
    test('case‑insensitive', () {
      final out = filterListings(sample, 'HELMET');
      expect(out.length, 1);
      expect(out.first['title'], 'Blue Helmet');
    });
    test('no matches', () {
      expect(filterListings(sample, 'scooter'), isEmpty);
    });
  });
}
