import 'package:ethiopian_datetime/ethiopian_datetime.dart' as et;
import 'package:flutter_test/flutter_test.dart';

import 'package:sunday_school_app/core/dates/ethiopian_date_formatter.dart';

void main() {
  group('EthiopianCalendar conversion', () {
    test('Anchor: Ethiopian new year (Meskerem 1)', () {
      // Commonly observed: Ethiopian year 2016 started on 2023-09-12 (Gregorian).
      final eth = EthiopianCalendar.fromGregorianDate(
        year: 2023,
        month: 9,
        day: 12,
      );
      expect(eth.year, 2016);
      expect(eth.month, 1);
      expect(eth.day, 1);

      expect(EthiopianCalendar.format(eth, includeYear: true), 'መስከረም 1, 2016');
    });

    test('Anchor: Ethiopian Christmas (Tahsas 29)', () {
      // Ethiopian Christmas (Genna) is celebrated on Jan 7 (Gregorian)
      // which corresponds to Tahsas 29 (Ethiopian) in most years.
      final eth = EthiopianCalendar.fromGregorianDate(
        year: 2026,
        month: 1,
        day: 7,
      );
      expect(eth.month, 4); // 4 = ታኅሳስ
      expect(eth.day, 29);
    });

    test('Cross-check vs ethiopian_datetime for a broad sample', () {
      // Validate our algorithm against an external Ethiopian calendar implementation.
      // Using a deterministic sample (no randomness) to keep tests stable.
      for (var year = 1995; year <= 2035; year += 2) {
        for (var month = 1; month <= 12; month++) {
          for (final day in <int>[1, 2, 10, 15, 20, 28]) {
            final dt = DateTime(year, month, day);

            final ours = EthiopianCalendar.fromGregorianDate(
              year: dt.year,
              month: dt.month,
              day: dt.day,
            );

            final theirs = dt.convertToEthiopian();

            expect(
              (ours.year, ours.month, ours.day),
              (theirs.year, theirs.month, theirs.day),
              reason: 'Mismatch for Gregorian ${dt.toIso8601String()}',
            );
          }
        }
      }
    });
  });

  group('EthiopianDateFormatter.formatFlexible', () {
    test('Parses ISO date without timezone drift', () {
      // Ensure we ignore timezone/time parts and only use the YYYY-MM-DD portion.
      final a = EthiopianDateFormatter.formatFlexible('2026-03-05');
      final b = EthiopianDateFormatter.formatFlexible('2026-03-05T23:30:00Z');
      expect(b, a);
    });
  });
}
