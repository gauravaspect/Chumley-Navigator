import 'package:chumley_navigator/screens/job_details/steps/ld_step_ui_helpers.dart';
import 'package:chumley_navigator/widgets/job/job_photo_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdPhotosStep extends StatelessWidget {
  const LdPhotosStep({
    super.key,
    required this.capturedPhotos,
    required this.onPhotoChanged,
  });

  final Map<String, String> capturedPhotos;
  final void Function(String key, String? path) onPhotoChanged;

  static const photoSlots = [
    ('Front of property *', 'front'),
    ('Affected area - overview *', 'overview'),
    ('Affected area - close-up *', 'closeup'),
    ('Water meter reading', 'meter'),
    ('Source - confirmed leak', 'source'),
    ('Test BEFORE - equipment + setup', 't_before'),
    ('Test AFTER - reading / result captured', 't_after'),
    ('Repair - completed work', 'repair'),
    ('Proposed access route (optional)', 'access_route'),
  ];

  @override
  Widget build(BuildContext context) {
    final captured = photoSlots
        .where((s) => (capturedPhotos[s.$2] ?? '').isNotEmpty)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdSectionCard(
          icon: LucideIcons.camera,
          title: 'Photographic evidence',
          subtitle:
              '$captured of ${photoSlots.length} attached. Required slots need a real photo.',
          children: [
            for (var i = 0; i < photoSlots.length; i++) ...[
              if (i > 0) SizedBox(height: 8.h),
              JobPhotoSlot(
                label: photoSlots[i].$1,
                filePath: capturedPhotos[photoSlots[i].$2],
                onChanged: (path) => onPhotoChanged(photoSlots[i].$2, path),
              ),
            ],
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: null,
              icon: Icon(LucideIcons.plus, size: 16.sp),
              label: const Text('Add extra'),
            ),
          ],
        ),
      ],
    );
  }
}
