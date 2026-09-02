import 'dart:io';
import 'package:chumley_navigator/components/common/aspect_branding.dart';
import 'package:chumley_navigator/pillar/jobs_repository.dart';
import 'package:chumley_navigator/screens/job_details/service/photo_pipeline_service.dart';
import 'package:chumley_navigator/screens/job_details/service/pillar_client.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bathroom Works & Project Management Form (BF 1–5 journey)
/// Matches Figma screens s-2317-3931 … s-2317-4221 & works_runtime.js
class WorksFormPage extends StatefulWidget {
  const WorksFormPage({
    super.key,
    required this.workOrderId,
    required this.workOrderLabel,
    this.pmProjectId,
    this.customerName,
  });

  final String workOrderId;
  final String workOrderLabel;
  final String? pmProjectId;
  final String? customerName;

  @override
  State<WorksFormPage> createState() => _WorksFormPageState();
}

class _WorksFormPageState extends State<WorksFormPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  static const List<String> _tabs = [
    'Pre-Works & HSE',
    'Scope & Checklist',
    'Photos',
    'Materials & Parts',
    'Sign Off',
  ];

  // Pre-Works & HSE state
  bool _waterIsolated = true;
  bool _electricIsolated = true;
  bool _surfaceProtection = true;
  bool _ppeCompliant = true;
  final _accessNotesController = TextEditingController();

  // Scope & Checklist items
  final Map<String, bool> _plumbingTasks = {
    'Remove existing sanitary ware & fittings': true,
    'Alter hot & cold pipework runs': true,
    'Install isolation valves & check pressure': true,
    'Fit new bath / shower tray & waste trap': false,
    'Install thermostatic mixer shower / valves': false,
    'Fit wash hand basin, taps & waste': false,
    'Install close-coupled / back-to-wall WC': false,
  };

  final Map<String, bool> _finishingTasks = {
    'Apply waterproof tanking / membrane to wet zone': false,
    'Wall tiling & silicone sealing around sanitary ware': false,
    'Floor covering / tiling completed': false,
    'Test drainage & pressure test full installation': false,
  };

  // Photos state: slot -> localFilePath
  final Map<String, String> _photos = {
    'Pre-work Suite': '',
    'Pipework & Isolation': '',
    'Tanking / Waterproofing': '',
    'Completed Bathroom Installation': '',
  };

  // Materials & Parts
  final List<Map<String, String>> _materials = [
    {'name': '15mm Copper Tube (2m)', 'qty': '2', 'partNo': 'COP-15-2M'},
    {'name': '15mm Compression Isolation Valves', 'qty': '4', 'partNo': 'VAL-15-COMP'},
    {'name': 'Sanitary Silicone Sealant (White)', 'qty': '2', 'partNo': 'SIL-WHT-SAN'},
  ];
  final _matNameCtrl = TextEditingController();
  final _matQtyCtrl = TextEditingController();

  // Sign-off
  final _completionNotesController = TextEditingController();
  final _customerNameController = TextEditingController();
  bool _clientSatisfied = true;

  final _jobs = JobsRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _customerNameController.text = widget.customerName ?? '';
    _loadSavedDraft();
  }

  Future<void> _loadSavedDraft() async {
    final draftDetail = await _jobs.fetchFormDraft(
      saId: widget.workOrderId,
      workTypeId: 'PM_WORKS',
    );
    final draft = draftDetail?.answers ?? await PillarClient.getFormAnswers(widget.workOrderId);
    if (draft.isNotEmpty && mounted) {
      setState(() {
        _waterIsolated = draft['water_isolated'] ?? _waterIsolated;
        _electricIsolated = draft['electric_isolated'] ?? _electricIsolated;
        _surfaceProtection = draft['surface_protection'] ?? _surfaceProtection;
        _accessNotesController.text = draft['access_notes'] ?? '';
        _completionNotesController.text = draft['completion_notes'] ?? '';
      });
    }
    if (draftDetail != null && draftDetail.photoSlots.isNotEmpty && mounted) {
      setState(() {
        _photos.addAll(draftDetail.photoSlots);
      });
    }
  }

  Future<void> _saveDraftLocally() async {
    final data = {
      'water_isolated': _waterIsolated,
      'electric_isolated': _electricIsolated,
      'surface_protection': _surfaceProtection,
      'access_notes': _accessNotesController.text,
      'plumbing_tasks': _plumbingTasks,
      'finishing_tasks': _finishingTasks,
      'materials': _materials,
      'completion_notes': _completionNotesController.text,
      'client_satisfied': _clientSatisfied,
    };
    await _jobs.saveFormDraft(
      saId: widget.workOrderId,
      workTypeId: 'PM_WORKS',
      answers: data,
      photoSlots: _photos,
    );
  }

  Future<void> _pickPhoto(String slot, ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(source: source);
      if (xfile != null) {
        final compressedPath = await PhotoPipelineService.processPhoto(xfile.path);
        if (mounted && compressedPath != null) {
          setState(() {
            _photos[slot] = compressedPath;
          });
          await _saveDraftLocally();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access camera/gallery: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);
    await _saveDraftLocally();

    final answers = {
      'hse': {
        'water_isolated': _waterIsolated,
        'electric_isolated': _electricIsolated,
        'surface_protection': _surfaceProtection,
        'ppe_compliant': _ppeCompliant,
        'access_notes': _accessNotesController.text.trim(),
      },
      'plumbing_tasks': _plumbingTasks,
      'finishing_tasks': _finishingTasks,
      'materials_used': _materials,
      'sign_off': {
        'customer_name': _customerNameController.text.trim(),
        'client_satisfied': _clientSatisfied,
        'completion_notes': _completionNotesController.text.trim(),
        'signed_at': DateTime.now().toIso8601String(),
      },
    };

    try {
      await _jobs.submitForm(
        saId: widget.workOrderId,
        workTypeId: 'PM_WORKS',
        reportSuffix: 'pm',
        reportType: 'PM_WORKS',
        answers: answers,
        photoSlots: _photos,
        pmProjectId: widget.pmProjectId,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bathroom Works Report submitted.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting form: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accessNotesController.dispose();
    _matNameCtrl.dispose();
    _matQtyCtrl.dispose();
    _completionNotesController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBase : AppColors.backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            // Aspect Header
            AspectBranding(
              progress: 1.0,
              expandedHeight: 54.h,
              collapsedHeight: 54.h,
              theme: theme,
              hasBackButton: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BATHROOM WORKS (BF 1–5)',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
                    ),
                  ),
                  Text(
                    'WO: ${widget.workOrderLabel}',
                    style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: theme.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: theme.textMuted,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                tabAlignment: TabAlignment.start,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHseTab(theme),
                  _buildScopeTab(theme),
                  _buildPhotosTab(theme),
                  _buildMaterialsTab(theme),
                  _buildSignOffTab(theme),
                ],
              ),
            ),

            // Bottom Next / Submit Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(top: BorderSide(color: theme.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _saveDraftLocally();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Draft saved locally.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.border),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                    child: Text('Save Draft', style: TextStyle(color: theme.text)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _tabController.index == _tabs.length - 1
                            ? const Color(0xFF22C55E)
                            : AppColors.primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_tabController.index < _tabs.length - 1) {
                                _tabController.animateTo(_tabController.index + 1);
                                setState(() {});
                              } else {
                                _submitForm();
                              }
                            },
                      child: _isSubmitting
                          ? SizedBox(height: 18.h, width: 18.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              _tabController.index == _tabs.length - 1
                                  ? 'Submit Report & Sign Off'
                                  : 'Next Section',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.sp),
                            ),
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

  Widget _buildHseTab(DashboardTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            theme: theme,
            title: 'Pre-Works Isolation & Safety Verification',
            child: Column(
              children: [
                _buildSwitchRow(theme, 'Mains Water Isolated & Drained Down', _waterIsolated, (v) => setState(() => _waterIsolated = v)),
                _buildSwitchRow(theme, 'Local Electrical Circuits Isolated / Safe', _electricIsolated, (v) => setState(() => _electricIsolated = v)),
                _buildSwitchRow(theme, 'Floor & Carpet Protection Laid Down', _surfaceProtection, (v) => setState(() => _surfaceProtection = v)),
                _buildSwitchRow(theme, 'PPE Worn (Safety Boots, Gloves, Eye Protection)', _ppeCompliant, (v) => setState(() => _ppeCompliant = v)),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _buildCard(
            theme: theme,
            title: 'Site Access & Environmental Notes',
            child: TextField(
              controller: _accessNotesController,
              maxLines: 3,
              style: TextStyle(fontSize: 13.sp, color: theme.text),
              decoration: InputDecoration(
                hintText: 'e.g. Stopcock location verified in hallway cupboard, water drained cleanly...',
                hintStyle: TextStyle(color: theme.textMuted, fontSize: 12.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeTab(DashboardTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            theme: theme,
            title: 'Plumbing & Pipework Checklist',
            child: Column(
              children: _plumbingTasks.keys.map((task) {
                final val = _plumbingTasks[task] ?? false;
                return CheckboxListTile(
                  title: Text(task, style: TextStyle(fontSize: 13.sp, color: theme.text)),
                  value: val,
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _plumbingTasks[task] = v ?? false),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 14.h),
          _buildCard(
            theme: theme,
            title: 'Waterproofing, Tiling & Finishing',
            child: Column(
              children: _finishingTasks.keys.map((task) {
                final val = _finishingTasks[task] ?? false;
                return CheckboxListTile(
                  title: Text(task, style: TextStyle(fontSize: 13.sp, color: theme.text)),
                  value: val,
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _finishingTasks[task] = v ?? false),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(DashboardTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Photographic Evidence',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: theme.text),
          ),
          SizedBox(height: 4.h),
          Text(
            'Take clear photos for customer sign-off and quality assurance.',
            style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
          ),
          SizedBox(height: 12.h),
          ..._photos.keys.map((slot) {
            final path = _photos[slot] ?? '';
            final hasPhoto = path.isNotEmpty;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: theme.isDark ? AppColors.darkSurfaceDeep : AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: theme.border),
                    ),
                    child: hasPhoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(File(path), fit: BoxFit.cover),
                          )
                        : Icon(LucideIcons.camera, color: theme.textMuted, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slot, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: theme.text)),
                        SizedBox(height: 2.h),
                        Text(
                          hasPhoto ? 'Photo attached' : 'Required photo',
                          style: TextStyle(fontSize: 11.sp, color: hasPhoto ? const Color(0xFF22C55E) : theme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<ImageSource>(
                    icon: Icon(hasPhoto ? LucideIcons.checkCheck : LucideIcons.plus, color: hasPhoto ? const Color(0xFF22C55E) : AppColors.primaryBlue),
                    onSelected: (source) => _pickPhoto(slot, source),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: ImageSource.camera, child: Text('Take Camera Photo')),
                      const PopupMenuItem(value: ImageSource.gallery, child: Text('Choose from Gallery')),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab(DashboardTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            theme: theme,
            title: 'Materials & Sundries Logged',
            child: Column(
              children: [
                ..._materials.map((m) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(m['name'] ?? '', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: theme.text)),
                    subtitle: Text('Part: ${m['partNo']} · Qty: ${m['qty']}', style: TextStyle(fontSize: 11.sp, color: theme.textMuted)),
                    trailing: IconButton(
                      icon: Icon(LucideIcons.trash2, size: 16.sp, color: Colors.redAccent),
                      onPressed: () => setState(() => _materials.remove(m)),
                    ),
                  );
                }),
                Divider(color: theme.border),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _matNameCtrl,
                        style: TextStyle(fontSize: 12.sp, color: theme.text),
                        decoration: InputDecoration(hintText: 'Material Name', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r))),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: TextField(
                        controller: _matQtyCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 12.sp, color: theme.text),
                        decoration: InputDecoration(hintText: 'Qty', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r))),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h)),
                      onPressed: () {
                        if (_matNameCtrl.text.isNotEmpty) {
                          setState(() {
                            _materials.add({
                              'name': _matNameCtrl.text.trim(),
                              'qty': _matQtyCtrl.text.trim().isEmpty ? '1' : _matQtyCtrl.text.trim(),
                              'partNo': 'CUSTOM',
                            });
                            _matNameCtrl.clear();
                            _matQtyCtrl.clear();
                          });
                        }
                      },
                      child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOffTab(DashboardTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            theme: theme,
            title: 'Customer Acceptance & Satisfaction',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer / Client Name', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
                SizedBox(height: 4.h),
                TextField(controller: _customerNameController, style: TextStyle(fontSize: 13.sp, color: theme.text), decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
                SizedBox(height: 12.h),
                _buildSwitchRow(theme, 'Customer Confirms Workmanship Completed Satisfactorily', _clientSatisfied, (v) => setState(() => _clientSatisfied = v)),
                SizedBox(height: 12.h),
                Text('Engineer Sign-off Notes & Remarks', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.text)),
                SizedBox(height: 4.h),
                TextField(
                  controller: _completionNotesController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 13.sp, color: theme.text),
                  decoration: InputDecoration(
                    hintText: 'e.g. All plumbing pressure tested, suite fully sealed, client demonstrated controls...',
                    hintStyle: TextStyle(color: theme.textMuted, fontSize: 12.sp),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required DashboardTheme theme, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: theme.text)),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchRow(DashboardTheme theme, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 13.sp, color: theme.text))),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
