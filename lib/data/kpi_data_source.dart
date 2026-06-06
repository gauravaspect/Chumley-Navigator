class KpiCardData {
  const KpiCardData({
    required this.label,
    required this.value,
    required this.max,
  });

  final String label;
  final double value;
  final double max;
}

/// Loads KPI cards at runtime (not compile-time const).
class KpiDataSource {
  KpiDataSource._();

  static final KpiDataSource instance = KpiDataSource._();

  List<KpiCardData> _cards = [];
  bool isLoading = true;

  List<KpiCardData> get cards => List.unmodifiable(_cards);

  Future<void> load() async {
    isLoading = true;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _cards = const [
      KpiCardData(label: 'Conversion Pool', value: 8.1, max: 20),
      KpiCardData(label: 'Productivity Pool', value: 12.1, max: 20),
      KpiCardData(label: 'Procedural Pool', value: 14.2, max: 20),
      KpiCardData(label: 'Vehicular Pool', value: 18.1, max: 20),
      KpiCardData(label: 'Satisfaction Pool', value: 16.7, max: 20),
    ];
    isLoading = false;
  }
}
