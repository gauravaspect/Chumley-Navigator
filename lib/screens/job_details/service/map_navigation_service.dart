import 'dart:io' show Platform;

import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class MapNavigationService {
  Future<void> launchNavigation({
    required BuildContext context,
    required double destinationLat,
    required double destinationLng,
    required String address,
  }) async {
    final encodedAddress = Uri.encodeComponent(address.trim());

    Future<void> openAppleMaps() async {
      final appUrl = Uri.parse(
        'maps://?daddr=$destinationLat,$destinationLng&q=$encodedAddress',
      );
      final webUrl = Uri.parse(
        'https://maps.apple.com/?daddr=$destinationLat,$destinationLng&q=$encodedAddress',
      );
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }

    Future<void> openGoogleMaps() async {
      final iosAppUrl = Uri.parse(
        'comgooglemaps://?daddr=$destinationLat,$destinationLng&directionsmode=driving',
      );
      final universalUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng',
      );
      if (Platform.isIOS && await canLaunchUrl(iosAppUrl)) {
        await launchUrl(iosAppUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(universalUrl)) {
        await launchUrl(universalUrl, mode: LaunchMode.externalApplication);
      }
    }

    Future<void> openWaze() async {
      final appUrl = Uri.parse(
        'waze://?ll=$destinationLat,$destinationLng&navigate=yes',
      );
      final webUrl = Uri.parse(
        'https://waze.com/ul?ll=$destinationLat,$destinationLng&navigate=yes',
      );
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }

    Future<void> openCitymapper() async {
      final appUrl = Uri.parse(
        'citymapper://directions?endcoord=$destinationLat,$destinationLng&endname=$encodedAddress',
      );
      final webUrl = Uri.parse(
        'https://citymapper.com/directions?endcoord=$destinationLat,$destinationLng&endname=$encodedAddress',
      );
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }

    if (!context.mounted) return;

    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext ctx) => CupertinoActionSheet(
          title: const Text('Navigate Using'),
          message: Text(
            address.isNotEmpty ? address : 'Choose a navigation app',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: const Text('Apple Maps'),
              onPressed: () {
                Navigator.pop(ctx);
                openAppleMaps();
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Google Maps'),
              onPressed: () {
                Navigator.pop(ctx);
                openGoogleMaps();
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Waze'),
              onPressed: () {
                Navigator.pop(ctx);
                openWaze();
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Citymapper'),
              onPressed: () {
                Navigator.pop(ctx);
                openCitymapper();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ),
      );
    } else {
      final theme = DashboardTheme.of(context);
      showModalBottomSheet(
        context: context,
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (BuildContext ctx) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: theme.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 4.h,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Navigate Using',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.dashTitle,
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 16.h, color: theme.border),
                  ListTile(
                    leading: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? AppColors.primaryBlue.withValues(alpha: 0.2)
                            : const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.mapPin,
                        color: theme.isDark
                            ? AppColors.accentBlue
                            : const Color(0xFF1A73E8),
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      'Google Maps',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.dashTitle,
                      ),
                    ),
                    subtitle: Text(
                      'Turn-by-turn navigation',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.dashMuted,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      openGoogleMaps();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? const Color(0xFF00ACC1).withValues(alpha: 0.2)
                            : const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        LucideIcons.navigation,
                        color: Color(0xFF00ACC1),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Waze',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.dashTitle,
                      ),
                    ),
                    subtitle: Text(
                      'Real-time traffic & alerts',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.dashMuted,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      openWaze();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        LucideIcons.compass,
                        color: Color(0xFF2E7D32),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Citymapper',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.dashTitle,
                      ),
                    ),
                    subtitle: Text(
                      'Urban routing & transit',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.dashMuted,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      openCitymapper();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
