import 'package:chumley_navigator/core/app_dependencies.dart';
import 'package:chumley_navigator/models/vehicle_model.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vehicle_check_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vehicle_check_state.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:chumley_navigator/shimmers/shimmer_box.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/routes.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/fade_slide_in.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_form_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_warning_banner.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VehileCheckScreen extends StatefulWidget {
  const VehileCheckScreen({super.key});

  static const _noVehiclesMessage =
      'No vehicles allocated to you. Please contact your manager.';

  @override
  State<VehileCheckScreen> createState() => _VehileCheckScreenState();
}

class _VehileCheckScreenState extends State<VehileCheckScreen> {
  late final VehicleCheckCubit _cubit;
  final _notesController = TextEditingController();
  bool _notesFocused = false;

  @override
  void initState() {
    super.initState();
    _cubit = AppDependencies.createVehicleCheckCubit()..load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  String _vehicleLabel(VehicleModel vehicle) {
    if (vehicle.vanNumber.trim().isNotEmpty) return vehicle.vanNumber.trim();
    if (vehicle.regNo.trim().isNotEmpty) return vehicle.regNo.trim();
    if (vehicle.vehicleName.trim().isNotEmpty) {
      return vehicle.vehicleName.trim();
    }
    return 'Vehicle';
  }

  void _startInspection(VehicleModel vehicle) {
    Navigator.pushNamed(
      context,
      AppRoutes.vehicleForm,
      arguments: VehicleFormArgs(
        vehicle: vehicle,
        dashboardNotes: _notesController.text.trim(),
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
          final fieldFill = theme.isDark
              ? theme.dashSurfaceTint
              : const Color(0xFFE9EDF5);
          final hairline = theme.isDark
              ? theme.dashBorderLight
              : const Color(0xFFE2E7F0);

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

              return Scaffold(
                backgroundColor: theme.base,
                body: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: theme.isDark
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF4F9FF),
                              Color(0xFFEDF4FE),
                              Color(0xFFE2ECFA),
                            ],
                            stops: [0, 0.55, 1],
                          ),
                    color: theme.isDark ? theme.base : null,
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 8.h, 20.w, 4.h),
                          child: Row(
                            children: [
                              SizedBox(width: 8.w),
                              Text(
                                'Vehicle report',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.dashHeading,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: theme.dashPrimary,
                            onRefresh: _cubit.refresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                8.h,
                                20.w,
                                24.h,
                              ),
                              children: [
                                FadeSlideIn(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vehicle details',
                                        style: TextStyle(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.7,
                                          color: theme.dashHeading,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Select your allocated vehicle and record inspection details before you start.',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          height: 1.4,
                                          color: theme.dashMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16.h),
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
                                            height: 14.h,
                                            width: 100.w,
                                            radius: 6,
                                          ),
                                          SizedBox(height: 10.h),
                                          ThemedShimmerBox(
                                            theme: theme,
                                            height: 48.h,
                                            radius: 12,
                                          ),
                                          SizedBox(height: 16.h),
                                          ThemedShimmerBox(
                                            theme: theme,
                                            height: 14.h,
                                            width: 120.w,
                                            radius: 6,
                                          ),
                                          SizedBox(height: 10.h),
                                          ThemedShimmerBox(
                                            theme: theme,
                                            height: 88.h,
                                            radius: 12,
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
                                            'Van number',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                              color: theme.dashSubtitle,
                                            ),
                                          ),
                                          SizedBox(height: 7.h),
                                          DropdownButtonFormField2<String>(
                                            value: selectedVehicle?.id,
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 14.w,
                                                vertical: 4.h,
                                              ),
                                              filled: true,
                                              fillColor: fieldFill,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12.r,
                                                ),
                                                borderSide: BorderSide(
                                                  color: hairline,
                                                ),
                                              ),
                                              enabledBorder:
                                                  OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12.r,
                                                ),
                                                borderSide: BorderSide(
                                                  color: hairline,
                                                ),
                                              ),
                                              focusedBorder:
                                                  OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12.r,
                                                ),
                                                borderSide: BorderSide(
                                                  color: theme.dashPrimary,
                                                  width: 1.25,
                                                ),
                                              ),
                                            ),
                                            hint: Text(
                                              vehicles.isEmpty
                                                  ? 'No vans available'
                                                  : 'Select van',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: theme.dashHeading,
                                              ),
                                            ),
                                            iconStyleData: IconStyleData(
                                              icon: Icon(
                                                LucideIcons.chevronDown,
                                                color:
                                                    const Color(0xFF8A99B0),
                                                size: 18.sp,
                                              ),
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              decoration: BoxDecoration(
                                                color: theme.dashCardBg,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12.r,
                                                ),
                                                border: Border.all(
                                                  color: hairline,
                                                ),
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: theme.dashHeading,
                                            ),
                                            items: vehicles
                                                .map(
                                                  (vehicle) =>
                                                      DropdownMenuItem(
                                                    value: vehicle.id,
                                                    child: Text(
                                                      _vehicleLabel(
                                                        vehicle,
                                                      ),
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
                                                        _cubit
                                                            .selectVehicle(
                                                          vehicle,
                                                        );
                                                        break;
                                                      }
                                                    }
                                                  },
                                          ),
                                          if (selectedVehicle != null &&
                                              selectedVehicle.regNo
                                                  .trim()
                                                  .isNotEmpty) ...[
                                            SizedBox(height: 10.h),
                                            Text(
                                              'Reg: ${selectedVehicle.regNo.trim()}',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: theme.dashMuted,
                                              ),
                                            ),
                                          ],
                                          SizedBox(height: 16.h),
                                          Text(
                                            'Dashboard notes',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                              color: theme.dashSubtitle,
                                            ),
                                          ),
                                          SizedBox(height: 7.h),
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            decoration: BoxDecoration(
                                              color: fieldFill,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                12.r,
                                              ),
                                              border: Border.all(
                                                color: _notesFocused
                                                    ? theme.dashPrimary
                                                    : hairline,
                                                width: _notesFocused
                                                    ? 1.25
                                                    : 1,
                                              ),
                                            ),
                                            child: TextField(
                                              controller: _notesController,
                                              maxLines: 3,
                                              onTap: () => setState(
                                                () =>
                                                    _notesFocused = true,
                                              ),
                                              onTapOutside: (_) =>
                                                  setState(
                                                () =>
                                                    _notesFocused = false,
                                              ),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                height: 1.45,
                                                color: theme.dashHeading,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Quick notes…',
                                                hintStyle: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: const Color(
                                                    0xFF8A99B0,
                                                  ),
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                  14.w,
                                                  13.h,
                                                  14.w,
                                                  40.h,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (showNoVehiclesBanner) ...[
                                  SizedBox(height: 12.h),
                                  const FadeSlideIn(
                                    delay: Duration(milliseconds: 50),
                                    child: VcrWarningBanner(
                                      message: VehileCheckScreen
                                          ._noVehiclesMessage,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 12.h),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 80),
                                  child: VcrFormCard(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            18.w,
                                            12.h,
                                            18.w,
                                            12.h,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "What you'll capture",
                                                  style: TextStyle(
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    letterSpacing: -0.2,
                                                    color:
                                                        theme.dashHeading,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${vcrSteps.length} areas',
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: theme.dashMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: hairline,
                                        ),
                                        for (var i = 0;
                                            i < vcrSteps.length;
                                            i++) ...[
                                          if (i > 0)
                                            Padding(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 18.w,
                                              ),
                                              child: Divider(
                                                height: 1,
                                                color: hairline,
                                              ),
                                            ),
                                          _CaptureAreaRow(
                                            theme: theme,
                                            index: i + 1,
                                            title: vcrSteps[i].title,
                                            photoLabel:
                                                vcrSteps[i].photoCountLabel,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            20.w,
                            12.h,
                            20.w,
                            12.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.isDark
                                ? theme.base.withValues(alpha: 0.92)
                                : Colors.white.withValues(alpha: 0.92),
                            border: Border(
                              top: BorderSide(color: hairline),
                            ),
                          ),
                          child: PressableScale(
                            onTap: selectedVehicle == null
                                ? null
                                : () =>
                                    _startInspection(selectedVehicle),
                            scale: 0.98,
                            child: Container(
                              width: double.infinity,
                              height: 44.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedVehicle != null
                                    ? AppColors.accentLime
                                    : AppColors.accentLime
                                        .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Text(
                                'Start inspection',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.dashHeading,
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
            },
          );
        },
      ),
    );
  }
}

class _CaptureAreaRow extends StatelessWidget {
  const _CaptureAreaRow({
    required this.theme,
    required this.index,
    required this.title,
    required this.photoLabel,
  });

  final DashboardTheme theme;
  final int index;
  final String title;
  final String photoLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: theme.isDark
                  ? theme.dashSurfaceTint
                  : const Color(0xFFD8E6FC),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: theme.dashPrimary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.dashHeading,
              ),
            ),
          ),
          Text(
            photoLabel,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.dashMuted,
            ),
          ),
        ],
      ),
    );
  }
}
