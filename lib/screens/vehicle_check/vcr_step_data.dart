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
}

/// API section keys → display labels for VCR capture slots.
const Map<String, String> vcrSectionLabels = {
  'bonnet_overview': 'Bonnet Overview',
  'bonnet_oil_level': 'Bonnet Oil Level',
  'bonnet_coolant_level': 'Bonnet Coolant Level',
  'external_front_view': 'External Front',
  'external_near_side': 'External Near Side',
  'external_off_side': 'External Off Side',
  'external_rear_view': 'External Rear',
  'mirrors_windscreen_right_mirror': 'Right Mirror',
  'mirrors_windscreen_windscreen': 'Windscreen',
  'mirrors_windscreen_left_mirror': 'Left Mirror',
  'wheels_front_left': 'Wheels Front Left',
  'wheels_rear_left': 'Wheels Rear Left',
  'wheels_rear_right': 'Wheels Rear Right',
  'wheels_front_right': 'Wheels Front Right',
  'wheels_spare': 'Wheels Spare',
  'interior_rear_internal': 'Interior Rear',
  'interior_cab': 'Interior Cab',
  'interior_dashcam': 'Interior Dashcam',
  'dashboard_overview': 'Dashboard Overview',
  'dashboard_mileage': 'Dashboard Odometer',
  'dashboard_adblue': 'Dashboard AdBlue',
};

const List<VcrStepData> vcrSteps = [
  VcrStepData(
    title: 'Bonnet',
    captures: [
      VcrCaptureSlotData(id: 'bonnet_overview', label: 'Bonnet Overview'),
      VcrCaptureSlotData(id: 'bonnet_oil_level', label: 'Bonnet Oil Level'),
      VcrCaptureSlotData(id: 'bonnet_coolant_level', label: 'Bonnet Coolant Level'),
    ],
  ),
  VcrStepData(
    title: 'External',
    captures: [
      VcrCaptureSlotData(id: 'external_front_view', label: 'External Front'),
      VcrCaptureSlotData(id: 'external_near_side', label: 'External Near Side'),
      VcrCaptureSlotData(id: 'external_off_side', label: 'External Off Side'),
      VcrCaptureSlotData(id: 'external_rear_view', label: 'External Rear'),
    ],
  ),
  VcrStepData(
    title: 'Mirrors & windscreen',
    captures: [
      VcrCaptureSlotData(
        id: 'mirrors_windscreen_right_mirror',
        label: 'Right Mirror',
      ),
      VcrCaptureSlotData(
        id: 'mirrors_windscreen_windscreen',
        label: 'Windscreen',
      ),
      VcrCaptureSlotData(
        id: 'mirrors_windscreen_left_mirror',
        label: 'Left Mirror',
      ),
    ],
  ),
  VcrStepData(
    title: 'Wheels',
    captures: [
      VcrCaptureSlotData(id: 'wheels_front_left', label: 'Wheels Front Left'),
      VcrCaptureSlotData(id: 'wheels_rear_left', label: 'Wheels Rear Left'),
      VcrCaptureSlotData(id: 'wheels_rear_right', label: 'Wheels Rear Right'),
      VcrCaptureSlotData(id: 'wheels_front_right', label: 'Wheels Front Right'),
      VcrCaptureSlotData(id: 'wheels_spare', label: 'Wheels Spare'),
    ],
  ),
  VcrStepData(
    title: 'Interior',
    captures: [
      VcrCaptureSlotData(id: 'interior_rear_internal', label: 'Interior Rear'),
      VcrCaptureSlotData(id: 'interior_cab', label: 'Interior Cab'),
      VcrCaptureSlotData(id: 'interior_dashcam', label: 'Interior Dashcam'),
    ],
  ),
  VcrStepData(
    title: 'Dashboard',
    captures: [
      VcrCaptureSlotData(id: 'dashboard_overview', label: 'Dashboard Overview'),
      VcrCaptureSlotData(id: 'dashboard_mileage', label: 'Dashboard Odometer'),
      VcrCaptureSlotData(id: 'dashboard_adblue', label: 'Dashboard AdBlue'),
    ],
  ),
];
