import 'package:chumley_navigator/screens/forms/vent_hygiene/models/sub_operative_controllers.dart';
import 'package:chumley_navigator/screens/forms/vent_hygiene/widgets/sub_operative_card.dart';
import 'package:chumley_navigator/screens/forms/vent_hygiene/widgets/vent_hygiene_ui_helpers.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VentInformationStep extends StatelessWidget {
  const VentInformationStep({
    super.key,
    required this.theme,
    required this.currency,
    required this.workOrderDisplay,
    required this.selectedAppointment,
    required this.appointmentSearchController,
    required this.lastServiceClean,
    required this.selectedOperative,
    required this.operativeSearchController,
    required this.travelHoursController,
    required this.dateTime,
    required this.dateTimeError,
    required this.leadEngineerCostController,
    required this.hoursWorkedController,
    required this.scopeOfWorkController,
    required this.subOperativeCount,
    required this.subOperatives,
    required this.certificateDescController,
    required this.preCleanPdfUrlController,
    required this.onCurrencyChanged,
    required this.onAppointmentChanged,
    required this.onPickLastServiceClean,
    required this.onOperativeChanged,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSubOperativeCountChanged,
  });

  final DashboardTheme theme;
  final String? currency;
  final String workOrderDisplay;
  final String? selectedAppointment;
  final TextEditingController appointmentSearchController;
  final DateTime? lastServiceClean;
  final String? selectedOperative;
  final TextEditingController operativeSearchController;
  final TextEditingController travelHoursController;
  final DateTime? dateTime;
  final String? dateTimeError;
  final TextEditingController leadEngineerCostController;
  final TextEditingController hoursWorkedController;
  final TextEditingController scopeOfWorkController;
  final String subOperativeCount;
  final List<SubOperativeControllers> subOperatives;
  final TextEditingController certificateDescController;
  final TextEditingController preCleanPdfUrlController;

  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<String?> onAppointmentChanged;
  final VoidCallback onPickLastServiceClean;
  final ValueChanged<String?> onOperativeChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final ValueChanged<String?> onSubOperativeCountChanged;

  static const currencyOptions = ['GBP', 'EUR', 'USD'];
  static const subOperativeCounts = ['None', '1', '2', '3', '4', '5', '6', '7'];
  static const serviceAppointments = [
    'SA-10021 · 12 High Street',
    'SA-10045 · 4 Station Road',
    'SA-10088 · Flat 2B Oak Court',
    'SA-10102 · 19 Mill Lane',
  ];
  static const people = [
    'Alex Morgan',
    'Jordan Lee',
    'Sam Patel',
    'Taylor Brooks',
    'Casey Nguyen',
  ];

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String formatDate(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    final month = _months[dt.month - 1];
    return '$weekday, ${dt.day} $month ${dt.year}';
  }

  static String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = dateTime == null ? 'Select date' : formatDate(dateTime!);
    final timeLabel = dateTime == null ? 'Select time' : formatTime(dateTime!);
    final lastCleanLabel = lastServiceClean == null
        ? 'Select date'
        : formatDate(lastServiceClean!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Currency',
          child: VentHygieneUiHelpers.simpleDropdown(
            theme: theme,
            value: currency,
            items: currencyOptions,
            hint: 'Select currency',
            onChanged: onCurrencyChanged,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Work Order',
          child: VentHygieneUiHelpers.readOnlyField(
            theme: theme,
            value: workOrderDisplay,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Service Appointment',
          child: VentHygieneUiHelpers.searchableDropdown(
            theme: theme,
            value: selectedAppointment,
            items: serviceAppointments,
            hint: 'Search Service Appointments',
            searchController: appointmentSearchController,
            onChanged: onAppointmentChanged,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Last Service Clean',
          child: VentHygieneUiHelpers.pickerButton(
            theme: theme,
            icon: LucideIcons.calendar,
            label: lastCleanLabel,
            onTap: onPickLastServiceClean,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Operative Name',
          child: VentHygieneUiHelpers.searchableDropdown(
            theme: theme,
            value: selectedOperative,
            items: people,
            hint: 'Search People',
            searchController: operativeSearchController,
            onChanged: onOperativeChanged,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Time Travel to site (Hours)',
          child: VentHygieneUiHelpers.numberField(
            theme: theme,
            controller: travelHoursController,
            hint: 'e.g. 1.5',
            allowDecimal: true,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Date / Time',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: VentHygieneUiHelpers.pickerButton(
                      theme: theme,
                      icon: LucideIcons.calendar,
                      label: dateLabel,
                      onTap: onPickDate,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: VentHygieneUiHelpers.pickerButton(
                      theme: theme,
                      icon: LucideIcons.clock,
                      label: timeLabel,
                      onTap: onPickTime,
                    ),
                  ),
                ],
              ),
              if (dateTimeError != null) ...[
                SizedBox(height: 8.h),
                Text(
                  dateTimeError!,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.errorText),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Total Cost of Lead Engineer',
          child: VentHygieneUiHelpers.numberField(
            theme: theme,
            controller: leadEngineerCostController,
            hint: '0.00',
            allowDecimal: true,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'How many hours did you work',
          child: VentHygieneUiHelpers.numberField(
            theme: theme,
            controller: hoursWorkedController,
            hint: 'e.g. 4',
            allowDecimal: true,
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Scope of Work',
          child: VentHygieneUiHelpers.expandableField(
            theme: theme,
            controller: scopeOfWorkController,
            hint: 'Describe the scope of work…',
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'How many sub operatives are there?',
          child: VentHygieneUiHelpers.simpleDropdown(
            theme: theme,
            value: subOperativeCount,
            items: subOperativeCounts,
            hint: 'Select count',
            onChanged: onSubOperativeCountChanged,
          ),
        ),
        if (subOperatives.isNotEmpty) ...[
          SizedBox(height: 14.h),
          for (var i = 0; i < subOperatives.length; i++) ...[
            SubOperativeCard(
              theme: theme,
              controllers: subOperatives[i],
              index: i,
            ),
            if (i < subOperatives.length - 1) SizedBox(height: 10.h),
          ],
        ],
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Description of certificate',
          child: VentHygieneUiHelpers.expandableField(
            theme: theme,
            controller: certificateDescController,
            hint: 'Describe the certificate…',
          ),
        ),
        SizedBox(height: 14.h),
        VentHygieneUiHelpers.labeledField(
          theme: theme,
          label: 'Pre-Clean Images PDF URL',
          child: VentHygieneUiHelpers.textField(
            theme: theme,
            controller: preCleanPdfUrlController,
            hint: 'https://…',
            keyboardType: TextInputType.url,
          ),
        ),
      ],
    );
  }
}
