import 'package:chumley_navigator/screens/forms/eicr/models/eicr_circuit.dart';
import 'package:chumley_navigator/screens/forms/eicr/widgets/eicr_form_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EicrCircuitsStep extends StatelessWidget {
  const EicrCircuitsStep({
    super.key,
    required this.theme,
    required this.circuits,
    required this.onAddCircuit,
    required this.onRemoveCircuit,
    required this.onStateChanged,
  });

  final DashboardTheme theme;
  final List<EicrCircuit> circuits;
  final VoidCallback onAddCircuit;
  final ValueChanged<int> onRemoveCircuit;
  final VoidCallback onStateChanged;

  static const circuitDescriptions = [
    'Lighting',
    'Sockets - ring final',
    'Sockets - radial',
    'Cooker',
    'Shower',
    'Immersion heater',
    'Heating / boiler',
    'Smoke / heat alarms',
    'Outdoor / garage',
    'EV charger',
    'Submain',
    'Other',
  ];

  static const wiringTypes = [
    'A - Thermoplastic insulated/sheathed cables',
    'B - Thermoplastic cables in metallic conduit',
    'C - Thermoplastic cables in non-metallic conduit',
    'D - Thermoplastic cables in metallic trunking',
    'E - Thermoplastic cables in non-metallic trunking',
    'F - Thermoplastic SWA cables',
    'G - Thermosetting SWA cables',
    'H - Mineral insulated cables',
    'Other - specify',
  ];

  static const refMethods = [
    'A1 - Insulated conductors in conduit, thermally insulated wall',
    'A2 - Multicore cable in conduit, thermally insulated wall',
    'B1 - Insulated conductors in conduit on a wall',
    'B2 - Multicore cable in conduit on a wall',
    'C - Clipped direct on a wall or ceiling',
    'D1 - Cables direct in ground',
    'D2 - Cables in ducts in ground',
    'E - Single multicore cable in free air',
    'F - Multicore cables touching',
    'G - Multicore cables spaced',
    'Other - specify',
  ];

  static const ocpdTypes = [
    'Type B (MCB)',
    'Type C (MCB)',
    'Type D (MCB)',
    'RCBO',
    'BS 88 fuse (HRC)',
    'BS 1361 fuse (cartridge)',
    'BS 3036 fuse (rewireable)',
    'BS 3871 Type 1',
    'BS 3871 Type 2',
    'BS 3871 Type 3',
    'MCCB (BS EN 60947-2)',
    'Other - specify',
  ];

  static const csaOptions = [
    '1.0',
    '1.5',
    '2.5',
    '4',
    '6',
    '10',
    '16',
    '25',
    '35',
    '50',
    '70',
    '95',
    'Other - specify',
  ];

  static const currentRatings = [
    '3',
    '5',
    '6',
    '10',
    '13',
    '16',
    '20',
    '25',
    '32',
    '40',
    '45',
    '50',
    '63',
    '80',
    '100',
    '125',
    'Other - specify',
  ];

  static const breakingCapacity = [
    '1',
    '3',
    '4.5',
    '6',
    '10',
    '16',
    '25',
    '36',
    '50',
    'Other - specify',
  ];

  static const continuityMethods = ['(R1 + R2)', 'R2 only', 'N/A'];
  static const irVoltages = ['250 V', '500 V', '1000 V'];
  static const polarityOptions = [
    'Correct',
    'Reversed - rectified',
    'Reversed - C1',
  ];
  static const yesNo = ['Yes', 'No'];
  static const yesNoNaSimple = ['Yes', 'No', 'N/A'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        EicrFormHelpers.title(
          theme,
          'Schedule of circuit details & test results',
        ),
        Text(
          'Record the design and test results for every final circuit (BS 7671 Appendix 6).',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
        SizedBox(height: 12.h),
        for (var i = 0; i < circuits.length; i++) _circuitCard(context, i),
        TextButton.icon(
          onPressed: onAddCircuit,
          icon: Icon(LucideIcons.plus, size: 16.sp),
          label: Text(
            '+ Add another circuit',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(foregroundColor: EicrFormHelpers.accent),
        ),
      ],
    );
  }

  Widget _circuitCard(BuildContext context, int i) {
    final c = circuits[i];
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: EicrFormHelpers.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Circuit ${i + 1}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
              const Spacer(),
              if (circuits.length > 1)
                IconButton(
                  onPressed: () => onRemoveCircuit(i),
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 16.sp,
                    color: AppColors.errorText,
                  ),
                ),
            ],
          ),
          EicrFormHelpers.field(
            theme,
            'DB / CU reference *',
            EicrFormHelpers.textField(theme, c.dbRef, 'DB ref'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Circuit number (way) *',
            EicrFormHelpers.textField(theme, c.way, 'Way'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Circuit description *',
            EicrFormHelpers.dropdown(
              theme,
              c.description,
              circuitDescriptions,
              (v) {
                c.description = v;
                onStateChanged();
              },
            ),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Type of wiring *',
            EicrFormHelpers.dropdown(theme, c.wiring, wiringTypes, (v) {
              c.wiring = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Reference method (Table 4A2) *',
            EicrFormHelpers.dropdown(theme, c.refMethod, refMethods, (v) {
              c.refMethod = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Number of points served',
            EicrFormHelpers.textField(
              theme,
              c.points,
              'Points',
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'csa Live conductor *',
            EicrFormHelpers.dropdown(theme, c.csaLive, csaOptions, (v) {
              c.csaLive = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'csa Neutral conductor *',
            EicrFormHelpers.dropdown(theme, c.csaNeutral, csaOptions, (v) {
              c.csaNeutral = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'csa CPC *',
            EicrFormHelpers.dropdown(theme, c.csaCpc, csaOptions, (v) {
              c.csaCpc = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'OCPD BS (EN) *',
            EicrFormHelpers.textField(theme, c.ocpdBs, 'e.g. BS EN 60898'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'OCPD Type *',
            EicrFormHelpers.dropdown(theme, c.ocpdType, ocpdTypes, (v) {
              c.ocpdType = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'OCPD rating *',
            EicrFormHelpers.dropdown(theme, c.ocpdRating, currentRatings, (v) {
              c.ocpdRating = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'OCPD breaking capacity *',
            EicrFormHelpers.dropdown(theme, c.ocpdBreaking, breakingCapacity, (
              v,
            ) {
              c.ocpdBreaking = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Maximum permitted Zs * (Ω)',
            EicrFormHelpers.textField(
              theme,
              c.maxZs,
              'From BS 7671 Chapter 41',
            ),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'RCD fitted on this circuit *',
            EicrFormHelpers.dropdown(theme, c.rcdFitted, yesNo, (v) {
              c.rcdFitted = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Protective conductor continuity method *',
            EicrFormHelpers.dropdown(
              theme,
              c.continuityMethod,
              continuityMethods,
              (v) {
                c.continuityMethod = v;
                onStateChanged();
              },
            ),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Protective conductor continuity reading * (Ω)',
            EicrFormHelpers.textField(theme, c.continuityReading, 'Ω'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'IR test voltage *',
            EicrFormHelpers.dropdown(theme, c.irVoltage, irVoltages, (v) {
              c.irVoltage = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Insulation resistance L-L (or L-N) * (MΩ)',
            EicrFormHelpers.textField(theme, c.irLl, 'MΩ'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Insulation resistance L-E * (MΩ)',
            EicrFormHelpers.textField(theme, c.irLe, 'Min 1.0 MΩ'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Insulation resistance N-E * (MΩ)',
            EicrFormHelpers.textField(theme, c.irNe, 'Min 1.0 MΩ'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Polarity *',
            EicrFormHelpers.dropdown(theme, c.polarity, polarityOptions, (v) {
              c.polarity = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Maximum measured Zs * (Ω)',
            EicrFormHelpers.textField(theme, c.measuredZs, 'Ω'),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'AFDD fitted on this circuit *',
            EicrFormHelpers.dropdown(theme, c.afdd, yesNoNaSimple, (v) {
              c.afdd = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'SPD fitted on or upstream of this circuit *',
            EicrFormHelpers.dropdown(theme, c.spd, yesNo, (v) {
              c.spd = v;
              onStateChanged();
            }),
          ),
          SizedBox(height: 10.h),
          EicrFormHelpers.field(
            theme,
            'Remarks',
            EicrFormHelpers.textField(
              theme,
              c.remarks,
              'Remarks…',
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
