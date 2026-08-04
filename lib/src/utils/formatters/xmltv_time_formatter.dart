class XmltvTimeFormatter {
  DateTime? parse({required String time}) {
    final cleanTime = time.trim();

    if (cleanTime.length < 14) return null;

    try {
      final year = cleanTime.substring(0, 4);
      final month = cleanTime.substring(4, 6);
      final day = cleanTime.substring(6, 8);
      final hour = cleanTime.substring(8, 10);
      final minute = cleanTime.substring(10, 12);
      final second = cleanTime.substring(12, 14);

      final rawTimezone = cleanTime.length > 14
          ? cleanTime.substring(14).trim()
          : '';

      final formattedTz = _identifyTimeZone(rawTimezone);

      final isoString = '$year-$month-${day}T$hour:$minute$second$formattedTz';

      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  String _identifyTimeZone(String rawTimezone) {
    final cleanTz = rawTimezone.trim();

    return switch (cleanTz) {
      '' || 'Z' || 'UTC' => 'Z',
      final tz when RegExp(r'^[+-]\d{4}$').hasMatch(tz) =>
        '${tz.substring(0, 3)}:${tz.substring(3)}',

      final tz when RegExp(r'^[+-]\d{2}:\d{2}$').hasMatch(tz) => tz,

      _ => 'Z',
    };
  }
}
