import 'package:chumley_navigator/models/fixed_price_job_context.dart';
import 'package:chumley_navigator/screens/job_details/fixed_price/fixed_price_ui_helpers.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FixedPriceReviewStep extends StatelessWidget {
  const FixedPriceReviewStep({
    super.key,
    required this.theme,
    required this.jobContext,
    required this.totalCustomerCharges,
  });

  final DashboardTheme theme;
  final FixedPriceJobContext? jobContext;
  final double totalCustomerCharges;

  @override
  Widget build(BuildContext context) {
    final scheduledStart = jobContext?.earliestRequestedDate;
    final dateStr = scheduledStart != null && scheduledStart.isNotEmpty
        ? scheduledStart
        : '—';
    final workOrderId = jobContext?.workOrderLabel.isNotEmpty == true
        ? jobContext!.workOrderLabel
        : jobContext?.sourceWorkOrderId ?? '—';
    final customerEmail = jobContext?.customerEmail.isNotEmpty == true
        ? jobContext!.customerEmail
        : '—';
    final siteLabel = () {
      if (jobContext == null) return '—';
      final id = jobContext!.siteId.trim();
      if (id.isEmpty) return '—';
      return id;
    }();

    final deposit = (totalCustomerCharges * 1.2) * 0.50;
    final missingJobContext = jobContext == null;
    final jobContextErrors = jobContext?.validate() ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Job Summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 16.h),
        if (missingJobContext || jobContextErrors.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
            ),
            child: Text(
              missingJobContext
                  ? 'This agreement must be opened from a job appointment before it can be submitted.'
                  : jobContextErrors.first,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red.shade700,
                height: 1.4,
              ),
            ),
          ),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Information',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildDetailRow(
                'Contact Email',
                customerEmail,
                theme,
              ),
              FixedPriceUiHelpers.buildDetailRow('Site', siteLabel, theme),
              FixedPriceUiHelpers.buildDetailRow(
                'Earliest Work Order Requested Date',
                dateStr,
                theme,
              ),
              FixedPriceUiHelpers.buildDetailRow(
                'Job Type',
                'Fixed Price (Single)',
                theme,
              ),
              FixedPriceUiHelpers.buildDetailRow(
                'Status',
                'Pending Confirmation',
                theme,
              ),
              FixedPriceUiHelpers.buildDetailRow(
                'Work Order ID',
                workOrderId,
                theme,
              ),
              if (jobContext?.sourceWorkOrderId.isNotEmpty == true &&
                  jobContext!.sourceWorkOrderId != workOrderId)
                FixedPriceUiHelpers.buildDetailRow(
                  'Source Work Order',
                  jobContext!.sourceWorkOrderId,
                  theme,
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedSurface(
          padding: EdgeInsets.all(16.r),
          backgroundColor: theme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimate Details',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.dashTitle,
                ),
              ),
              SizedBox(height: 12.h),
              FixedPriceUiHelpers.buildDetailRow(
                'Generate Deposit Invoice',
                deposit > 0 ? 'Yes' : 'No',
                theme,
              ),
              FixedPriceUiHelpers.buildDetailRow(
                'Work Commencing Immediately',
                'Yes',
                theme,
              ),
              FixedPriceUiHelpers.buildDetailRow(
                'Date Time Last Estimate Sent',
                '29/06/2026 11:20',
                theme,
              ),
              FixedPriceUiHelpers.buildDetailRow(
                'Payment Link Sent to Customer',
                'Yes',
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
