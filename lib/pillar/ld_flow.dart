/// Port of `app/form_flow.js` PLAN + PHOTO_HOST.
class LdHost {
  const LdHost({
    required this.sid,
    required this.name,
    required this.absorb,
  });

  final String sid;
  final String name;
  final List<String> absorb;
}

class LdFlow {
  static const hosts = [
    LdHost(sid: '2013-3427', name: 'Safety', absorb: ['2023-3704']),
    LdHost(sid: '2013-3546', name: 'Context', absorb: ['2013-3670']),
    LdHost(sid: '2013-3795', name: 'Inspection', absorb: ['2013-4048']),
    LdHost(sid: '2057-3792', name: 'Findings', absorb: ['2062-3848']),
    LdHost(sid: '2070-3895', name: 'Sign off', absorb: ['2013-4305']),
  ];

  static const photosSid = '2013-3921';

  static const photoHost = {
    'front of property': '2013-3546',
    'water meter reading': '2013-3670',
    'affected area overview': '2013-3795',
    'affected area close up': '2013-3795',
    'proposed access route': '2057-3792',
  };

  static const photoDuplicate = {
    'test before equipment setup': 'step 6 carries this slot natively',
    'test after reading result captured': 'step 6 carries this slot natively',
    'source confirmed leak': 'step 7 Slot/Leak location',
    'repair completed work': 'step 7 Slot/After repair (completed fix)',
  };
}
