import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PodiumEntry {
  const PodiumEntry({
    required this.firstName,
    required this.lastName,
    required this.score,
    required this.position,
  });

  final String firstName;
  final String lastName;
  final String score;
  final String position;
}

class PodiumColumn extends StatelessWidget {
  const PodiumColumn({super.key, required this.entry});

  final PodiumEntry entry;

  @override
  Widget build(BuildContext context) {
    final isFirst = entry.position == '1st';
    final cardH = isFirst ? 175.h : 145.h;
    final nameSize = isFirst ? 14.sp : 12.sp;
    final iconSize = isFirst ? 42.sp : 32.sp;
    final scoreSize = isFirst ? 24.sp : 20.sp;

    final cardColor = AppColors.accentLime.withValues(alpha: 0.55);
    final borderColor = AppColors.accentBlue.withValues(alpha: 0.35);

    return PressableScale(
      onTap: () {},
      scale: 0.98,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: cardH,
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: ElevatedSurface.softShadows(elevation: 0.7),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.firstName,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlueDark,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  entry.lastName,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlueDark,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 9.h),
                Icon(
                  Icons.emoji_events_outlined,
                  size: iconSize,
                  color: AppColors.primaryBlueDark,
                ),
                SizedBox(height: 9.h),
                Text(
                  entry.score,
                  style: TextStyle(
                    fontSize: scoreSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppColors.primaryBlueDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '${entry.position} Place',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
