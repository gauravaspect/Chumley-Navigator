import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vehicle_check_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vehicle_check_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_form_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_page_header.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_warning_banner.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehileCheckScreen extends StatefulWidget {
  const VehileCheckScreen({super.key});

  static const _noVehiclesMessage =
      'No vehicles allocated to you. Please contact your manager.';

  static const _instructions = [
    'Please ensure that all 21 required photographs are uploaded in full. Failure to provide any of the required images will prevent progression to the next stage.',
    'Each photograph must strictly adhere to the provided reference examples. Images that are captured from incorrect angles and do not comply with the specified guidelines may be flagged as invalid by the system.',
    'Kindly verify that all photographs are clear, properly aligned, and meet the outlined requirements prior to submission.',
    'Please make sure you have selected the current vehicle from the drop down menu before continuing.',
  ];

  @override
  State<VehileCheckScreen> createState() => _VehileCheckScreenState();
}

class _VehileCheckScreenState extends State<VehileCheckScreen> {
  late final VehicleCheckCubit _cubit;
  final _scrollController = ScrollController();
  final ValueNotifier<double> _collapseProgress = ValueNotifier(0);

  static const double _brandingExpandedHeight = 72;
  static const double _brandingCollapsedHeight = 54;
  static const double _scrollThreshold = 100;

