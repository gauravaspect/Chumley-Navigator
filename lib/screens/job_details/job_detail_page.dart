import 'dart:async';
import 'dart:math' as math;

import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/log.dart';
import 'package:chumley_navigator/models/fixed_price_job_context.dart';
import 'package:chumley_navigator/models/sa_status.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/pillar/form_draft_store.dart';
import 'package:chumley_navigator/pillar/form_kind.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/pillar/on_site_forms_session.dart';
import 'package:chumley_navigator/screens/job_details/on_site_wizard.dart';
import 'package:chumley_navigator/screens/job_details/post_submit_flow.dart';
import 'package:chumley_navigator/screens/job_details/raise_lead_page.dart';
import 'package:chumley_navigator/screens/job_details/raise_multiple_fixed_price_page.dart';
import 'package:chumley_navigator/screens/job_details/raise_reactive_job_page.dart';
import 'package:chumley_navigator/screens/job_details/service/appointments_api_service.dart';
import 'package:chumley_navigator/screens/job_details/service/geocoding_service.dart';
import 'package:chumley_navigator/screens/job_details/service/location_service.dart';
import 'package:chumley_navigator/screens/job_details/service/map_navigation_service.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_actions_panel.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_details_card.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_raise_jobs_card.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_schedule_card.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_site_card.dart';
import 'package:chumley_navigator/screens/job_details/widgets/job_status_header.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/ui/command_centre_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  bool _formsDismissed = false;
  final _jobs = JobsRepository();
  final _draftStore = FormDraftStore();
  late Appointment _appointment;
  String _currentStatus = '';
  List<String> _allowedNextStatuses = const [];
  bool _statusUpdating = false;
  bool _loadingDetail = true;

  /// After form submit: job completed → follow-on → visit complete.
  PostSubmitPhase? _postSubmitPhase;

  /// True once the 12-step OnSiteWizard has been submitted for this visit.
  bool _onSiteWizardSubmitted = false;

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
    Color(0xFF0891B2), // Received
    Color(0xFFF59E0B), // In Transit
    Color(0xFF8B5CF6), // On site
    Color(0xFF3B82F6), // Job Closure
    Color(0xFF22C55E), // Visit Complete
  ];

  static const List<IconData> _statusIcons = [
    LucideIcons.bell,
    LucideIcons.checkCheck,
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

  int get _progressIndex => SaStatus.progressIndex(
    _currentStatus,
  ).clamp(0, SaStatus.progressLabels.length - 1);

  Color get _currentStatusColor => _statusColors[_progressIndex];

  IconData get _currentStatusIcon => _statusIcons[_progressIndex];

  String? get _primaryNextStatus =>
      _allowedNextStatuses.isNotEmpty ? _allowedNextStatuses.first : null;

  List<String> get _skipAheadStatuses => _allowedNextStatuses.length > 1
      ? _allowedNextStatuses.sublist(1)
      : const [];

  Future<void> _dismissOnSiteForms() async {
    _formsDismissed = true;
    await _draftStore.saveFormsDismissed(_jobId, true);
    if (mounted) setState(() {});
  }

  Future<void> _resumeFillingForms() async {
    _formsDismissed = false;
    await _draftStore.saveFormsDismissed(_jobId, false);
    if (mounted) setState(() {});
  }

  void _applyStatusResponse({
    required String status,
    required List<String> allowedNext,
  }) {
    _currentStatus = status;
    _allowedNextStatuses = allowedNext;

    if (SaStatus.isOnSite(status)) {
      _postSubmitPhase = null;
    } else if (SaStatus.isJobClosure(status)) {
      _postSubmitPhase ??= PostSubmitPhase.jobCompleted;
    } else if (SaStatus.isVisitComplete(status)) {
      _postSubmitPhase ??= PostSubmitPhase.visitComplete;
    }
  }

  bool get _areRequiredFormsCompleted {
    if (_onSiteWizardSubmitted) return true;
    return SaStatus.isJobClosure(_currentStatus) ||
        SaStatus.isVisitComplete(_currentStatus);
  }

  void _showFormsRequiredSnack() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Complete all required forms before Job Closure.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Future<void> _advanceStatus(String targetStatus) async {
    if (targetStatus.trim().isEmpty || _statusUpdating) return;

    if (SaStatus.isJobClosure(targetStatus) && !_areRequiredFormsCompleted) {
      _showFormsRequiredSnack();
      return;
    }

    setState(() => _statusUpdating = true);
    try {
      final result = await _jobs.setStatus(saId: _jobId, status: targetStatus);
      if (!mounted) return;
      setState(() {
        _statusUpdating = false;
        if (result.appointment != null) {
          _appointment = _appointment.mergePreservingWorkOrderContext(
            result.appointment!,
          );
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

  Future<void> _advanceToJobClosure({bool afterFormSubmit = false}) async {
    if (!afterFormSubmit && !_areRequiredFormsCompleted) {
      if (mounted) _showFormsRequiredSnack();
      return;
    }
    try {
      final result = await _jobs.advanceToJobClosure(_jobId);
      if (result != null && mounted) {
        setState(() {
          if (result.appointment != null) {
            _appointment = _appointment.mergePreservingWorkOrderContext(
              result.appointment!,
            );
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
    await _draftStore.saveFormsDismissed(_jobId, false);
    await _advanceToJobClosure(afterFormSubmit: true);
    if (!mounted) return;
    setState(() {
      _formsDismissed = false;
      _onSiteWizardSubmitted = true;
      _postSubmitPhase = PostSubmitPhase.jobCompleted;
    });
  }

  Future<void> _restoreVisit() async {
    setState(() => _loadingDetail = true);
    try {
      final detail = await _jobs.fetchAppointment(_jobId);
      final dismissed = await _draftStore.loadFormsDismissed(_jobId);
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _formsDismissed = dismissed;
        if (detail.appointment != null) {
          _appointment = _appointment.mergePreservingWorkOrderContext(
            detail.appointment!,
          );
        }
        _applyStatusResponse(
          status: detail.status.isNotEmpty ? detail.status : _currentStatus,
          allowedNext: detail.allowedNextStatuses.isNotEmpty
              ? detail.allowedNextStatuses
              : _appointment.allowedNextStatuses,
        );
        if (SaStatus.isJobClosure(_currentStatus) ||
            SaStatus.isVisitComplete(_currentStatus)) {
          _onSiteWizardSubmitted = true;
        }
      });
      _resolveSitePosition();
    } catch (e) {
      Log('Failed to fetch appointment $_jobId: $e', name: 'JobDetail');
      final status =
          await _draftStore.loadStatus(_jobId) ?? widget.appointment.status;
      final dismissed = await _draftStore.loadFormsDismissed(_jobId);
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _formsDismissed = dismissed;
        _applyStatusResponse(
          status: status,
          allowedNext: _appointment.allowedNextStatuses,
        );
        if (SaStatus.isJobClosure(_currentStatus) ||
            SaStatus.isVisitComplete(_currentStatus)) {
          _onSiteWizardSubmitted = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeMapAndLocation() async {
    _resolveSitePosition();
    _setupEngineerLocation();
  }

  Future<void> _resolveSitePosition() async {
    if (mounted) setState(() => _geocodingLoading = true);
    LatLng? resolvedPosition;

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

    final centerLat = (engineerLatLng.latitude + _sitePosition!.latitude) / 2;
    final centerLng = (engineerLatLng.longitude + _sitePosition!.longitude) / 2;
    final center = LatLng(centerLat, centerLng);

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

    final distanceInMiles = distanceInMeters * 0.000621371;
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
    final contextArgs = FixedPriceJobContext.fromAppointment(_appointment);
    Log(
      'Opening FP estimate: wo=${contextArgs.sourceWorkOrderId} '
      'site=${contextArgs.siteId} account=${contextArgs.accountId}',
      name: 'JobDetail',
    );
    await Navigator.pushNamed(
      context,
      AppRoutes.fixedPriceScreen,
      arguments: contextArgs,
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

  Future<void> _openReactiveJob() async {
    await RaiseReactiveJobPage.open(
      context,
      jobId: _jobId,
      jobNumber: _appointment.appointmentNumber,
      customerName: _appointment.customerName,
      postcode: _appointment.sitePostcode,
    );
  }

  Future<void> _openMultipleFixedPrice() async {
    await RaiseMultipleFixedPricePage.open(
      context,
      jobId: _jobId,
      jobNumber: _appointment.appointmentNumber,
      customerName: _appointment.customerName,
      postcode: _appointment.sitePostcode,
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

  Widget _buildCompletedBanner(DashboardTheme theme) {
    const greenColor = Color(0xFF22C55E);

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

  Widget _buildOnSiteForm(String jobNo) {
    return OnSiteWizard(
      jobId: _jobId,
      jobNumber: jobNo,
      onCancelToInTransit: () {
        _dismissOnSiteForms();
      },
      onReportSubmitted: (answers, photos) async {
        final kind = _formKind;
        await _jobs.signOff(
          jobId: _jobId,
          reportType: switch (kind) {
            FormKind.gas => 'CP12',
            FormKind.bath => 'WORKS',
            FormKind.leak => 'LD',
          },
          reportSuffix: switch (kind) {
            FormKind.gas => 'gas_safety_record',
            FormKind.bath => 'works_report',
            FormKind.leak => 'leak_detection_report',
          },
          answers: answers,
          photoSlots: photos,
        );
        await _handleFormSubmitted();
      },
    );
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
        !isCompleted &&
        !showPostSubmit &&
        OnSiteFormsSession.shouldShowWizard(
          isOnSite: SaStatus.isOnSite(_currentStatus),
          formsDismissed: _formsDismissed,
        );

    final effectivePostSubmitPhase =
        _postSubmitPhase ??
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
          ? (theme.isDark ? theme.base : const Color(0xFFF4F9FF))
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
                        setState(
                          () => _postSubmitPhase = PostSubmitPhase.followOn,
                        );
                      },
                      onVisitComplete: () async {
                        await _advanceStatus(SaStatus.visitComplete);
                        if (mounted) {
                          setState(
                            () => _postSubmitPhase =
                                PostSubmitPhase.visitComplete,
                          );
                        }
                      },
                      onBackToHome: () => Navigator.of(context).pop(),
                      onRaiseEstimate: () async {
                        await _openFixedPrice();
                        if (mounted) {
                          setState(
                            () => _postSubmitPhase = PostSubmitPhase.jobClosed,
                          );
                        }
                      },
                      onRaiseReactive: () async {
                        await _openReactiveJob();
                        if (mounted) {
                          setState(
                            () => _postSubmitPhase = PostSubmitPhase.jobClosed,
                          );
                        }
                      },
                      onRaiseMultipleFixedPrice: () async {
                        await _openMultipleFixedPrice();
                        if (mounted) {
                          setState(
                            () => _postSubmitPhase = PostSubmitPhase.jobClosed,
                          );
                        }
                      },
                      onReferAndEarn: () async {
                        await _openLead(RaiseLeadKind.refer);
                        if (mounted) {
                          setState(
                            () => _postSubmitPhase = PostSubmitPhase.jobClosed,
                          );
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
                              JobStatusHeader(
                                theme: theme,
                                status: currentStatus,
                                statusColor: currentStatusColor,
                                jobNo: jobNo,
                                jobType: jobType,
                                progressIndex: _progressIndex,
                              ),
                              _buildSectionLabel(theme, 'RAISE JOBS'),
                              JobRaiseJobsCard(
                                theme: theme,
                                isOnSite: isOnSite,
                                onRaiseFixedPrice: _openFixedPrice,
                                onRaiseReactive: _openReactiveJob,
                                onRaiseMultipleFixedPrice: _openMultipleFixedPrice,
                                onDisabledTap: _showOnSiteRequiredSnackbar,
                              ),
                              _buildSectionLabel(theme, 'JOB DETAILS'),
                              JobDetailsCard(
                                theme: theme,
                                appointment: _appointment,
                                jobNo: jobNo,
                                customerName: customerName,
                                jobTitleDescription: jobTitleDescription,
                              ),
                              _buildSectionLabel(theme, 'SCHEDULE'),
                              JobScheduleCard(
                                theme: theme,
                                statusColor: _currentStatusColor,
                                formattedDate: formattedDate,
                                timeStr: timeStr,
                                timeEndStr: timeEndStr,
                              ),
                              _buildSectionLabel(theme, 'SITE'),
                              JobSiteCard(
                                theme: theme,
                                customerName: customerName,
                                siteAddress: siteAddress,
                                mapController: _mapController,
                                sitePosition: _sitePosition,
                                engineerPosition: _engineerPosition,
                                distanceInMiles: _distanceInMiles,
                                travelTimeMinutes: _travelTimeMinutes,
                                locationLoading: _locationLoading,
                                geocodingLoading: _geocodingLoading,
                                onOpenMaps: () {
                                  if (_sitePosition != null) {
                                    _mapNavigationService.launchNavigation(
                                      context: context,
                                      destinationLat: _sitePosition!.latitude,
                                      destinationLng: _sitePosition!.longitude,
                                      address: siteAddress,
                                    );
                                  }
                                },
                                onFitBounds: _fitMapBounds,
                              ),
                              if (isCompleted) _buildCompletedBanner(theme),
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  JobActionsPanel(
                    theme: theme,
                    statusColor: currentStatusColor,
                    statusIcon: _currentStatusIcon,
                    currentStatus: _currentStatus,
                    isCompleted: isCompleted,
                    loadingDetail: _loadingDetail,
                    statusUpdating: _statusUpdating,
                    primaryNextStatus: _primaryNextStatus,
                    skipAheadStatuses: _skipAheadStatuses,
                    areRequiredFormsCompleted: _areRequiredFormsCompleted,
                    onPrimaryAction: () {
                      if (OnSiteFormsSession.shouldResumeForms(
                        isOnSite: SaStatus.isOnSite(_currentStatus),
                        formsCompleted: _areRequiredFormsCompleted,
                        primaryNextStatus: _primaryNextStatus,
                      )) {
                        _resumeFillingForms();
                        return;
                      }
                      if (_primaryNextStatus != null) {
                        _advanceStatus(_primaryNextStatus!);
                      }
                    },
                    onResumeForms: _resumeFillingForms,
                    onSkipAheadAction: _advanceStatus,
                  ),
                ],
              ),
      ),
    );
  }
}
