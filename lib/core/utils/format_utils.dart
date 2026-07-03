// Shared formatting helpers used across course card widgets.

/// Format a price value: "Free" when zero, otherwise "1,680 EGP".
String formatPrice(double price) {
  if (price <= 0) return 'Free';
  final whole = price.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  return '$buf EGP';
}

/// Returns a 1-decimal rating string, or null when the course has no ratings
/// yet (rating == 0 and reviewsCount == 0). Callers should show "New" on null.
String? formatRating(double rating, {int reviewsCount = 0}) {
  if (rating <= 0 && reviewsCount <= 0) return null;
  return rating.toStringAsFixed(1);
}
