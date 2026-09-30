import 'package:chumley_navigator/screens/forms/eicr/widgets/eicr_form_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EicrSupplyStep extends StatelessWidget {
  const EicrSupplyStep({
    super.key,
    required this.theme,
    required this.nominalVoltageController,
    required this.numberOfPhases,
    required this.frequencyController,
    required this.zeController,
    required this.psccController,
    required this.pfcController,
    required this.earthingArrangement,
    required this.natureOfSupply,
    required this.meansOfEarthing,
    required this.maxDemandController,
    required this.earthingMaterial,
    required this.earthingCsa,
    required this.earthingVerified,
    required this.bondingMaterial,
    required this.bondingCsa,
    required this.bondingVerified,
    required this.bondWater,
    required this.bondGas,
    required this.bondOil,
    required this.bondSteel,
    required this.bondLps,
    required this.bondOtherController,
    required this.mainSwitchLocationController,
    required this.mainSwitchBsController,
    required this.mainSwitchPoles,
    required this.mainSwitchCurrent,
    required this.mainSwitchVoltageController,
    required this.mainSwitchKind,
    required this.onNumberOfPhasesChanged,
    required this.onEarthingArrangementChanged,
    required this.onNatureOfSupplyChanged,
    required this.onMeansOfEarthingChanged,
    required this.onEarthingMaterialChanged,
    required this.onEarthingCsaChanged,
    required this.onEarthingVerifiedChanged,
    required this.onBondingMaterialChanged,
    required this.onBondingCsaChanged,
    required this.onBondingVerifiedChanged,
    required this.onBondWaterChanged,
    required this.onBondGasChanged,
    required this.onBondOilChanged,
    required this.onBondSteelChanged,
    required this.onBondLpsChanged,
    required this.onMainSwitchPolesChanged,
    required this.onMainSwitchCurrentChanged,
    required this.onMainSwitchKindChanged,
  });

  final DashboardTheme theme;
  final TextEditingController nominalVoltageController;
  final String? numberOfPhases;
  final TextEditingController frequencyController;
  final TextEditingController zeController;
  final TextEditingController psccController;
  final TextEditingController pfcController;
  final String? earthingArrangement;
  final String? natureOfSupply;
  final String? meansOfEarthing;
  final TextEditingController maxDemandController;
  final String? earthingMaterial;
  final String? earthingCsa;
  final String? earthingVerified;
  final String? bondingMaterial;
  final String? bondingCsa;
  final String? bondingVerified;
  final String? bondWater;
  final String? bondGas;
  final String? bondOil;
  final String? bondSteel;
  final String? bondLps;
  final TextEditingController bondOtherController;
  final TextEditingController mainSwitchLocationController;
  final TextEditingController mainSwitchBsController;
  final String? mainSwitchPoles;
  final String? mainSwitchCurrent;
  final TextEditingController mainSwitchVoltageController;
  final String? mainSwitchKind;

  final ValueChanged<String?> onNumberOfPhasesChanged;
  final ValueChanged<String?> onEarthingArrangementChanged;
  final ValueChanged<String?> onNatureOfSupplyChanged;
  final ValueChanged<String?> onMeansOfEarthingChanged;
  final ValueChanged<String?> onEarthingMaterialChanged;
  final ValueChanged<String?> onEarthingCsaChanged;
  final ValueChanged<String?> onEarthingVerifiedChanged;
  final ValueChanged<String?> onBondingMaterialChanged;
  final ValueChanged<String?> onBondingCsaChanged;
  final ValueChanged<String?> onBondingVerifiedChanged;
  final ValueChanged<String?> onBondWaterChanged;
  final ValueChanged<String?> onBondGasChanged;
  final ValueChanged<String?> onBondOilChanged;
  final ValueChanged<String?> onBondSteelChanged;
  final ValueChanged<String?> onBondLpsChanged;
  final ValueChanged<String?> onMainSwitchPolesChanged;
  final ValueChanged<String?> onMainSwitchCurrentChanged;
  final ValueChanged<String?> onMainSwitchKindChanged;

  static const phases = ['1 (single)', '3 (three)'];
  static const earthingArrangements = [
    'TN-S',
    'TN-C-S (PME)',
    'TN-C-S (PNB)',
    'TT',
    'TN-C',
    'IT',
  ];
  static const natureOfSupplyOptions = [
    'Public LV network',
    'Private generator',
    'Dual (public + generator)',
    'Microgeneration tied to public',
  ];
  static const meansOfEarthingOptions = [
    "Distributor's facility (TN-S / TN-C-S)",
    'Installation earth electrode (TT)',
  ];
  static const conductorMaterials = [
    'Copper',
    'Aluminium',
    'Steel',
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
  static const yesNo = ['Yes', 'No'];
  static const yesNoNa = ['Yes', 'No', 'N/A - not present'];
  static const yesNoNaLps = ['Yes', 'No', 'N/A - no LPS present'];
  static const poles = ['1', '2', '3', '4'];
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
  static const deviceKinds = [
    'Isolator / switch-disconnector',
    'Switch-fuse',
    'Circuit-breaker / MCCB',
    'RCD main switch',
    'Other - specify',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        EicrFormHelpers.title(
          theme,
          'Supply characteristics (BS 7671 Appendix 6)',
        ),
        Text(
          'Supply 1',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: theme.text,
          ),
        ),
        SizedBox(height: 10.h),
        EicrFormHelpers.field(
          theme,
          'Nominal voltage U₀ (V)',
          EicrFormHelpers.textField(
            theme,
            nominalVoltageController,
            'Typical UK = 230 V',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Number of phases',
          EicrFormHelpers.dropdown(
            theme,
            numberOfPhases,
            phases,
            onNumberOfPhasesChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Nominal frequency (Hz)',
          EicrFormHelpers.textField(
            theme,
            frequencyController,
            'UK public LV = 50 Hz',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'External earth loop Ze (Ω)',
          EicrFormHelpers.textField(theme, zeController, 'Ω'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Prospective short-circuit current (PSCC) (kA)',
          EicrFormHelpers.textField(theme, psccController, 'kA'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Prospective fault current (PFC) (kA)',
          EicrFormHelpers.textField(theme, pfcController, 'kA'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Earthing arrangement',
          EicrFormHelpers.dropdown(
            theme,
            earthingArrangement,
            earthingArrangements,
            onEarthingArrangementChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Nature of supply',
          EicrFormHelpers.dropdown(
            theme,
            natureOfSupply,
            natureOfSupplyOptions,
            onNatureOfSupplyChanged,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(
          theme,
          'Installation particulars - earthing, bonding & main switch (Section J)',
        ),
        EicrFormHelpers.field(
          theme,
          'Means of earthing *',
          EicrFormHelpers.dropdown(
            theme,
            meansOfEarthing,
            meansOfEarthingOptions,
            onMeansOfEarthingChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Maximum demand (load) (kVA / A)',
          EicrFormHelpers.textField(theme, maxDemandController, 'kVA / A'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Earthing conductor - material *',
          EicrFormHelpers.dropdown(
            theme,
            earthingMaterial,
            conductorMaterials,
            onEarthingMaterialChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Earthing conductor - csa *',
          EicrFormHelpers.dropdown(
            theme,
            earthingCsa,
            csaOptions,
            onEarthingCsaChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Earthing conductor connection / continuity verified *',
          EicrFormHelpers.dropdown(
            theme,
            earthingVerified,
            yesNo,
            onEarthingVerifiedChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main protective bonding - material *',
          EicrFormHelpers.dropdown(
            theme,
            bondingMaterial,
            conductorMaterials,
            onBondingMaterialChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main protective bonding - csa *',
          EicrFormHelpers.dropdown(
            theme,
            bondingCsa,
            csaOptions,
            onBondingCsaChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main bonding connection / continuity verified *',
          EicrFormHelpers.dropdown(
            theme,
            bondingVerified,
            yesNo,
            onBondingVerifiedChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main bonding to water service *',
          EicrFormHelpers.dropdown(
            theme,
            bondWater,
            yesNoNa,
            onBondWaterChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main bonding to gas service *',
          EicrFormHelpers.dropdown(theme, bondGas, yesNoNa, onBondGasChanged),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main bonding to oil service *',
          EicrFormHelpers.dropdown(theme, bondOil, yesNoNa, onBondOilChanged),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main bonding to structural steel *',
          EicrFormHelpers.dropdown(
            theme,
            bondSteel,
            yesNoNa,
            onBondSteelChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main bonding to lightning protection system *',
          EicrFormHelpers.dropdown(
            theme,
            bondLps,
            yesNoNaLps,
            onBondLpsChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main bonding to other extraneous-conductive-parts',
          EicrFormHelpers.textField(
            theme,
            bondOtherController,
            'Optional - specify',
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Main switch'),
        EicrFormHelpers.field(
          theme,
          'Main switch - location *',
          EicrFormHelpers.textField(
            theme,
            mainSwitchLocationController,
            'Location',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main switch - BS (EN) *',
          EicrFormHelpers.textField(theme, mainSwitchBsController, 'BS (EN)'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main switch - number of poles *',
          EicrFormHelpers.dropdown(
            theme,
            mainSwitchPoles,
            poles,
            onMainSwitchPolesChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main switch - current rating *',
          EicrFormHelpers.dropdown(
            theme,
            mainSwitchCurrent,
            currentRatings,
            onMainSwitchCurrentChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main switch - voltage rating * (V)',
          EicrFormHelpers.textField(theme, mainSwitchVoltageController, 'V'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Main switch - device kind *',
          EicrFormHelpers.dropdown(
            theme,
            mainSwitchKind,
            deviceKinds,
            onMainSwitchKindChanged,
          ),
        ),
      ],
    );
  }
}
