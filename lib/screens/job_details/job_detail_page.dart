import 'dart:async';
import 'dart:io' show Platform;

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/app_constants.dart';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/models/engineer_form_model.dart';
import 'package:chumley_navigator/models/sa_status.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/screens/forms/cp12_form_page.dart';
import 'package:chumley_navigator/screens/forms/damp_survey_form_page.dart';
import 'package:chumley_navigator/screens/forms/ld_form_page.dart';
import 'package:chumley_navigator/screens/forms/vent_hygiene_form_page.dart';
import 'package:chumley_navigator/screens/job_details/on_site_wizard.dart';
import 'package:chumley_navigator/screens/job_details/post_submit_flow.dart';
import 'package:chumley_navigator/screens/job_details/raise_lead_page.dart';
import 'package:chumley_navigator/screens/job_details/service/appointments_api_service.dart';
import 'package:chumley_navigator/screens/job_details/works_form_page.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/call_style_action_slider.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:math' as math;

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

  bool _showOnSiteForm = true;
  final _jobs = JobsRepository();
  final _draftStore = FormDraftStore();
  late Appointment _appointment;
  String _currentStatus = '';
  List<String> _allowedNextStatuses = const [];
  bool _statusUpdating = false;
  bool _loadingDetail = true;

  /// After form submit: job completed → follow-on → visit complete.
  PostSubmitPhase? _postSubmitPhase;

  // Forms panel state
  List<EngineerFormSummary> _formsList = const [];
  bool _formsLoading = false;
  final Map<String, bool> _localFormCompletedOverrides = {};
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

  static const List<Color> _statusColors = [
    Color(0xFF27549D), // Dispatched
    Color(0xFFF59E0B), // In Transit
    Color(0xFF8B5CF6), // On site
    Color(0xFF3B82F6), // Job Closure
    Color(0xFF22C55E), // Visit Complete
  ];

  static const List<IconData> _statusIcons = [
    LucideIcons.bell,
    LucideIcons.navigation,
    LucideIcons.wrench,
    LucideIcons.clipboardCheck,
    LucideIcons.badgeCheck,
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
    _appointment = widget.appointment;
    _currentStatus = widget.appointment.status;
    _allowedNextStatuses = widget.appointment.allowedNextStatuses;
    Log('Job details: ${widget.appointment.toJson()}', name: 'JobDetail');
    _initializeMapAndLocation();
    _restoreVisit();
  }

  String get _jobId {
    final id = _appointment.id.trim();
    if (id.isNotEmpty) return id;
    return _appointment.appointmentNumber;
  }

  FormKind get _formKind {
    return FormKindResolver.kindOf(
      jobType: _appointment.type,
      trade: _appointment.type,
      workType: _appointment.type,
      description: _appointment.title,
    );
  }

  int get _progressIndex =>
      SaStatus.progressIndex(_currentStatus).clamp(0, _statusColors.length - 1);

  Color get _currentStatusColor => _statusColors[_progressIndex];

  IconData get _currentStatusIcon => _statusIcons[_progressIndex];

  String? get _primaryNextStatus =>
      _allowedNextStatuses.isNotEmpty ? _allowedNextStatuses.first : null;

  List<String> get _skipAheadStatuses => _allowedNextStatuses.length > 1
      ? _allowedNextStatuses.sublist(1)
      : const [];

  void _applyStatusResponse({
    required String status,
    required List<String> allowedNext,
  }) {
    _currentStatus = status;
    _allowedNextStatuses = allowedNext;

    if (SaStatus.isOnSite(status)) {
      _showOnSiteForm = true;
      _postSubmitPhase = null;
    } else if (SaStatus.isJobClosure(status)) {
      _showOnSiteForm = false;
      _postSubmitPhase ??= PostSubmitPhase.jobCompleted;
    } else if (SaStatus.isVisitComplete(status)) {
      _showOnSiteForm = false;
      _postSubmitPhase ??= PostSubmitPhase.visitComplete;
    }
  }

  Future<void> _advanceStatus(String targetStatus) async {
    if (targetStatus.trim().isEmpty || _statusUpdating) return;

    setState(() => _statusUpdating = true);
    try {
      // Local state progression without external API dependency
      final result = await _jobs.setStatus(saId: _jobId, status: targetStatus);
      if (!mounted) return;
      setState(() {
        _statusUpdating = false;
        if (result.appointment != null) {
          _appointment = result.appointment!;
        } else {
          _appointment = _appointment.copyWith(
            status: result.status,
            allowedNextStatuses: result.allowedNextStatuses,
          );
        }
        _applyStatusResponse(
          status: result.status,
          allowedNext: result.allowedNextStatuses,
        );
      });
    } catch (e) {
      Log('Status update failed: $e', name: 'JobDetail');
      if (!mounted) return;
      setState(() => _statusUpdating = false);
      final errorMsg = e is AppointmentApiException
          ? e.message
          : e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  Future<void> _advanceToJobClosure() async {
    try {
      final result = await _jobs.advanceToJobClosure(_jobId);
      if (result != null && mounted) {
        setState(() {
          if (result.appointment != null) {
            _appointment = result.appointment!;
          } else {
            _appointment = _appointment.copyWith(
              status: result.status,
              allowedNextStatuses: result.allowedNextStatuses,
            );
          }
          _currentStatus = result.status;
          _allowedNextStatuses = result.allowedNextStatuses;
        });
      }
    } catch (e) {
      Log('advanceToJobClosure failed: $e', name: 'JobDetail');
    }
  }

  Future<void> _handleFormSubmitted() async {
    await _advanceToJobClosure();
    if (!mounted) return;
    setState(() {
      _showOnSiteForm = false;
      _postSubmitPhase = PostSubmitPhase.jobCompleted;
    });
  }

  Future<void> _fetchForms() async {
    final id = _jobId.trim();
    if (id.isEmpty) return;
    setState(() => _formsLoading = true);
    try {
      final forms = await _jobs.fetchForms(id);
      if (!mounted) return;
      setState(() {
        _formsList = forms;
        _formsLoading = false;
      });
    } catch (e) {
      Log('Failed to fetch appointment forms for $id: $e', name: 'JobDetail');
      if (!mounted) return;
      setState(() => _formsLoading = false);
    }
  }

  Future<void> _restoreVisit() async {
    _fetchForms();
    setState(() => _loadingDetail = true);
    try {
      final detail = await _jobs.fetchAppointment(_jobId);
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        if (detail.appointment != null) {
          _appointment = detail.appointment!;
        }
        _applyStatusResponse(
          status: detail.status.isNotEmpty ? detail.status : _currentStatus,
          allowedNext: detail.allowedNextStatuses.isNotEmpty
              ? detail.allowedNextStatuses
              : _appointment.allowedNextStatuses,
        );
      });
      _resolveSitePosition();
    } catch (e) {
      Log('Failed to fetch appointment $_jobId: $e', name: 'JobDetail');
      final status =
          await _draftStore.loadStatus(_jobId) ?? widget.appointment.status;
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _applyStatusResponse(
          status: status,
          allowedNext: _appointment.allowedNextStatuses,
        );
      });
    }
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
      final dynamic appt = _appointment;
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
    if (_appointment.customerName.isNotEmpty) {
      return _appointment.customerName;
    }
    if (_appointment.customerContactName.isNotEmpty) {
      return _appointment.customerContactName;
    }
    final parts = _appointment.title.split(' - ');
    if (parts.length > 1) {
      return parts[1];
    }
    return _appointment.customerEmail.isNotEmpty
        ? _appointment.customerEmail
        : 'Phil Harris';
  }

  String get siteAddress {
    if (_appointment.siteAddress.isNotEmpty) {
      final addr = _appointment.siteAddress;
      final pc = _appointment.sitePostcode;
      if (pc.isNotEmpty && !addr.contains(pc)) {
        return '$addr, $pc';
      }
      return addr;
    }
    if (_appointment.siteName.isNotEmpty) {
      return _appointment.siteName;
    }
    final parts = _appointment.title.split(' - ');
    if (parts.length > 2) {
      return parts.sublist(2).join(', ');
    }
    return _appointment.title.isNotEmpty
        ? _appointment.title
        : '5 Brighton Queens Road, Brighton and Hove BN1 3XP, United Kingdom';
  }

  String get jobTitleDescription {
    if (_appointment.workType.isNotEmpty) {
      return _appointment.workType;
    }
    final parts = _appointment.title.split(' - ');
    if (parts.isNotEmpty) {
      final possibleDesc = parts[0];
      if (possibleDesc.startsWith('J-')) {
        return _appointment.type.isNotEmpty ? _appointment.type : 'Work Order';
      }
      return possibleDesc;
    }
    return _appointment.type.isNotEmpty ? _appointment.type : 'Work Order';
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    final start = _appointment.scheduledStart;
    final end = _appointment.scheduledEnd;
    final timeStr = start != null ? _formatTime(start) : '10:00';
    final timeEndStr = end != null
        ? _formatTime(end)
        : (start != null
              ? _formatTime(start.add(const Duration(hours: 1)))
              : '12:00');
    final formattedDate = start != null
        ? _formatDateString(start)
        : 'TUESDAY, JUN 9';

    final jobType = _appointment.type.isNotEmpty
        ? _appointment.type
        : 'Reactive';
    final jobNo = _appointment.appointmentNumber.isNotEmpty
        ? _appointment.appointmentNumber
        : 'SA-290627';

    final currentStatus = SaStatus.displayLabel(_currentStatus);
    final currentStatusColor = _currentStatusColor;
    final isCompleted = SaStatus.isVisitComplete(_currentStatus);
    final isJobClosure = SaStatus.isJobClosure(_currentStatus);
    final showPostSubmit = _postSubmitPhase != null || isJobClosure;
    final showOnSiteWizard =
        SaStatus.isOnSite(_currentStatus) &&
        !isCompleted &&
        !showPostSubmit &&
        _showOnSiteForm;

    final effectivePostSubmitPhase = _postSubmitPhase ??
        (isCompleted
            ? PostSubmitPhase.visitComplete
            : PostSubmitPhase.jobCompleted);

    VoidCallback postSubmitBack;
    switch (effectivePostSubmitPhase) {
      case PostSubmitPhase.jobClosed:
        postSubmitBack = () =>
            setState(() => _postSubmitPhase = PostSubmitPhase.followOn);
      case PostSubmitPhase.followOn:
        postSubmitBack = () =>
            setState(() => _postSubmitPhase = PostSubmitPhase.jobCompleted);
      case PostSubmitPhase.visitComplete:
        postSubmitBack = () =>
            setState(() => _postSubmitPhase = PostSubmitPhase.jobClosed);
      case PostSubmitPhase.jobCompleted:
        postSubmitBack = () => Navigator.of(context).pop();
    }

    Widget brandingHeader({required VoidCallback onBack}) {
      return Stack(
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
            child: CommandCentreBackButton(onTap: onBack),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: (showOnSiteWizard || showPostSubmit)
          ? const Color(0xFFF4F9FF)
          : theme.base,
      body: SafeArea(
        child: showPostSubmit
            ? Column(
                children: [
                  brandingHeader(onBack: postSubmitBack),
                  Expanded(
                    child: PostSubmitFlow(
                      phase: effectivePostSubmitPhase,
                      jobNumber: jobNo,
                      customerName: customerName,
                      jobType: jobType,
                      workTypeLabel: jobTitleDescription,
                      description: jobTitleDescription,
                      onPhaseChanged: (phase) async {
                        if (phase == PostSubmitPhase.visitComplete) {
                          await _advanceStatus(SaStatus.visitComplete);
                        }
                        if (mounted) {
                          setState(() => _postSubmitPhase = phase);
                        }
                      },
                      onCloseJob: () {
                        setState(() => _postSubmitPhase = PostSubmitPhase.followOn);
                      },
                      onVisitComplete: () async {
                        await _advanceStatus(SaStatus.visitComplete);
                        if (mounted) {
                          setState(() => _postSubmitPhase = PostSubmitPhase.visitComplete);
                        }
                      },
                      onBackToHome: () => Navigator.of(context).pop(),
                      onRaiseEstimate: () async {
                        await _openFixedPrice();
                        if (mounted) {
                          setState(() => _postSubmitPhase = PostSubmitPhase.jobClosed);
                        }
                      },
                      onRaiseReactive: () async {
                        await _openLead(RaiseLeadKind.reactive);
                        if (mounted) {
                          setState(() => _postSubmitPhase = PostSubmitPhase.jobClosed);
                        }
                      },
                      onReferAndEarn: () async {
                        await _openLead(RaiseLeadKind.refer);
                        if (mounted) {
                          setState(() => _postSubmitPhase = PostSubmitPhase.jobClosed);
                        }
                      },
                    ),
                  ),
                ],
              )
            : showOnSiteWizard
            ? _buildOnSiteForm(jobNo)
            : Stack(
                children: [
                  Column(
                    children: [
                      brandingHeader(onBack: () => Navigator.of(context).pop()),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 96.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusHeader(
                                theme,
                                currentStatus,
                                currentStatusColor,
                                jobNo,
                                jobType,
                              ),
                              _buildSectionLabel(theme, 'JOB DETAILS'),
                              _buildJobDetailsCard(theme, jobNo),
                              _buildSectionLabel(theme, 'SCHEDULE'),
                              _buildScheduleCard(
                                theme,
                                formattedDate,
                                timeStr,
                                timeEndStr,
                                jobNo,
                                currentStatus,
                              ),
                              _buildSectionLabel(theme, 'SITE'),
                              _buildSiteCard(theme),
                              if (isCompleted) _buildCompletedBanner(theme),
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
    final statusIcon = _currentStatusIcon;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Colour-coded status pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon(statusIcon, size: 12.sp, color: statusColor),
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.sp,
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
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E9F2),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  jobType,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A6B85),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E9F2),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  "Bathroom/Kitchen & Interfloor",
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A6B85),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Progress track (step dots)
          _buildStatusProgressTrack(theme, statusColor),
        ],
      ),
    );
  }

  Widget _buildStatusProgressTrack(DashboardTheme theme, Color statusColor) {
    const shortLabels = [
      'Dispatched',
      'In Transit',
      'On Site',
      'Job Closure',
      'Visit Complete',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dotSize = 8.w;
        final activeDotSize = 12.w;
        final colWidth = totalWidth / shortLabels.length;

        final lineStart = colWidth / 2;
        final lineEnd = totalWidth - colWidth / 2;
        final lineLength = lineEnd - lineStart;

        final progressIdx = _progressIndex;
        final activeFraction =
            (progressIdx.clamp(0, shortLabels.length - 1)) /
            (shortLabels.length - 1);
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
                  // Row of dots — completed steps show a check icon
                  Row(
                    children: List.generate(shortLabels.length, (i) {
                      final isActive = i <= progressIdx;
                      final isCurrent = i == progressIdx;
                      final isCompleted = i < progressIdx;
                      final size = isCompleted
                          ? 16.w
                          : isCurrent
                          ? activeDotSize
                          : dotSize;

                      return Expanded(
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            width: size,
                            height: size,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? statusColor
                                  : theme.isDark
                                  ? AppColors.darkBorder
                                  : AppColors.borderDefault,
                              shape: BoxShape.circle,
                              boxShadow: isCurrent && !isCompleted
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
                            child: isCompleted
                                ? Icon(
                                    LucideIcons.check,
                                    size: 10.sp,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: List.generate(shortLabels.length, (i) {
                final isActive = i <= progressIdx;
                final isCurrent = i == progressIdx;

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
      padding: EdgeInsets.zero,
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
                  onTap: (tapPosition, point) {
                    if (_sitePosition != null) {
                      _mapNavigationService.launchNavigation(
                        context: context,
                        destinationLat: _sitePosition!.latitude,
                        destinationLng: _sitePosition!.longitude,
                        address: siteAddress,
                      );
                    }
                  },
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

              // Floating Route Info Overlay (bottom-left) - Tap to open navigation
              if (_engineerPosition != null &&
                  _sitePosition != null &&
                  _distanceInMiles != null &&
                  _travelTimeMinutes != null)
                Positioned(
                  bottom: 10.h,
                  left: 10.w,
                  right: 50.w,
                  child: GestureDetector(
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _currentStatusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _currentStatusColor.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18.sp,
                    color: _currentStatusColor,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: theme.text,
                  ),
                ),
                Text(
                  '$timeStr – $timeEndStr',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Color(0xFFE3E9F2),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: theme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '2h window',
                    style: TextStyle(fontSize: 9.sp, color: theme.textMuted),
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
            _buildMapSection(theme),
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
      ('Appointment ID', jobNo),
      ('Type', _appointment.type.isNotEmpty ? _appointment.type : 'Reactive'),
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
            final isDescription = item.$1 == 'Description';
            final labelStyle = TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: theme.textMuted,
            );
            final valueStyle = TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: theme.text,
              height: 1.35,
            );
            final valueText = item.$2.isNotEmpty ? item.$2 : '—';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i > 0)
                  Divider(height: 14.h, color: theme.border, thickness: 0.5),
                if (isDescription)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: labelStyle),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFE3E9F2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          _appointment.workType.isNotEmpty
                              ? _appointment.workType
                              : (_appointment.title.isNotEmpty
                                    ? _appointment.title
                                    : jobTitleDescription),
                          style: valueStyle,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100.w,
                        child: Text(item.$1, style: labelStyle),
                      ),
                      Spacer(),
                      Expanded(child: Text(valueText, style: valueStyle)),
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
        onTap: null,
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

  bool get isOnSite => SaStatus.isOnSiteOrLater(_currentStatus);

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

  Future<void> _openFixedPrice() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.fixedPriceScreen,
      arguments: _appointment,
    );
  }

  Future<void> _openLead(RaiseLeadKind kind) async {
    await RaiseLeadPage.open(
      context,
      kind: kind,
      jobId: _jobId,
      jobNumber: _appointment.appointmentNumber,
    );
  }

  Widget _buildOnSiteForm(String jobNo) {
    switch (_formKind) {
      case FormKind.bath:
        return WorksFormPage(
          jobId: _jobId,
          jobNumber: jobNo,
          onCancelToInTransit: () {
            setState(() => _showOnSiteForm = false);
          },
          onSubmitted: () async {
            await _handleFormSubmitted();
          },
        );
      case FormKind.gas:
        return Cp12FormPage(
          appointmentNumber: jobNo,
          jobId: _jobId,
          onSubmitted: () async {
            await _jobs.signOff(
              jobId: _jobId,
              reportType: 'CP12',
              reportSuffix: 'gas_safety_record',
              answers: {'form': 'cp12'},
              photoSlots: const {},
            );
            await _handleFormSubmitted();
          },
        );
      case FormKind.leak:
        return OnSiteWizard(
          jobId: _jobId,
          jobNumber: jobNo,
          onCancelToInTransit: () {
            setState(() => _showOnSiteForm = false);
          },
          onReportSubmitted: (answers, photos) async {
            await _jobs.signOff(
              jobId: _jobId,
              reportType: 'LD',
              reportSuffix: 'leak_detection_report',
              answers: answers,
              photoSlots: photos,
            );
            await _handleFormSubmitted();
          },
        );
    }
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
              onTap: _openFixedPrice,
            ),
            SizedBox(height: 8.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'Raise Reactive',
              subtitle: 'Raise an urgent reactive task or callback',
              icon: LucideIcons.zap,
              enabled: onSite,
              onTap: () => _openLead(RaiseLeadKind.reactive),
            ),
            SizedBox(height: 8.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'PPM lead',
              subtitle: 'Send PPM interest to the office board',
              icon: LucideIcons.calendarClock,
              enabled: onSite,
              onTap: () => _openLead(RaiseLeadKind.ppm),
            ),
            SizedBox(height: 8.h),
            _buildRaiseJobItem(
              theme: theme,
              title: 'PM project lead',
              subtitle: 'Send PM interest. Does not create a project.',
              icon: LucideIcons.hammer,
              enabled: onSite,
              onTap: () => _openLead(RaiseLeadKind.pm),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFormByWorkType(String workTypeId, String title) async {
    if (!isOnSite) {
      _showOnSiteRequiredSnackbar();
      return;
    }
    final appt = _appointment;
    final workOrderId = appt.sourceWorkOrderId.isNotEmpty
        ? appt.sourceWorkOrderId
        : appt.id;
    final workOrderLabel = appt.appointmentNumber.isNotEmpty
        ? appt.appointmentNumber
        : workOrderId;
    final normalized = workTypeId.toLowerCase();

    Widget page;
    if (normalized.contains('damp')) {
      page = DampSurveyFormPage(
        saId: _jobId,
        workOrderId: workOrderId,
        workOrderLabel: workOrderLabel,
        workTypeId: workTypeId,
      );
    } else if (normalized.contains('vent')) {
      page = VentHygieneFormPage(
        saId: _jobId,
        workOrderId: workOrderId,
        workOrderLabel: workOrderLabel,
        workTypeId: workTypeId,
      );
    } else if (normalized.contains('cp12') || normalized.contains('gas')) {
      page = Cp12FormPage(jobId: _jobId, appointmentNumber: workOrderLabel);
    } else if (normalized.contains('works') || normalized.contains('bath')) {
      page = WorksFormPage(jobId: _jobId, jobNumber: workOrderLabel);
    } else {
      page = LdFormPage(
        saId: _jobId,
        workOrderId: workOrderId,
        workOrderLabel: workOrderLabel,
        workTypeId: workTypeId,
      );
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (result == true) {
      setState(() {
        _localFormCompletedOverrides[workTypeId] = true;
      });
    }
    await _fetchForms();
  }

  String _subtitleForWorkType(String workTypeId) {
    final wt = workTypeId.toLowerCase();
    if (wt.contains('ld') || wt.contains('leak')) {
      return 'Electrical Installation Condition Report · BS 7671:2018+A2:2022';
    }
    if (wt.contains('damp')) {
      return 'Surface / depth readings · BS 5250:2021';
    }
    if (wt.contains('vent')) {
      return 'Vent heat loss calculation · BS 8204:2011';
    }
    if (wt.contains('cp12') || wt.contains('gas')) {
      return 'Gas Safety Record · Landlord Certificate';
    }
    return 'Inspection & Certification Record';
  }

  Widget _buildFormsCard(DashboardTheme theme) {
    final pinkColor = const Color(0xFFEC4899);
    final onSite = isOnSite;

    // Build form display items from API fetched list or fallback standard forms
    final List<
      ({
        String workTypeId,
        String title,
        String subtitle,
        bool isCompleted,
        bool isDraft,
        ValueChanged<bool> onToggle,
        VoidCallback onTap,
      })
    >
    formItems;

    if (_formsList.isNotEmpty) {
      final activeForms = _formsList.where((form) {
        final wt = form.workTypeId.toLowerCase();
        // Comment out LD form for now — keep only HVAC / other active forms
        return !wt.contains('ld') && !wt.contains('leak');
      }).toList();

      formItems = activeForms.map((form) {
        final isCompleted =
            _localFormCompletedOverrides[form.workTypeId] ??
            form.isSubmitted ||
                form.status.toLowerCase() == 'completed' ||
                form.status.toLowerCase() == 'submitted';
        final isDraft = form.isDraft && !isCompleted;
        return (
          workTypeId: form.workTypeId,
          title: form.title.isNotEmpty ? form.title : form.workTypeId,
          subtitle: _subtitleForWorkType(form.workTypeId),
          isCompleted: isCompleted,
          isDraft: isDraft,
          onToggle: (bool v) {
            setState(() {
              _localFormCompletedOverrides[form.workTypeId] = v;
            });
          },
          onTap: () => _openFormByWorkType(form.workTypeId, form.title),
        );
      }).toList();
    } else {
      formItems = [
        // LD Form commented out for now — keeping HVAC only
        // (
        //   workTypeId: 'ld_form',
        //   title: 'LD Form',
        //   subtitle: 'Electrical Installation Condition Report · BS 7671:2018+A2:2022',
        //   isCompleted: _localFormCompletedOverrides['ld_form'] ?? _ldFormCompleted,
        //   isDraft: false,
        //   onToggle: (bool v) => setState(() {
        //     _ldFormCompleted = v;
        //     _localFormCompletedOverrides['ld_form'] = v;
        //   }),
        //   onTap: () => _openFormByWorkType('ld_form', 'LD Form'),
        // ),
        (
          workTypeId: 'vent_hygiene',
          title: 'Vent Hygiene Forms (HVAC)',
          subtitle: 'Vent heat loss calculation · BS 8204:2011',
          isCompleted:
              _localFormCompletedOverrides['vent_hygiene'] ??
              _ventHygieneCompleted,
          isDraft: false,
          onToggle: (bool v) => setState(() {
            _ventHygieneCompleted = v;
            _localFormCompletedOverrides['vent_hygiene'] = v;
          }),
          onTap: () =>
              _openFormByWorkType('vent_hygiene', 'Vent Hygiene Forms'),
        ),
      ];
    }

    final completedCount = formItems.where((e) => e.isCompleted).length;
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
                if (_formsLoading) ...[
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: pinkColor,
                    ),
                  ),
                ],
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
                  onTap: item.onTap,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: item.isCompleted
                          ? pinkColor.withValues(alpha: 0.06)
                          : theme.isDark
                          ? AppColors.darkSurfaceDeep
                          : AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: item.isCompleted
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
                            item.onToggle(!item.isCompleted);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: item.isCompleted
                                  ? pinkColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(
                                color: item.isCompleted
                                    ? pinkColor
                                    : theme.textMuted.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: item.isCompleted
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
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: onSite
                                            ? theme.text
                                            : theme.textMuted,
                                        decoration: item.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  if (item.isDraft)
                                    Container(
                                      margin: EdgeInsets.only(left: 6.w),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF59E0B,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Draft',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item.subtitle,
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
    final primary = _primaryNextStatus;
    final skipAhead = _skipAheadStatuses;

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
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: theme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            if (_loadingDetail)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: statusColor,
                  ),
                ),
              )
            else if (!isCompleted && primary != null)
              CallStyleActionSlider(
                text: SaStatus.actionLabel(primary),
                backgroundColor: statusColor,
                icon: _currentStatusIcon,
                isEnabled: !_statusUpdating,
                onConfirm: () => _advanceStatus(primary),
              )
            else if (isCompleted)
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
                      'Visit Complete',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
            if (skipAhead.isNotEmpty && !isCompleted && !_loadingDetail) ...[
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: skipAhead
                    .map((status) {
                      return OutlinedButton(
                        onPressed: _statusUpdating
                            ? null
                            : () => _advanceStatus(status),
                        child: Text(status),
                      );
                    })
                    .toList(growable: false),
              ),
            ],
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
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
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
                      color: Colors.grey.shade300,
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
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 16.h, color: Colors.grey.shade200),
                  ListTile(
                    leading: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.mapPin,
                        color: const Color(0xFF1A73E8),
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      'Google Maps',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Turn-by-turn navigation',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
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
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.navigation,
                        color: const Color(0xFF00ACC1),
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      'Waze',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Real-time traffic & alerts',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
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
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.compass,
                        color: const Color(0xFF2E7D32),
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      'Citymapper',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Urban routing & transit',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
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
