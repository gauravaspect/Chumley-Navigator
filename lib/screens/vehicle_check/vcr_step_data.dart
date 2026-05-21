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

  final String id;
  final String label;
}

class VcrStepData {
  const VcrStepData({
    required this.title,
    required this.examples,
    required this.captures,
  });

  final String title;
  final List<VcrExamplePhoto> examples;
  final List<VcrCaptureSlotData> captures;
}

/// Inspection sections — step 1 matches design reference content.
const List<VcrStepData> vcrSteps = [
  VcrStepData(
    title: 'Bonnet',
    examples: [
      VcrExamplePhoto(
        label: 'Bonnet Coolant Level',
        imageUrl:
            'https://storage.googleapis.com/flowing-garage-481412-p2.firebasestorage.app/vcr%20examples/Bonnet_Coolant_Level.jpeg',
      ),
      VcrExamplePhoto(
        label: 'Bonnet Oil Level',
        imageUrl:
            'https://storage.googleapis.com/flowing-garage-481412-p2.firebasestorage.app/vcr%20examples/Bonnet_Oil_Level.jpeg',
      ),
      VcrExamplePhoto(
        label: 'Bonnet Overview',
        imageUrl:
            'https://storage.googleapis.com/flowing-garage-481412-p2.firebasestorage.app/vcr%20examples/Bonnet_Overview.jpeg',
      ),
    ],
    captures: [
      VcrCaptureSlotData(id: 'bonnet_overview', label: 'Overview'),
      VcrCaptureSlotData(id: 'bonnet_oil', label: 'Oil Level'),
      VcrCaptureSlotData(id: 'bonnet_coolant', label: 'Coolant Level'),
    ],
  ),
  VcrStepData(
    title: 'Front',
    examples: [],
    captures: [
      VcrCaptureSlotData(id: 'front_overview', label: 'Overview'),
      VcrCaptureSlotData(id: 'front_plate', label: 'Number Plate'),
      VcrCaptureSlotData(id: 'front_lights', label: 'Lights'),
    ],
  ),
  VcrStepData(
    title: 'Driver Side',
    examples: [],
    captures: [
      VcrCaptureSlotData(id: 'driver_overview', label: 'Overview'),
      VcrCaptureSlotData(id: 'driver_tyres', label: 'Tyres'),
      VcrCaptureSlotData(id: 'driver_door', label: 'Door'),
    ],
  ),
  VcrStepData(
    title: 'Rear',
    examples: [],
    captures: [
      VcrCaptureSlotData(id: 'rear_overview', label: 'Overview'),
      VcrCaptureSlotData(id: 'rear_plate', label: 'Number Plate'),
      VcrCaptureSlotData(id: 'rear_lights', label: 'Lights'),
    ],
  ),
  VcrStepData(
    title: 'Passenger Side',
    examples: [],
    captures: [
      VcrCaptureSlotData(id: 'passenger_overview', label: 'Overview'),
      VcrCaptureSlotData(id: 'passenger_tyres', label: 'Tyres'),
      VcrCaptureSlotData(id: 'passenger_door', label: 'Door'),
    ],
  ),
  VcrStepData(
    title: 'Interior',
    examples: [],
    captures: [
      VcrCaptureSlotData(id: 'interior_dashboard', label: 'Dashboard'),
      VcrCaptureSlotData(id: 'interior_seats', label: 'Seats'),
      VcrCaptureSlotData(id: 'interior_cargo', label: 'Cargo Area'),
    ],
  ),
];
