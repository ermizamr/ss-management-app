class EthiopianDate {
  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}

class EthiopianCalendar {
  static const List<String> monthNames = <String>[
    'መስከረም',
    'ጥቅምት',
    'ኅዳር',
    'ታኅሳስ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሐሴ',
    'ጳጉሜን',
  ];

  // Ethiopic epoch in Julian Day Number (JDN).
  // This constant is widely used in calendrical conversion algorithms.
  static const int _ethiopicEpochJdn = 1723856;

  static EthiopianDate fromGregorianDate({
    required int year,
    required int month,
    required int day,
  }) {
    final jdn = _gregorianToJdn(year: year, month: month, day: day);
    return _ethiopicFromJdn(jdn);
  }

  static EthiopianDate fromGregorianDateTime(DateTime date) {
    return fromGregorianDate(year: date.year, month: date.month, day: date.day);
  }

  static int _gregorianToJdn({
    required int year,
    required int month,
    required int day,
  }) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    return day +
        ((153 * m + 2) ~/ 5) +
        (365 * y) +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  static EthiopianDate _ethiopicFromJdn(int jdn) {
    final days = jdn - _ethiopicEpochJdn;
    final n = days ~/ 1461;
    final r = days % 1461;

    var yearIndex = r ~/ 365;
    if (yearIndex == 4) yearIndex = 3;

    final year = 4 * n + yearIndex;
    final dayOfYear = r - 365 * yearIndex;
    final month = (dayOfYear ~/ 30) + 1;
    final day = (dayOfYear % 30) + 1;

    return EthiopianDate(year: year, month: month, day: day);
  }

  static String format(EthiopianDate date, {required bool includeYear}) {
    final name = monthNames[(date.month - 1).clamp(0, monthNames.length - 1)];
    if (!includeYear) {
      return '$name ${date.day}';
    }
    return '$name ${date.day}, ${date.year}';
  }
}

class EthiopianDateFormatter {
  static final Map<String, int> _englishMonthIndex = <String, int>{
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  static String formatFlexible(String input, {DateTime? now}) {
    final raw = input.trim();
    if (raw.isEmpty) return raw;

    final today = now ?? DateTime.now();

    // ISO date or datetime: 2026-03-05 or 2026-03-05T12:34:56Z
    final isoLike = RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(raw);
    if (isoLike) {
      final datePart = raw.length >= 10 ? raw.substring(0, 10) : raw;
      final pieces = datePart.split('-');
      if (pieces.length != 3) return input;

      final y = int.tryParse(pieces[0]);
      final m = int.tryParse(pieces[1]);
      final d = int.tryParse(pieces[2]);
      if (y == null || m == null || d == null) return input;

      final eth = EthiopianCalendar.fromGregorianDate(
        year: y,
        month: m,
        day: d,
      );
      return EthiopianCalendar.format(eth, includeYear: true);
    }

    // Format like "Mar 3" / "February 27" (no year)
    final parts = raw.split(RegExp(r'\s+'));
    if (parts.length == 2) {
      final monthKey = parts[0].toLowerCase();
      final day = int.tryParse(parts[1]);
      final month = _englishMonthIndex[monthKey];
      if (month != null && day != null) {
        final dt = DateTime(today.year, month, day);
        final eth = EthiopianCalendar.fromGregorianDateTime(dt);
        return EthiopianCalendar.format(eth, includeYear: false);
      }
    }

    return input;
  }

  static String formatDateTime(DateTime date, {bool includeYear = true}) {
    final eth = EthiopianCalendar.fromGregorianDateTime(date);
    return EthiopianCalendar.format(eth, includeYear: includeYear);
  }
}
