class HomeJobFilter {
  static bool showOnHome({
    required String status,
    required DateTime? scheduledStart,
    required DateTime selectedDay,
    required DateTime today,
  }) {
    final st = status.toUpperCase();
    if (st == 'COMPLETE' || st == 'AWAITING_APPROVAL' || st == 'APPROVED') {
      return false;
    }
    final inFlight = st == 'IN_TRANSIT' || st == 'ON_SITE';
    final viewingToday = _sameDay(selectedDay, today);
    if (viewingToday && inFlight) return true;
    if (scheduledStart == null) return false;
    return _sameDay(scheduledStart, selectedDay);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
