import 'package:chumley_navigator/models/vehicle_model.dart';

class VcrExamplePhoto {
  const VcrExamplePhoto({
    required this.label,
    required this.imageUrl,
  });

  final String label;
  final String imageUrl;
}

class VcrCaptureSlotData {
  const VcrCaptureSlotData({required this.id, required this.label});

  /// API section key passed to `/api/vcr/examples/{id}`.
  final String id;
  final String label;
}

class VcrStepData {
  const VcrStepData({
    required this.title,
    required this.captures,
  });

  final String title;
  final List<VcrCaptureSlotData> captures;

  String get inspectionTitle => '$title inspection';

  String get photoCountLabel {
    final n = captures.length;
    return '$n ${n == 1 ? 'photo' : 'photos'}';
  }
}

/// Route args for the multi-step VCR capture form.
class VehicleFormArgs {
  const VehicleFormArgs({
    required this.vehicle,
    this.dashboardNotes = '',
  });

  final VehicleModel vehicle;
  final String dashboardNotes;
}

/// API section keys → display labels for VCR capture slots.
const Map<String, String> vcrSectionLabels = {
  'external_front_view': 'Front',
  'external_near_side': 'Nearside',
  'external_off_side': 'Offside',
  'external_rear_view': 'Rear',
  'bonnet_overview': 'Overview',
  'bonnet_oil_level': 'Oil level',
  'bonnet_coolant_level': 'Coolant',
  'wheels_front_left': 'Front left',
  'wheels_rear_left': 'Rear left',
  'wheels_rear_right': 'Rear right',
  'wheels_front_right': 'Front right',
  'wheels_spare': 'Spare',
  'mirrors_windscreen_windscreen': 'Windscreen',
  'mirrors_windscreen_left_mirror': 'Nearside mirror',
  'mirrors_windscreen_right_mirror': 'Offside mirror',
  'interior_cab': 'Cab',
  'interior_rear_internal': 'Load area',
  'interior_dashcam': 'Dashcam',
  'dashboard_overview': 'Warning lights',
  'dashboard_mileage': 'Odometer',
  'dashboard_adblue': 'AdBlue',
};

/// Prototype order: External → Bonnet → Wheels → Mirrors → Interior → Dashboard.
const List<VcrStepData> vcrSteps = [
  VcrStepData(
    title: 'External',
    captures: [
      VcrCaptureSlotData(id: 'external_front_view', label: 'Front'),
      VcrCaptureSlotData(id: 'external_rear_view', label: 'Rear'),
      VcrCaptureSlotData(id: 'external_near_side', label: 'Nearside'),
      VcrCaptureSlotData(id: 'external_off_side', label: 'Offside'),
    ],
  ),
  VcrStepData(
    title: 'Bonnet',
    captures: [
      VcrCaptureSlotData(id: 'bonnet_oil_level', label: 'Oil level'),
      VcrCaptureSlotData(id: 'bonnet_coolant_level', label: 'Coolant'),
      VcrCaptureSlotData(id: 'bonnet_overview', label: 'Overview'),
    ],
  ),
  VcrStepData(
    title: 'Wheels',
    captures: [
      VcrCaptureSlotData(id: 'wheels_front_left', label: 'Front left'),
      VcrCaptureSlotData(id: 'wheels_front_right', label: 'Front right'),
      VcrCaptureSlotData(id: 'wheels_rear_left', label: 'Rear left'),
      VcrCaptureSlotData(id: 'wheels_rear_right', label: 'Rear right'),
      VcrCaptureSlotData(id: 'wheels_spare', label: 'Spare'),
    ],
  ),
  VcrStepData(
    title: 'Mirrors & Windscreen',
    captures: [
      VcrCaptureSlotData(
        id: 'mirrors_windscreen_windscreen',
        label: 'Windscreen',
      ),
      VcrCaptureSlotData(
        id: 'mirrors_windscreen_left_mirror',
        label: 'Nearside mirror',
      ),
      VcrCaptureSlotData(
        id: 'mirrors_windscreen_right_mirror',
        label: 'Offside mirror',
      ),
    ],
  ),
  VcrStepData(
    title: 'Interior',
    captures: [
      VcrCaptureSlotData(id: 'interior_cab', label: 'Cab'),
      VcrCaptureSlotData(id: 'interior_rear_internal', label: 'Load area'),
      VcrCaptureSlotData(id: 'interior_dashcam', label: 'Dashcam'),
    ],
  ),
  VcrStepData(
    title: 'Dashboard',
    captures: [
      VcrCaptureSlotData(id: 'dashboard_overview', label: 'Warning lights'),
      VcrCaptureSlotData(id: 'dashboard_mileage', label: 'Odometer'),
      VcrCaptureSlotData(id: 'dashboard_adblue', label: 'AdBlue'),
    ],
  ),
];
