import 'dart:async';
import 'dart:io' show Platform;

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/app_constants.dart';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chumley_navigator/screens/forms/damp_survey_form_page.dart';
import 'package:chumley_navigator/screens/forms/form_details.dart';
import 'package:chumley_navigator/screens/forms/ld_form_page.dart';
import 'package:chumley_navigator/screens/forms/vent_hygiene_form_page.dart';

class JobDetailPage extends StatefulWidget {
  final Appointment appointment;

  const JobDetailPage({super.key, required this.appointment});

  static void open(BuildContext context, Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobDetailPage(appointment: appointment),
      ),
    );
  }

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage>
    with TickerProviderStateMixin {
  // Services
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();
  final MapNavigationService _mapNavigationService = MapNavigationService();

  // Location stream subscription
  StreamSubscription<Position>? _locationSubscription;
  bool _isUsingFallbackLocation = false;

  // Status lifecycle index
  int _statusIndex = 1; // 0 = Scheduled, 1 = Dispatched, 4 = Job Completed

  // Forms panel state (mapped directly)
  bool _ldFormCompleted = false;
  bool _dampSurveyCompleted = false;
  bool _ventHygieneCompleted = false;

  // State
  Position? _engineerPosition;
  LatLng? _sitePosition;
  double? _distanceInMiles;
  int? _travelTimeMinutes;
  bool _locationLoading = false;
  bool _geocodingLoading = false;

  // Map Controller
  final MapController _mapController = MapController();

  static const List<String> _statusLabels = [
    'Scheduled',
    'Dispatched',
    'In Transit',
    'In Progress',
    'Job Completed',
  ];

  static const List<Color> _statusColors = [
    Color(0xFF6728C8), // Scheduled
    Color(0xFF3B82F6), // Dispatched
    Color(0xFFF59E0B), // In Transit
    Color(0xFF8B5CF6), // In Progress
    Color(0xFF22C55E), // Job Completed
  ];

  static const List<IconData> _statusIcons = [
    LucideIcons.calendarClock, // Scheduled
    LucideIcons.bell, // Dispatched
    LucideIcons.navigation, // In Transit
    LucideIcons.wrench, // In Progress
    LucideIcons.badgeCheck, // Job Completed
  ];

  static const List<String> _actionLabels = [
    'Slide to Dispatch',
    'Slide to Start Transit',
    'Slide to Arrive On Site',
    'Slide to Complete Job',
    '', // terminal state
  ];

  static const List<String> _shortMonthNames = [
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

  static const List<String> _fullDayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    Log('Job details: ${widget.appointment.toJson()}', name: 'JobDetail');
    _initializeMapAndLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeMapAndLocation() async {
    // 1. Resolve site position (uses dynamic check for appointment lat/lng first, then geocodes with 4s timeout)
    _resolveSitePosition();

    // 2. Resolve engineer position (uses GPS with 4s timeout + stream update)
    _setupEngineerLocation();
  }

  Future<void> _resolveSitePosition() async {
    if (mounted) setState(() => _geocodingLoading = true);
    LatLng? resolvedPosition;

    // Check if appointment has latitude and longitude dynamically
    double? apptLat;
    double? apptLng;
    try {
      final dynamic appt = widget.appointment;
      apptLat = appt.latitude as double?;
      apptLng = appt.longitude as double?;
    } catch (_) {}

    if (apptLat != null &&
        apptLng != null &&
        apptLat.isFinite &&
        apptLng.isFinite) {
      resolvedPosition = LatLng(apptLat, apptLng);
    } else {
      try {
        resolvedPosition = await _geocodingService
            .addressToCoordinates(siteAddress)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('Geocoding timeout/error: $e');
      }
    }

    if (mounted) {
      setState(() {
        if (resolvedPosition != null &&
            resolvedPosition.latitude.isFinite &&
            resolvedPosition.longitude.isFinite) {
          _sitePosition = resolvedPosition;
        } else {
          // Fallback to London center (Trafalgar Square)
          _sitePosition = const LatLng(51.5074, -0.1278);
        }
        _geocodingLoading = false;
      });

      if (_isUsingFallbackLocation) {
        _setFallbackEngineerLocation();
      } else {
        _updateRouteInfo();
        _fitMapBounds();
      }
    }
  }

  Future<void> _setupEngineerLocation() async {
    if (mounted) setState(() => _locationLoading = true);
    try {
      final hasPermission = await _locationService
          .checkAndRequestPermission()
          .timeout(const Duration(seconds: 4));

      if (!hasPermission) {
        _setFallbackEngineerLocation();
      } else {
        final pos = await _locationService.getCurrentLocation().timeout(
          const Duration(seconds: 4),
        );
        if (pos != null && pos.latitude.isFinite && pos.longitude.isFinite) {
          if (mounted) {
            setState(() {
              _engineerPosition = pos;
              _isUsingFallbackLocation = false;
              _locationLoading = false;
            });
            _updateRouteInfo();
            _fitMapBounds();
          }
        } else {
          _setFallbackEngineerLocation();
        }
      }
    } catch (e) {
      debugPrint('Location setup timeout/error: $e');
      _setFallbackEngineerLocation();
    }

    // Continuously listen to location updates while active
    try {
      _locationSubscription = _locationService.getLocationStream().listen(
        (pos) {
          if (pos.latitude.isFinite && pos.longitude.isFinite) {
            if (mounted) {
              setState(() {
                _engineerPosition = pos;
                _isUsingFallbackLocation = false;
              });
              _updateRouteInfo();
              _fitMapBounds();
            }
          }
        },
        onError: (err) {
          debugPrint('Location stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('Error starting location stream: $e');
    }
  }

  void _setFallbackEngineerLocation() {
    if (mounted) {
      setState(() {
        _isUsingFallbackLocation = true;

        final double baseLat = _sitePosition?.latitude ?? 51.5033;
        final double baseLng = _sitePosition?.longitude ?? -0.1195;

        final double offsetLat = _sitePosition != null ? 0.005 : 0.0;
        final double offsetLng = _sitePosition != null ? 0.005 : 0.0;

        _engineerPosition = Position(
          latitude: baseLat + offsetLat,
          longitude: baseLng + offsetLng,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        _locationLoading = false;
      });
      _updateRouteInfo();
      _fitMapBounds();
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (!destLocation.latitude.isFinite ||
        !destLocation.longitude.isFinite ||
        !destZoom.isFinite) {
      return;
    }
    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    double startLat = 51.5074;
    double startLng = -0.1278;
    double startZoom = 14.0;
    try {
      final center = _mapController.camera.center;
      if (center.latitude.isFinite && center.longitude.isFinite) {
        startLat = center.latitude;
        startLng = center.longitude;
        startZoom = _mapController.camera.zoom;
      } else {
        if (_sitePosition != null &&
            _sitePosition!.latitude.isFinite &&
            _sitePosition!.longitude.isFinite) {
          startLat = _sitePosition!.latitude;
          startLng = _sitePosition!.longitude;
        }
      }
    } catch (_) {
      if (_sitePosition != null &&
          _sitePosition!.latitude.isFinite &&
          _sitePosition!.longitude.isFinite) {
        startLat = _sitePosition!.latitude;
        startLng = _sitePosition!.longitude;
      }
    }

    final latAnimation = Tween<double>(
      begin: startLat,
      end: destLocation.latitude,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    final lngAnimation = Tween<double>(
      begin: startLng,
      end: destLocation.longitude,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    final zoomAnimation = Tween<double>(
      begin: startZoom,
      end: destZoom,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.addListener(() {
      if (mounted) {
        final currentLat = latAnimation.value;
        final currentLng = lngAnimation.value;
        final currentZoom = zoomAnimation.value;
        if (currentLat.isFinite &&
            currentLng.isFinite &&
            currentZoom.isFinite) {
          _mapController.move(LatLng(currentLat, currentLng), currentZoom);
        }
      }
    });

    controller.forward().then((_) => controller.dispose());
  }

  void _fitMapBounds() {
    if (_engineerPosition == null || _sitePosition == null) return;
    if (!_engineerPosition!.latitude.isFinite ||
        !_engineerPosition!.longitude.isFinite ||
        !_sitePosition!.latitude.isFinite ||
        !_sitePosition!.longitude.isFinite) {
      return;
    }

    final engineerLatLng = LatLng(
      _engineerPosition!.latitude,
      _engineerPosition!.longitude,
    );

    // Zoom out slightly to add padding
    final centerLat = (engineerLatLng.latitude + _sitePosition!.latitude) / 2;
    final centerLng = (engineerLatLng.longitude + _sitePosition!.longitude) / 2;
    final center = LatLng(centerLat, centerLng);

    // Compute appropriate zoom level based on coordinate span
    final latDelta = (engineerLatLng.latitude - _sitePosition!.latitude).abs();
    final lngDelta = (engineerLatLng.longitude - _sitePosition!.longitude)
        .abs();
    final maxDelta = latDelta > lngDelta ? latDelta : lngDelta;

    double zoom = 14.0;
    if (maxDelta > 0.001) {
      final computedZoom = 12.0 - (math.log(maxDelta) / math.log(2));
      if (computedZoom.isFinite) {
        zoom = computedZoom.clamp(3.0, 16.0);
      }
    }

    if (center.latitude.isFinite &&
        center.longitude.isFinite &&
        zoom.isFinite) {
      _animatedMapMove(center, zoom);
    }
  }

  void _updateRouteInfo() {
    if (_engineerPosition == null || _sitePosition == null) return;
    if (!_engineerPosition!.latitude.isFinite ||
        !_engineerPosition!.longitude.isFinite ||
        !_sitePosition!.latitude.isFinite ||
        !_sitePosition!.longitude.isFinite) {
      return;
    }

    final distanceInMeters = Geolocator.distanceBetween(
      _engineerPosition!.latitude,
      _engineerPosition!.longitude,
      _sitePosition!.latitude,
      _sitePosition!.longitude,
    );

    // 1 meter = 0.000621371 miles
    final distanceInMiles = distanceInMeters * 0.000621371;

    // Estimate travel time: assume 25 mph average speed
    final travelTimeMinutes = (distanceInMiles / 25.0 * 60.0).round();

    setState(() {
      _distanceInMiles = distanceInMiles;
      _travelTimeMinutes = travelTimeMinutes;
    });
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateString(DateTime? dt) {
    if (dt == null) return '';
    final dayName = _fullDayNames[dt.weekday - 1];
    final monthName = _shortMonthNames[dt.month - 1];
    return '${dayName.toUpperCase()}, $monthName ${dt.day}';
  }

  String get customerName {
    final parts = widget.appointment.title.split(' - ');
    if (parts.length > 1) {
      return parts[1];
    }
    return 'Phil Harris';
  }

  String get siteAddress {
    final parts = widget.appointment.title.split(' - ');
    if (parts.length > 2) {
      return parts.sublist(2).join(', ');
    }
    return '5 Brighton Queens Road, Brighton and Hove BN1 3XP, United Kingdom';
  }

  String get jobTitleDescription {
    final parts = widget.appointment.title.split(' - ');
    if (parts.isNotEmpty) {
      final possibleDesc = parts[0];
      if (possibleDesc.startsWith('J-')) {
        return widget.appointment.type.isNotEmpty
            ? widget.appointment.type
            : 'EML Emergency Light Test';
      }
      return possibleDesc;
    }
    return 'EML Emergency Light Test';
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    final start = widget.appointment.scheduledStart;
    final timeStr = start != null ? _formatTime(start) : '10:00';
    final timeEndStr = start != null
        ? _formatTime(start.add(const Duration(hours: 2)))
        : '12:00';
    final formattedDate = start != null
        ? _formatDateString(start)
        : 'TUESDAY, JUN 9';

    final jobType = widget.appointment.type.isNotEmpty
        ? widget.appointment.type
        : 'Reactive';
    final jobNo = widget.appointment.appointmentNumber.isNotEmpty
        ? widget.appointment.appointmentNumber
        : 'SA-290627';

    final currentStatus = _statusLabels[_statusIndex];
    final currentStatusColor = _statusColors[_statusIndex];
    final isCompleted = _statusIndex == _statusLabels.length - 1;

    return Scaffold(
      backgroundColor: theme.base,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Top bar (AspectBranding + back button) ──
                Stack(
                  children: [
                    AspectBranding(
                      progress: 1.0,
                      expandedHeight: 54.h,
                      collapsedHeight: 54.h,
                      theme: theme,
                      hasBackButton: true,
                      title: Text(
                        'WORK ORDER',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: theme.dashTitle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12.h,
                      left: 16.w,
                      child: CommandCentreBackButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),

                // ── Scrollable body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 96.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. STATUS HEADER CARD
                        _buildStatusHeader(
                          theme,
                          currentStatus,
                          currentStatusColor,
                          jobNo,
                          jobType,
                        ),

                        if (!isOnSite) ...[
                          // 2. SCHEDULE SECTION
                          _buildSectionLabel(theme, 'SCHEDULE'),
                          _buildScheduleCard(
                            theme,
                            formattedDate,
                            timeStr,
                            timeEndStr,
                            jobNo,
                            currentStatus,
                          ),
                          // 3. MAP
                          _buildMapSection(theme),

                          // 4. SITE SECTION
                          _buildSectionLabel(theme, 'SITE'),
                          _buildSiteCard(theme),

                          // 5. ACCESS SECTION
                          _buildSectionLabel(theme, 'ACCESS'),
                          _buildAccessCard(theme),

                          // 6. JOB DETAILS SECTION
                          _buildSectionLabel(theme, 'JOB DETAILS'),
                          _buildJobDetailsCard(theme, jobNo),
                        ] else ...[
                          // 8. FORMS SECTION (Pre-completion is now under top card)
                          _buildSectionLabel(theme, 'COMPLETION FORMS'),
                          _buildFormsCard(theme),

                          // 8.5 RAISE JOBS SECTION (under pre completion)
                          _buildSectionLabel(theme, 'RAISE JOBS'),
                          _buildRaiseJobsCard(theme),

                          // 5. ACCESS SECTION
                          _buildSectionLabel(theme, 'ACCESS'),
                          _buildAccessCard(theme),

                          // 6. JOB DETAILS SECTION
                          _buildSectionLabel(theme, 'JOB DETAILS'),
                          _buildJobDetailsCard(theme, jobNo),

                          // 7. RELATED DOCS SECTION (shown only when on site)
                          _buildSectionLabel(theme, 'RELATED DOCS'),
                          _buildRelatedDocs(theme),
                        ],

                        // 9. COMPLETED BANNER
                        if (isCompleted) _buildCompletedBanner(theme),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Sticky bottom actions panel ──
            _buildActionsPanel(theme, currentStatusColor, isCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
    DashboardTheme theme,
    String status,
    Color statusColor,
    String jobNo,
    String jobType,
  ) {
    final isDark = theme.isDark;
    final statusIcon = _statusIcons[_statusIndex];

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.08),
                  blurRadius: 20.r,
                  spreadRadius: 0,
                  offset: Offset(0, 4.h),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chip row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colour-coded status pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12.sp, color: statusColor),
                    SizedBox(width: 6.w),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Job number top-right
              Text(
                jobNo,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Large status text
          Text(
            status,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: theme.text,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$jobType • EML Emergency Light Test',
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.h),

          // Progress track (step dots)
          _buildStatusProgressTrack(theme, statusColor),
        ],
      ),
    );
  }

  Widget _buildStatusProgressTrack(DashboardTheme theme, Color statusColor) {
    final shortLabels = ['Sched.', 'Dispatched', 'Transit', 'On Site', 'Done'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dotSize = 8.w;
        final activeDotSize = 12.w;
        final colWidth = totalWidth / 5;

        // Line starts at center of the first column and ends at center of the last column
        final lineStart = colWidth / 2;
        final lineEnd = totalWidth - colWidth / 2;
        final lineLength = lineEnd - lineStart;

        // Active fraction: clamp between 0 and 4.
        final activeFraction = (_statusIndex.clamp(0, 4)) / 4.0;
        final activeLength = lineLength * activeFraction;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connector bar with dots
            SizedBox(
              height: 20.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background connector line (inactive)
                  Positioned(
                    left: lineStart,
                    right: colWidth / 2,
                    top: 10.h - 1.h, // center vertically in the 20.h space
                    height: 2.h,
                    child: Container(
                      color: theme.isDark
                          ? AppColors.darkBorder
                          : AppColors.borderDefault,
                    ),
                  ),
                  // Active connector line
                  Positioned(
                    left: lineStart,
                    width: activeLength,
                    top: 10.h - 1.h,
                    height: 2.h,
                    child: Container(color: statusColor),
                  ),
                  // Row of dots
                  Row(
                    children: List.generate(shortLabels.length, (i) {
                      final isActive = i <= _statusIndex;
                      final isCurrent = i == _statusIndex;
                      final size = isCurrent ? activeDotSize : dotSize;

                      return Expanded(
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? statusColor
                                  : theme.isDark
                                  ? AppColors.darkBorder
                                  : AppColors.borderDefault,
                              shape: BoxShape.circle,
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: statusColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 6.r,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            // Label row (display all labels, aligned centered under their respective dots)
            Row(
              children: List.generate(shortLabels.length, (i) {
                final isActive = i <= _statusIndex;
                final isCurrent = i == _statusIndex;

                return Expanded(
                  child: Text(
                    shortLabels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: isCurrent
                          ? statusColor
                          : isActive
                          ? statusColor.withValues(alpha: 0.8)
                          : theme.textMuted,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapSection(DashboardTheme theme) {
    final engineerLatLng =
        (_engineerPosition != null &&
            _engineerPosition!.latitude.isFinite &&
            _engineerPosition!.longitude.isFinite)
        ? LatLng(_engineerPosition!.latitude, _engineerPosition!.longitude)
        : null;

    final siteLatLng =
        (_sitePosition != null &&
            _sitePosition!.latitude.isFinite &&
            _sitePosition!.longitude.isFinite)
        ? _sitePosition
        : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 160.h,
          width: double.infinity,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: siteLatLng ?? const LatLng(51.5074, -0.1278),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
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
              if (_locationLoading || _geocodingLoading)
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
                          _geocodingLoading
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

              // Floating Route Info Overlay (bottom-left)
              if (_engineerPosition != null &&
                  _sitePosition != null &&
                  _distanceInMiles != null &&
                  _travelTimeMinutes != null)
                Positioned(
                  bottom: 10.h,
                  left: 10.w,
                  right: 50.w,
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
                        Text(
                          siteAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
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
                              '${_distanceInMiles!.toStringAsFixed(1)} miles away',
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
                              '$_travelTimeMinutes mins travel',
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

              // Center bounds button (top-right)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: _fitMapBounds,
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

  Widget _buildSectionLabel(DashboardTheme theme, String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: theme.textMuted,
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    DashboardTheme theme,
    String formattedDate,
    String timeStr,
    String timeEndStr,
    String jobNo,
    String currentStatus,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: _cardDecoration(theme),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: date block
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: theme.textMuted,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$timeStr – $timeEndStr',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: theme.text,
                    letterSpacing: -1.0,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 11.sp,
                      color: theme.textMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '2h window',
                      style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Right: status badge (vertical)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _statusColors[_statusIndex].withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _statusColors[_statusIndex].withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _statusIcons[_statusIndex],
                    size: 18.sp,
                    color: _statusColors[_statusIndex],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currentStatus,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: _statusColors[_statusIndex],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteCard(DashboardTheme theme) {
    final accentColor = theme.isDark
        ? AppColors.accentBlue
        : AppColors.primaryBlue;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: _cardDecoration(theme),
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
            // Navigate button
            GestureDetector(
              onTap: () {
                if (_sitePosition != null) {
                  _mapNavigationService.launchNavigation(
                    context: context,
                    destinationLat: _sitePosition!.latitude,
                    destinationLng: _sitePosition!.longitude,
                    address: siteAddress,
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 36.h,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
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
                      color: accentColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Open in Maps',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
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

  Widget _buildAccessCard(DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: _cardDecoration(theme),
        child: Column(
          children: [
            _buildAccessRow(
              theme,
              LucideIcons.hardHat,
              'Equipment',
              'Standard ladders required. Double height limits on external fixture.',
            ),
            Divider(height: 16.h, color: theme.border, thickness: 0.5),
            _buildAccessRow(
              theme,
              LucideIcons.keyRound,
              'Site Entry',
              'Keys available with the site supervisor at the main front reception office.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessRow(
    DashboardTheme theme,
    IconData icon,
    String label,
    String value,
  ) {
    final accentColor = theme.isDark
        ? AppColors.accentBlue
        : AppColors.primaryBlue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: accentColor),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: theme.textMuted,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.text,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDetailsCard(DashboardTheme theme, String jobNo) {
    final items = [
      ('Work Order', jobNo),
      (
        'Type',
        widget.appointment.type.isNotEmpty
            ? widget.appointment.type
            : 'Reactive',
      ),
      ('Customer', customerName),
      ('Description', jobTitleDescription),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: _cardDecoration(theme),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (i > 0)
                  Divider(height: 14.h, color: theme.border, thickness: 0.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: Text(
                        item.$1,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.$2.isNotEmpty ? item.$2 : '—',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRelatedDocs(DashboardTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: _cardDecoration(theme),
        child: Column(
          children: [
            _buildDocRow(
              theme,
              LucideIcons.fileText,
              'Electrical Certificate (EICR)',
              'Required condition report. 2 tasks completed.',
              0,
            ),
            Divider(height: 0, color: theme.border, thickness: 0.5),
            _buildDocRow(
              theme,
              LucideIcons.shieldAlert,
              'Risk Assessment (RAMS)',
              'Site safety evaluation statement. Approved.',
              1,
            ),
            Divider(height: 0, color: theme.border, thickness: 0.5),
            _buildDocRow(
              theme,
              LucideIcons.history,
              'Previous Job History',
              'SA-281099 — Fitted replacement LED modules.',
              2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocRow(
    DashboardTheme theme,
    IconData icon,
    String title,
    String subtitle,
    int index,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // dummy
        borderRadius: index == 0
            ? BorderRadius.vertical(top: Radius.circular(16.r))
            : index == 2
            ? BorderRadius.vertical(bottom: Radius.circular(16.r))
            : BorderRadius.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? AppColors.darkBorder
                      : AppColors.surfaceBlueTint,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 16.sp,
                  color: theme.isDark
                      ? AppColors.accentBlue
                      : AppColors.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 14.sp,
                color: theme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get isOnSite => _statusIndex >= 3;

  void _showOnSiteRequiredSnackbar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.lock, color: Colors.white, size: 16.sp),
            SizedBox(width: 8.w),
            const Expanded(
              child: Text(
                'Engineer must Arrive On Site to perform this action.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  void _handleRaiseJob(String jobType) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final theme = DashboardTheme.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                LucideIcons.check,
                color: const Color(0xFF22C55E),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Success',
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '$jobType has been successfully raised and linked to this work order.',
            style: TextStyle(color: theme.text, fontSize: 13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: theme.isDark
                      ? AppColors.accentBlue
                      : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRaiseJobItem({
    required DashboardTheme theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final goldColor = const Color(0xFFF59E0B);
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!enabled) {
              _showOnSiteRequiredSnackbar();
              return;
            }
            onTap();
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: enabled
                  ? goldColor.withValues(alpha: 0.05)
                  : theme.isDark
                  ? AppColors.darkSurfaceDeep
                  : AppColors.backgroundGray,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: enabled
                    ? goldColor.withValues(alpha: 0.25)
                    : theme.border,
                width: 0.75,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: enabled
                        ? goldColor.withValues(alpha: 0.1)
                        : theme.isDark
                        ? AppColors.darkBorder
                        : AppColors.surfaceBlueTint,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 16.sp,
                    color: enabled ? goldColor : theme.textMuted,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: enabled ? theme.text : theme.textMuted,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14.sp,
                  color: theme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRaiseJobsCard(DashboardTheme theme) {
    final goldColor = const Color(0xFFF59E0B);
    final onSite = isOnSite;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: onSite ? goldColor.withValues(alpha: 0.3) : theme.border,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.fileText,
                  size: 16.sp,
                  color: onSite ? goldColor : theme.textMuted,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Raise Jobs',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: onSite ? theme.text : theme.textMuted,
                  ),
                ),
                const Spacer(),
                if (!onSite)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.lock,
                        size: 12.sp,
                        color: theme.textMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Requires On Site',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'Raise FP',
              subtitle: 'Create a new Fixed Price work order for this site',
              icon: LucideIcons.fileText,
              enabled: onSite,
              // onTap: () => _handleRaiseJob('Fixed Price (FP)'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.fixedPriceScreen,
                  arguments: widget.appointment,
                );
              },
            ),
            SizedBox(height: 8.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'Raise multiple FP',
              subtitle: 'Batch create multiple Fixed Price jobs',
              icon: LucideIcons.clipboardList,
              enabled: onSite,
              onTap: () => _handleRaiseJob('Multiple FPs'),
            ),
            SizedBox(height: 8.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'Raise Reactive',
              subtitle: 'Raise an urgent reactive task or callback',
              icon: LucideIcons.zap,
              enabled: onSite,
              onTap: () => _handleRaiseJob('Reactive Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsCard(DashboardTheme theme) {
    final pinkColor = const Color(0xFFEC4899);
    final onSite = isOnSite;
    final formItems = [
      (
        'LD Form',
        'Electrical Installation Condition Report · BS 7671:2018+A2:2022',
        _ldFormCompleted,
        (bool v) => setState(() => _ldFormCompleted = v),
        FormType.LDForm,
      ),
      (
        'Damp Survey Form',
        'Surface / depth readings · BS 5250:2021',
        _dampSurveyCompleted,
        (bool v) => setState(() => _dampSurveyCompleted = v),
        FormType.DampSurveyForm,
      ),
      (
        'Vent Hygiene Forms',
        'Vent heat loss calculation · BS 8204:2011',
        _ventHygieneCompleted,
        (bool v) => setState(() => _ventHygieneCompleted = v),
        FormType.VentHygeineForm,
      ),
    ];

    final completedCount = [
      _ldFormCompleted,
      _dampSurveyCompleted,
      _ventHygieneCompleted,
    ].where((e) => e).length;
    final totalForms = formItems.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: onSite ? pinkColor.withValues(alpha: 0.3) : theme.border,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  LucideIcons.clipboardList,
                  size: 16.sp,
                  color: onSite ? pinkColor : theme.textMuted,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Pre-Completion Forms',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: onSite ? theme.text : theme.textMuted,
                  ),
                ),
                const Spacer(),
                if (!onSite)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.lock,
                        size: 12.sp,
                        color: theme.textMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Requires On Site',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textMuted,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '$completedCount/$totalForms',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: pinkColor,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            // Form items
            ...formItems.map((item) {
              return Opacity(
                opacity: onSite ? 1.0 : 0.55,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    if (!onSite) {
                      _showOnSiteRequiredSnackbar();
                      return;
                    }
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          final appt = widget.appointment;
                          final workOrderId = appt.sourceWorkOrderId.isNotEmpty
                              ? appt.sourceWorkOrderId
                              : appt.id;
                          final workOrderLabel =
                              appt.appointmentNumber.isNotEmpty
                                  ? appt.appointmentNumber
                                  : workOrderId;

                          switch (item.$5) {
                            case FormType.LDForm:
                              return LdFormPage(
                                workOrderId: workOrderId,
                                workOrderLabel: workOrderLabel,
                              );
                            case FormType.DampSurveyForm:
                              return DampSurveyFormPage(
                                workOrderId: workOrderId,
                                workOrderLabel: workOrderLabel,
                              );
                            case FormType.VentHygeineForm:
                              return VentHygieneFormPage(
                                workOrderId: workOrderId,
                                workOrderLabel: workOrderLabel,
                              );
                          }
                        },
                      ),
                    );
                    if (result == true) {
                      item.$4(true);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: item.$3
                          ? pinkColor.withValues(alpha: 0.06)
                          : theme.isDark
                          ? AppColors.darkSurfaceDeep
                          : AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: item.$3
                            ? pinkColor.withValues(alpha: 0.35)
                            : theme.border,
                        width: 0.75,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clickable checkbox
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (!onSite) {
                              _showOnSiteRequiredSnackbar();
                              return;
                            }
                            item.$4(!item.$3);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: item.$3 ? pinkColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(
                                color: item.$3
                                    ? pinkColor
                                    : theme.textMuted.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: item.$3
                                ? Icon(
                                    LucideIcons.check,
                                    size: 12.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$1,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: onSite ? theme.text : theme.textMuted,
                                  decoration: item.$3
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item.$2,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: theme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16.sp,
                          color: theme.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Info note
            if (completedCount < totalForms && onSite)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: pinkColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.info, size: 12.sp, color: pinkColor),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Tap a form to complete, or check it off directly.',
                        style: TextStyle(fontSize: 11.sp, color: pinkColor),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBanner(DashboardTheme theme) {
    final greenColor = const Color(0xFF22C55E);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: greenColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: greenColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.badgeCheck, size: 36.sp, color: greenColor),
            SizedBox(height: 10.h),
            Text(
              'Job Completed',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: greenColor,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'All forms submitted. This job is now closed.',
              style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsPanel(
    DashboardTheme theme,
    Color statusColor,
    bool isCompleted,
  ) {
    // final isFormsStep = _statusIndex == 6;
    // final allFormsChecked = _form1Checked && _form2Checked && _form3Checked;
    // final canAdvance = !isCompleted && (!isFormsStep || allFormsChecked);
    final canAdvance = !isCompleted;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          border: Border(top: BorderSide(color: theme.border, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: Offset(0, -4.h),
              blurRadius: 16.r,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: theme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            if (!isCompleted)
              CallStyleActionSlider(
                text: _actionLabels[_statusIndex],
                backgroundColor: statusColor,
                icon: _statusIcons[_statusIndex],
                isEnabled: canAdvance,
                onConfirm: () {
                  setState(() {
                    _statusIndex++;
                  });
                },
              )
            else
              // Completed terminal state badge
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 16.sp,
                      color: const Color(0xFF22C55E),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Job Closed',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(DashboardTheme theme) {
    return BoxDecoration(
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
    );
  }
}

// ── CUSTOM SLIDER WIDGET ───────────────────────────────────────

class CallStyleActionSlider extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onConfirm;

  const CallStyleActionSlider({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.icon,
    required this.isEnabled,
    required this.onConfirm,
  });

  @override
  State<CallStyleActionSlider> createState() => _CallStyleActionSliderState();
}

class _CallStyleActionSliderState extends State<CallStyleActionSlider>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _springAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CallStyleActionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = 40.h;
    final sliderHeight = 48.h;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDragDistance = constraints.maxWidth - thumbSize - 8.w;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: sliderHeight,
          decoration: BoxDecoration(
            color: widget.isEnabled
                ? widget.backgroundColor
                : widget.backgroundColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Swipe Action Instruction text
              Opacity(
                opacity: (1.0 - (_dragOffset / maxDragDistance)).clamp(
                  0.2,
                  1.0,
                ),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isEnabled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              // Swipe gesture target drag thumb
              Positioned(
                left: 4.w + _dragOffset,
                child: GestureDetector(
                  onHorizontalDragUpdate: widget.isEnabled
                      ? (details) {
                          setState(() {
                            _dragOffset += details.primaryDelta!;
                            if (_dragOffset < 0) _dragOffset = 0;
                            if (_dragOffset > maxDragDistance) {
                              _dragOffset = maxDragDistance;
                            }
                          });
                        }
                      : null,
                  onHorizontalDragEnd: widget.isEnabled
                      ? (details) async {
                          if (_dragOffset >= maxDragDistance * 0.9) {
                            // Successful trigger
                            HapticFeedback.mediumImpact();
                            widget.onConfirm();

                            _springAnimation =
                                Tween<double>(
                                  begin: _dragOffset,
                                  end: 0.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.elasticOut,
                                  ),
                                );
                            _animationController.reset();
                            _animationController.forward().then((_) {
                              setState(() {
                                _dragOffset = 0.0;
                              });
                            });
                          } else {
                            // Spring back
                            _springAnimation =
                                Tween<double>(
                                  begin: _dragOffset,
                                  end: 0.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.easeOutBack,
                                  ),
                                );
                            _animationController.reset();
                            _animationController.forward().then((_) {
                              setState(() {
                                _dragOffset = 0.0;
                              });
                            });
                          }
                        }
                      : null,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final offset = _animationController.isAnimating
                          ? _springAnimation.value
                          : _dragOffset;

                      if (_animationController.isAnimating) {
                        _dragOffset = offset;
                      }

                      return Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.backgroundColor,
                          size: 18.sp,
                        ),
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
}

// ── SERVICES ──────────────────────────────────────────────────

class LocationService {
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}

class GeocodingService {
  static final Map<String, LatLng> _geocodeCache = {};

  Future<LatLng?> addressToCoordinates(String address) async {
    final cleanAddress = address.trim().toLowerCase();
    if (cleanAddress.contains('brighton') && cleanAddress.contains('queens')) {
      return const LatLng(50.8284, -0.1410);
    }
    if (cleanAddress.contains('ashby road') || cleanAddress.contains('le11')) {
      return const LatLng(52.7658, -1.2285);
    }

    if (_geocodeCache.containsKey(address)) {
      return _geocodeCache[address];
    }
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final lat = locations.first.latitude;
        final lng = locations.first.longitude;
        if (lat.isFinite && lng.isFinite) {
          final loc = LatLng(lat, lng);
          _geocodeCache[address] = loc;
          return loc;
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }
}

class MapNavigationService {
  Future<void> launchNavigation({
    required BuildContext context,
    required double destinationLat,
    required double destinationLng,
    required String address,
  }) async {
    if (Platform.isAndroid) {
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng',
      );
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch Google Maps')),
          );
        }
      }
    } else if (Platform.isIOS) {
      if (context.mounted) {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: const Text('Navigate Using'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                child: const Text('Apple Maps'),
                onPressed: () async {
                  Navigator.pop(context);
                  final appleMapsUrl = Uri.parse(
                    'maps://?daddr=$destinationLat,$destinationLng',
                  );
                  if (await canLaunchUrl(appleMapsUrl)) {
                    await launchUrl(
                      appleMapsUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('Google Maps'),
                onPressed: () async {
                  Navigator.pop(context);
                  final googleMapsAppUrl = Uri.parse(
                    'comgooglemaps://?daddr=$destinationLat,$destinationLng',
                  );
                  if (await canLaunchUrl(googleMapsAppUrl)) {
                    await launchUrl(
                      googleMapsAppUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    // Fallback to browser Google Maps
                    final googleMapsWebUrl = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng',
                    );
                    if (await canLaunchUrl(googleMapsWebUrl)) {
                      await launchUrl(
                        googleMapsWebUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  }
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    }
  }
}
