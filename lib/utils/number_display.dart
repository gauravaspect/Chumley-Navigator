/// Formats integers with thousands separators, e.g. 1234567 → "1,234,567".
String formatIntegerWithCommas(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  if (negative) buffer.write('-');

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }

  return buffer.toString();
}

/// Prefixes positive values with "+" for delta-style labels.
String formatSignedIntegerWithCommas(int value) {
  if (value > 0) {
    return '+${formatIntegerWithCommas(value)}';
  }
  return formatIntegerWithCommas(value);
}
