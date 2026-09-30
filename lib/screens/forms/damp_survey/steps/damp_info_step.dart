import 'package:chumley_navigator/screens/forms/damp_survey/widgets/damp_survey_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DampInfoStep extends StatelessWidget {
  const DampInfoStep({
    super.key,
    required this.theme,
    required this.formNameController,
    required this.workOrderDisplay,
    required this.pdfUrlController,
    required this.selectedAppointment,
    required this.appointmentSearchController,
    required this.onAppointmentChanged,
  });

  final DashboardTheme theme;
  final TextEditingController formNameController;
  final String workOrderDisplay;
  final TextEditingController pdfUrlController;
  final String? selectedAppointment;
  final TextEditingController appointmentSearchController;
  final ValueChanged<String?> onAppointmentChanged;

  static const serviceAppointments = [
    'SA-10021 · 12 High Street',
    'SA-10045 · 4 Station Road',
    'SA-10088 · Flat 2B Oak Court',
    'SA-10102 · 19 Mill Lane',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Damp Survey Form Name',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: formNameController,
            hint: 'Enter form name',
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Work Order',
          child: DampSurveyUiHelpers.readOnlyField(
            theme: theme,
            value: workOrderDisplay,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Generated PDF Url',
          child: DampSurveyUiHelpers.textField(
            theme: theme,
            controller: pdfUrlController,
            hint: 'https://…',
            keyboardType: TextInputType.url,
          ),
        ),
        SizedBox(height: 14.h),
        DampSurveyUiHelpers.labeledField(
          theme: theme,
          label: 'Service Appointment',
          child: DampSurveyUiHelpers.searchableDropdown(
            theme: theme,
            value: selectedAppointment,
            items: serviceAppointments,
            hint: 'Search Service Appointments',
            searchController: appointmentSearchController,
            onChanged: onAppointmentChanged,
          ),
        ),
      ],
    );
  }
}
