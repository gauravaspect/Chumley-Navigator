import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// iOS-style time picker presented as a bottom sheet.
Future<TimeOfDay?> showCupertinoTimePickerSheet({
  required BuildContext context,
  required TimeOfDay initialTime,
  String title = 'Select time',
}) async {
  final theme = DashboardTheme.of(context);
  var selected = initialTime;
  final initialDateTime = DateTime(
    2020,
    1,
    1,
    initialTime.hour,
    initialTime.minute,
  );

  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (sheetContext) {
      return Container(
        height: 320.h,
        decoration: BoxDecoration(
          color: theme.dashCardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dashBorderLight),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.dashSubtitle,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.dashTitle,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(sheetContext, selected),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.dashPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 22.sp,
                      color: theme.dashTitle,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialDateTime,
                  use24hFormat: true,
                  onDateTimeChanged: (value) {
                    selected = TimeOfDay(
                      hour: value.hour,
                      minute: value.minute,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
