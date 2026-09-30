import 'package:chumley_navigator/core/app_constants.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobSiteCard extends StatelessWidget {
  final DashboardTheme theme;
  final String customerName;
  final String siteAddress;
  final MapController mapController;
  final LatLng? sitePosition;
  final Position? engineerPosition;
  final double? distanceInMiles;
  final int? travelTimeMinutes;
  final bool locationLoading;
  final bool geocodingLoading;
  final VoidCallback onOpenMaps;
  final VoidCallback onFitBounds;

  const JobSiteCard({
    super.key,
    required this.theme,
    required this.customerName,
    required this.siteAddress,
    required this.mapController,
    required this.sitePosition,
    required this.engineerPosition,
    required this.distanceInMiles,
    required this.travelTimeMinutes,
    required this.locationLoading,
    required this.geocodingLoading,
    required this.onOpenMaps,
    required this.onFitBounds,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = theme.isDark
        ? AppColors.accentBlue
        : AppColors.primaryBlue;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.border, width: 0.5),
          boxShadow: theme.isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.shadowSubtle,
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: theme.isDark
                        ? AppColors.darkBorder
                        : AppColors.surfaceBlueTint,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    LucideIcons.user,
                    size: 16.sp,
                    color: accentColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Site Contact',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 20.h, color: theme.border, thickness: 0.5),
            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.mapPin, size: 14.sp, color: accentColor),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    siteAddress,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.text,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildMapSection(theme),
            SizedBox(height: 12.h),
            // Navigate button
            GestureDetector(
              onTap: onOpenMaps,
              child: Container(
                width: double.infinity,
                height: 36.h,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.navigation,
                      size: 13.sp,
                      color: AppColors.white,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Open in Maps',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(DashboardTheme theme) {
    final engineerLatLng =
        (engineerPosition != null &&
            engineerPosition!.latitude.isFinite &&
            engineerPosition!.longitude.isFinite)
        ? LatLng(engineerPosition!.latitude, engineerPosition!.longitude)
        : null;

    final siteLatLng =
        (sitePosition != null &&
            sitePosition!.latitude.isFinite &&
            sitePosition!.longitude.isFinite)
        ? sitePosition
        : null;

    return Padding(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 160.h,
          width: double.infinity,
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: siteLatLng ?? const LatLng(51.5074, -0.1278),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap: (tapPosition, point) => onOpenMaps(),
                ),
                children: [
                  theme.isDark
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            // Invert + Navy Slate tint for map background layer
                            -0.7, 0, 0, 0, 220,
                            0, -0.7, 0, 0, 220,
                            0, 0, -0.6, 0, 220,
                            0, 0, 0, 1, 0,
                          ]),
                          child: TileLayer(
                            urlTemplate:
                                'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=${AppConstants.tomtomApiKey}',
                            userAgentPackageName:
                                'com.aspect.chumley_navigator',
                          ),
                        )
                      : TileLayer(
                          urlTemplate:
                              'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=${AppConstants.tomtomApiKey}',
                          userAgentPackageName: 'com.aspect.chumley_navigator',
                        ),
                  MarkerLayer(
                    markers: [
                      if (siteLatLng != null)
                        Marker(
                          point: siteLatLng,
                          width: 40.w,
                          height: 40.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Icon(
                                Icons.location_on_rounded,
                                color: Colors.blue,
                                size: 30.sp,
                              ),
                            ],
                          ),
                        ),
                      if (engineerLatLng != null)
                        Marker(
                          point: engineerLatLng,
                          width: 40.w,
                          height: 40.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Icon(
                                Icons.navigation_rounded,
                                color: Colors.green,
                                size: 24.sp,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Loading overlay when fetching location
              if (locationLoading || geocodingLoading)
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12.w,
                          height: 12.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: theme.isDark
                                ? AppColors.accentBlue
                                : AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          geocodingLoading
                              ? 'Geocoding address…'
                              : 'Locating you…',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Floating Route Info Overlay (bottom-left) - Tap to open navigation
              if (engineerPosition != null &&
                  sitePosition != null &&
                  distanceInMiles != null &&
                  travelTimeMinutes != null)
                Positioned(
                  bottom: 10.h,
                  left: 10.w,
                  right: 50.w,
                  child: GestureDetector(
                    onTap: onOpenMaps,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: theme.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: theme.border, width: 0.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  siteAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: theme.text,
                                  ),
                                ),
                              ),
                              Icon(
                                LucideIcons.externalLink,
                                size: 10.sp,
                                color: theme.textMuted,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.navigation,
                                size: 10.sp,
                                color: theme.isDark
                                    ? AppColors.accentBlue
                                    : AppColors.primaryBlue,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${distanceInMiles!.toStringAsFixed(1)} miles away',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.text,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                LucideIcons.clock,
                                size: 10.sp,
                                color: theme.isDark
                                    ? AppColors.accentBlue
                                    : AppColors.primaryBlue,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$travelTimeMinutes mins travel',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.text,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Center bounds button (top-right)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: onFitBounds,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: theme.surface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.maximize2,
                        color: theme.text,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
