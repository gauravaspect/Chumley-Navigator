import 'package:chumley_navigator/screens/forms/eicr/widgets/eicr_form_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EicrInstallationStep extends StatelessWidget {
  const EicrInstallationStep({
    super.key,
    required this.theme,
    required this.wiringAgeController,
    required this.additions,
    required this.recordsAvailable,
    required this.lastInspectionDateController,
    required this.extentController,
    required this.limitationsAgreed,
    required this.operationalLimitations,
    required this.agreedWithController,
    required this.bs7671Controller,
    required this.supplyPolarityController,
    required this.spdBsController,
    required this.spdTypeController,
    required this.spdRatedController,
    required this.spdBreakingController,
    required this.mainOvercurrentType,
    required this.mainOvercurrentRatingController,
    required this.mainOvercurrentBreakingController,
    required this.rcdMainBreakingController,
    required this.dbLocationController,
    required this.suppliedFromController,
    required this.zdbController,
    required this.ipfController,
    required this.distOcpdBsController,
    required this.distOcpdTypeController,
    required this.distOcpdRatingController,
    required this.spdAtBoard,
    required this.generalConditionController,
    required this.furtherInspectionController,
    required this.recommendationReasonsController,
    required this.inspectedByNameController,
    required this.inspectedByPositionController,
    required this.authorisedByNameController,
    required this.authorisedByPositionController,
    required this.instrumentsController,
    required this.onAdditionsChanged,
    required this.onRecordsAvailableChanged,
    required this.onLimitationsAgreedChanged,
    required this.onOperationalLimitationsChanged,
    required this.onMainOvercurrentTypeChanged,
    required this.onSpdAtBoardChanged,
  });

  final DashboardTheme theme;
  final TextEditingController wiringAgeController;
  final String? additions;
  final String? recordsAvailable;
  final TextEditingController lastInspectionDateController;
  final TextEditingController extentController;
  final String? limitationsAgreed;
  final String? operationalLimitations;
  final TextEditingController agreedWithController;
  final TextEditingController bs7671Controller;
  final TextEditingController supplyPolarityController;
  final TextEditingController spdBsController;
  final TextEditingController spdTypeController;
  final TextEditingController spdRatedController;
  final TextEditingController spdBreakingController;
  final String? mainOvercurrentType;
  final TextEditingController mainOvercurrentRatingController;
  final TextEditingController mainOvercurrentBreakingController;
  final TextEditingController rcdMainBreakingController;
  final TextEditingController dbLocationController;
  final TextEditingController suppliedFromController;
  final TextEditingController zdbController;
  final TextEditingController ipfController;
  final TextEditingController distOcpdBsController;
  final TextEditingController distOcpdTypeController;
  final TextEditingController distOcpdRatingController;
  final String? spdAtBoard;
  final TextEditingController generalConditionController;
  final TextEditingController furtherInspectionController;
  final TextEditingController recommendationReasonsController;
  final TextEditingController inspectedByNameController;
  final TextEditingController inspectedByPositionController;
  final TextEditingController authorisedByNameController;
  final TextEditingController authorisedByPositionController;
  final TextEditingController instrumentsController;

  final ValueChanged<String?> onAdditionsChanged;
  final ValueChanged<String?> onRecordsAvailableChanged;
  final ValueChanged<String?> onLimitationsAgreedChanged;
  final ValueChanged<String?> onOperationalLimitationsChanged;
  final ValueChanged<String?> onMainOvercurrentTypeChanged;
  final ValueChanged<String?> onSpdAtBoardChanged;

  static const yesNo = ['Yes', 'No'];
  static const yesNotApparent = ['Yes', 'Not apparent'];
  static const yesNoFull = ['Yes', 'No - full inspection agreed'];
  static const yesNoSimple = ['Yes', 'No'];
  static const overcurrentTypes = ['MCCB', 'ACB', 'Fuse(s)', 'Other'];
  static const spdTypes = ['T1', 'T2', 'T3', 'T1+T2', 'T2+T3', 'N/A'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        EicrFormHelpers.title(theme, 'Installation details (Section C)'),
        EicrFormHelpers.field(
          theme,
          'Estimated age of wiring system (years)',
          EicrFormHelpers.textField(
            theme,
            wiringAgeController,
            'Years',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Evidence of additions / alterations?',
          EicrFormHelpers.dropdown(
            theme,
            additions,
            yesNotApparent,
            onAdditionsChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Installation records available? (Reg 651.1)',
          EicrFormHelpers.dropdown(
            theme,
            recordsAvailable,
            yesNo,
            onRecordsAvailableChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Date of last inspection',
          EicrFormHelpers.textField(
            theme,
            lastInspectionDateController,
            'Date',
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Extent & limitations of the inspection'),
        EicrFormHelpers.field(
          theme,
          'Extent of the installation covered by this report *',
          EicrFormHelpers.textField(
            theme,
            extentController,
            'Extent…',
            maxLines: 3,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Were any limitations to the inspection agreed with the client? (Reg 653.2) *',
          EicrFormHelpers.dropdown(
            theme,
            limitationsAgreed,
            yesNoFull,
            onLimitationsAgreedChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Were there any operational limitations during the inspection? *',
          EicrFormHelpers.dropdown(
            theme,
            operationalLimitations,
            yesNoSimple,
            onOperationalLimitationsChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Agreed with (name / role)',
          EicrFormHelpers.textField(theme, agreedWithController, 'Name / role'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Inspection carried out to BS 7671:2018 as amended to',
          EicrFormHelpers.textField(theme, bs7671Controller, 'e.g. A2:2022'),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Supply protective device (Section I)'),
        EicrFormHelpers.field(
          theme,
          'Confirmation of supply polarity',
          EicrFormHelpers.textField(
            theme,
            supplyPolarityController,
            'Polarity',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Supply protective device - BS (EN)',
          EicrFormHelpers.textField(theme, spdBsController, 'BS (EN)'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Supply protective device - Type',
          EicrFormHelpers.textField(theme, spdTypeController, 'Type'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Supply protective device - rated current (A)',
          EicrFormHelpers.textField(
            theme,
            spdRatedController,
            'A',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Supply protective device - breaking capacity (kA)',
          EicrFormHelpers.textField(
            theme,
            spdBreakingController,
            'kA',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Main switch device ratings (Section J)'),
        EicrFormHelpers.field(
          theme,
          'If overcurrent device - device type',
          EicrFormHelpers.dropdown(
            theme,
            mainOvercurrentType,
            overcurrentTypes,
            onMainOvercurrentTypeChanged,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'If overcurrent device - rating / setting (A)',
          EicrFormHelpers.textField(
            theme,
            mainOvercurrentRatingController,
            'A',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'If overcurrent device - breaking capacity (kA)',
          EicrFormHelpers.textField(
            theme,
            mainOvercurrentBreakingController,
            'kA',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'If RCD main switch - breaking capacity (kA)',
          EicrFormHelpers.textField(theme, rcdMainBreakingController, 'kA'),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Distribution board details'),
        EicrFormHelpers.field(
          theme,
          'DB / CU location',
          EicrFormHelpers.textField(theme, dbLocationController, 'Location'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Supplied from',
          EicrFormHelpers.textField(
            theme,
            suppliedFromController,
            'Supplied from',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Zdb at this board (Ω)',
          EicrFormHelpers.textField(theme, zdbController, 'Ω'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Ipf at this board (kA)',
          EicrFormHelpers.textField(theme, ipfController, 'kA'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Distribution circuit OCPD - BS (EN)',
          EicrFormHelpers.textField(theme, distOcpdBsController, 'BS (EN)'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Distribution circuit OCPD - Type',
          EicrFormHelpers.textField(theme, distOcpdTypeController, 'Type'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Distribution circuit OCPD - rating / setting (A)',
          EicrFormHelpers.textField(theme, distOcpdRatingController, 'A'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'SPD Type(s) at this board',
          EicrFormHelpers.dropdown(
            theme,
            spdAtBoard,
            spdTypes,
            onSpdAtBoardChanged,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(
          theme,
          'Summary & next inspection (Sections E & F)',
        ),
        EicrFormHelpers.field(
          theme,
          'General condition of the installation (electrical safety)',
          EicrFormHelpers.textField(
            theme,
            generalConditionController,
            'Condition…',
            maxLines: 3,
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Further inspection & testing recommended before',
          EicrFormHelpers.textField(
            theme,
            furtherInspectionController,
            'Date / period',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Reasons for the recommendation',
          EicrFormHelpers.textField(
            theme,
            recommendationReasonsController,
            'Reasons…',
            maxLines: 2,
          ),
        ),
        SizedBox(height: 16.h),
        EicrFormHelpers.title(theme, 'Declaration details (Section G)'),
        EicrFormHelpers.field(
          theme,
          'Inspected & tested by - name',
          EicrFormHelpers.textField(theme, inspectedByNameController, 'Name'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Inspected & tested by - position',
          EicrFormHelpers.textField(
            theme,
            inspectedByPositionController,
            'Position',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Report authorized for issue by - name',
          EicrFormHelpers.textField(theme, authorisedByNameController, 'Name'),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Report authorized for issue by - position',
          EicrFormHelpers.textField(
            theme,
            authorisedByPositionController,
            'Position',
          ),
        ),
        SizedBox(height: 12.h),
        EicrFormHelpers.field(
          theme,
          'Test instruments used (serial / asset numbers)',
          EicrFormHelpers.textField(
            theme,
            instrumentsController,
            'Instruments…',
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
