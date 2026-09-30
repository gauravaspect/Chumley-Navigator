import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_cubit.dart';
import 'package:chumley_navigator/screens/vehicle_check/cubit/vcr_examples_state.dart';
import 'package:chumley_navigator/screens/vehicle_check/vcr_step_data.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_example_photo_card.dart';
import 'package:chumley_navigator/widgets/vehicle/vcr_form_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Section rendering reference example photos for the active VCR step.
class VcrExamplesSection extends StatelessWidget {
  final DashboardTheme theme;
  final VcrStepData step;

  const VcrExamplesSection({
    super.key,
    required this.theme,
    required this.step,
  });

  List<String> _stepSections(VcrStepData step) =>
      step.captures.map((capture) => capture.id).toList(growable: false);

  bool _stateMatchesStep(VcrExamplesState state, List<String> stepSections) {
    return switch (state) {
      VcrExamplesLoading(:final sections) => listEquals(sections, stepSections),
      VcrExamplesLoaded(:final sections) => listEquals(sections, stepSections),
      VcrExamplesError(:final sections) => listEquals(sections, stepSections),
      _ => false,
    };
  }

  List<VcrExamplePhoto> _examplesForStep(
    VcrStepData step,
    Map<String, List<VcrExamplePhoto>> examplesBySection,
  ) {
    final photos = <VcrExamplePhoto>[];
    for (final capture in step.captures) {
      for (final photo in examplesBySection[capture.id] ?? const []) {
        if (photo.imageUrl.isEmpty) continue;
        photos.add(
          VcrExamplePhoto(
            label: photo.label.trim().isEmpty ? capture.label : photo.label,
            imageUrl: photo.imageUrl,
          ),
        );
      }
    }
    return photos;
  }

  @override
  Widget build(BuildContext context) {
    return VcrFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Example photos',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: theme.dashHeading,
                  ),
                ),
              ),
              Text(
                'Use these as a guide',
                style: TextStyle(fontSize: 13.sp, color: theme.dashMuted),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          BlocBuilder<VcrExamplesCubit, VcrExamplesState>(
            builder: (context, state) {
              final stepSections = _stepSections(step);
              final isLoading =
                  state is VcrExamplesLoading &&
                  _stateMatchesStep(state, stepSections);
              final currentExamples =
                  state is VcrExamplesLoaded &&
                      _stateMatchesStep(state, stepSections)
                  ? _examplesForStep(step, state.examplesBySection)
                  : const <VcrExamplePhoto>[];

              if (isLoading) {
                return SizedBox(
                  height: 110.h,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.dashPrimary,
                    ),
                  ),
                );
              }

              if (currentExamples.isEmpty) {
                return Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    for (final capture in step.captures)
                      _ExamplePlaceholder(theme: theme, label: capture.label),
                  ],
                );
              }

              return SizedBox(
                height: 130.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: currentExamples.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (_, index) {
                    final example = currentExamples[index];
                    return VcrExamplePhotoCard(
                      imageUrl: example.imageUrl,
                      label: example.label,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExamplePlaceholder extends StatelessWidget {
  const _ExamplePlaceholder({required this.theme, required this.label});

  final DashboardTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.w,
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: theme.isDark
                  ? theme.dashSurfaceTint
                  : const Color(0xFFE9EDF5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.image,
              size: 20.sp,
              color: const Color(0xFFC9DCF7),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: theme.dashMuted,
            ),
          ),
        ],
      ),
    );
  }
}
