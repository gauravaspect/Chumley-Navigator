import 'package:chumley_navigator/screens/forms/ld/widgets/ld_form_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Information Tab for LD Form — Form Name, Work Order, PDF Url, Service Appointment.
class LdInformationTab extends StatelessWidget {
  final DashboardTheme theme;
  final TextEditingController formNameController;
  final TextEditingController pdfUrlController;
  final TextEditingController appointmentSearchController;
  final String workOrderDisplay;
  final String? selectedAppointment;
  final List<String> serviceAppointments;
  final ValueChanged<String?> onAppointmentChanged;

  const LdInformationTab({
    super.key,
    required this.theme,
    required this.formNameController,
    required this.pdfUrlController,
    required this.appointmentSearchController,
    required this.workOrderDisplay,
    required this.selectedAppointment,
    required this.serviceAppointments,
    required this.onAppointmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'LD Form Name',
          child: LdFormHelpers.buildTextField(
            theme: theme,
            controller: formNameController,
            hint: 'Enter LD form name',
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Work Order',
          child: LdFormHelpers.buildReadOnlyField(
            theme: theme,
            value: workOrderDisplay,
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'LD Form PDF Url',
          child: LdFormHelpers.buildTextField(
            theme: theme,
            controller: pdfUrlController,
            hint: 'https://…',
            keyboardType: TextInputType.url,
          ),
        ),
        SizedBox(height: 14.h),
        LdFormHelpers.buildLabeledField(
          theme: theme,
          label: 'Service Appointment',
          child: LdFormHelpers.buildSearchableDropdown(
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