  static double _easedCollapseProgress(double offset) {
    final raw = (offset / _scrollThreshold).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  void _onScroll() {
    final progress = _easedCollapseProgress(_scrollController.offset);
    if (_collapseProgress.value != progress) {
      _collapseProgress.value = progress;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _cubit = AppDependencies.createVehicleCheckCubit()..load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    _cubit.close();
    super.dispose();
  }

  String _vehicleLabel(VehicleModel vehicle) {
    if (vehicle.regNo.trim().isNotEmpty) return vehicle.regNo.trim();
    if (vehicle.vehicleName.trim().isNotEmpty) return vehicle.vehicleName.trim();
    if (vehicle.vanNumber.trim().isNotEmpty) return vehicle.vanNumber.trim();
    return 'Vehicle';
  }

  OutlineInputBorder _inputBorder(DashboardTheme theme, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(
        color: focused ? theme.accent : theme.border,
        width: focused ? 1 : 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: ListenableBuilder(
        listenable: ThemeScope.of(context),
        builder: (context, _) {
          final theme = DashboardTheme.of(context);

          return BlocConsumer<VehicleCheckCubit, VehicleCheckState>(
            listener: (context, state) {
              if (state is VehicleCheckError && !state.hasVehicles) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              final vehicles = state.vehicles;
              final selectedVehicle = state.selectedVehicleOrNull;
              final showVehicleShimmer = state is VehicleCheckInitial ||
                  (state is VehicleCheckLoading && vehicles.isEmpty);
              final showNoVehiclesBanner =
                  !showVehicleShimmer && vehicles.isEmpty;
              final canContinue = selectedVehicle != null;

              return Scaffold(
                backgroundColor: theme.base,
                body: SafeArea(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        color: theme.dashPrimary,
                        onRefresh: _cubit.refresh,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: _brandingExpandedHeight + 28,
                            bottom: 112.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // SizedBox(height: 14.h),
                              const FadeSlideIn(child: VcrPageHeader()),
                              SizedBox(height: 12.h),
                              if (showVehicleShimmer)
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 40),
                                  child: VcrFormCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ThemedShimmerBox(
                                          theme: theme,
                                          height: 10.h,
                                          width: 120.w,
                                          radius: 4,
                                        ),
                                        SizedBox(height: 10.h),
                                        ThemedShimmerBox(
                                          theme: theme,
                                          height: 40.h,
                                          radius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 40),
                                  child: VcrFormCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'YOUR ALLOCATED VEHICLE',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                            color: theme.textBody,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          'Select the vehicle for this inspection',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w400,
                                            color: theme.textMuted,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'Vehicle',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: theme.textMuted,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        DropdownButtonFormField2<String>(
                                          value: selectedVehicle?.id,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 10.h,
                                            ),
                                            filled: true,
                                            fillColor: theme.surfaceDeep,
                                            border: _inputBorder(theme),
                                            enabledBorder: _inputBorder(theme),
                                            focusedBorder: _inputBorder(
                                              theme,
                                              focused: true,
                                            ),
                                          ),
                                          hint: Text(
                                            vehicles.isEmpty
                                                ? 'No vehicles available'
                                                : 'Select vehicle',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: theme.textMuted,
                                            ),
                                          ),
                                          iconStyleData: IconStyleData(
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: theme.textMuted,
                                              size: 20.sp,
                                            ),
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              color: theme.surface,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              border: Border.all(
                                                color: theme.border,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: theme.text,
                                          ),
                                          items: vehicles
                                              .map(
                                                (vehicle) =>
                                                    DropdownMenuItem(
                                                  value: vehicle.id,
                                                  child: Text(
                                                    _vehicleLabel(vehicle),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: vehicles.isEmpty
                                              ? null
                                              : (vehicleId) {
                                                  for (final vehicle
                                                      in vehicles) {
                                                    if (vehicle.id ==
                                                        vehicleId) {
                                                      _cubit.selectVehicle(
                                                        vehicle,
                                                      );
                                                      break;
                                                    }
                                                  }
                                                },
                                        ),
                                        if (selectedVehicle != null) ...[
                                          SizedBox(height: 12.h),
                                          _VehicleDetailRow(
                                            theme: theme,
                                            label: 'Registration',
                                            value: selectedVehicle.regNo,
                                          ),
                                          if (selectedVehicle.vanNumber
                                              .trim()
                                              .isNotEmpty)
                                            _VehicleDetailRow(
                                              theme: theme,
                                              label: 'Van number',
                                              value: selectedVehicle.vanNumber,
                                            ),
                                          if (selectedVehicle.vehicleName
                                              .trim()
                                              .isNotEmpty)
                                            _VehicleDetailRow(
                                              theme: theme,
                                              label: 'Vehicle name',
                                              value: selectedVehicle.vehicleName,
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              if (showNoVehiclesBanner) ...[
                                SizedBox(height: 12.h),
                                const FadeSlideIn(
                                  delay: Duration(milliseconds: 50),
                                  child: VcrWarningBanner(
                                    message: VehileCheckScreen._noVehiclesMessage,
                                  ),
                                ),
                              ],
                              SizedBox(height: 12.h),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 100),
                                child: VcrFormCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'STEP 1 INSTRUCTIONS',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.4,
                                          color: theme.textBody,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Read before starting the vehicle check',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          color: theme.textMuted,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      for (var i = 0;
                                          i <
                                              VehileCheckScreen
                                                  ._instructions.length;
                                          i++) ...[
                                        Text(
                                          VehileCheckScreen._instructions[i],
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w400,
                                            height: 1.45,
                                            color: theme.textMuted,
                                          ),
                                        ),
                                        if (i <
                                            VehileCheckScreen
                                                    ._instructions.length -
                                                1)
                                          SizedBox(height: 10.h),
                                      ],
                                      SizedBox(height: 14.h),
                                      _ContinueButton(
                                        enabled: canContinue,
                                        onTap: canContinue
                                            ? () => Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.vehicleForm,
                                                  arguments: selectedVehicle,
                                                )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _collapseProgress,
                        builder: (context, progress, _) {
                          return Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: AspectBranding(
                              progress: progress,
                              expandedHeight: _brandingExpandedHeight,
                              collapsedHeight: _brandingCollapsedHeight,
                              theme: theme,
                              title: Text(
                                'Vehicle check Report',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: theme.textBody,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VehicleDetailRow extends StatelessWidget {
  const _VehicleDetailRow({
    required this.theme,
    required this.label,
    required this.value,
  });

  final DashboardTheme theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: theme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              trimmed,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.onTap,
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Continue to vehicle details',
      button: true,
      enabled: enabled,
      child: PressableScale(
        onTap: enabled ? onTap : null,
        scale: 0.98,
        child: Container(
          width: double.infinity,
          height: 46.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'Continue to vehicle details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
