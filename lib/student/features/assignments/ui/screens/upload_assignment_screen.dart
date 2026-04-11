import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';

class UploadAssignmentScreen extends StatefulWidget {
  const UploadAssignmentScreen({super.key});

  @override
  State<UploadAssignmentScreen> createState() => _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Submit assignment',
          style: AppTextTheme.displaySmall.copyWith(fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASSIGNMENT',
                        style: AppTextTheme.badgeSm.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'User Research Report',
                        style: AppTextTheme.displaySmall.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UI/UX Design Masterclass · Due Apr 18, 2026',
                        style: AppTextTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Due in a few days',
                          style: AppTextTheme.badgeSm.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions',
                        style: AppTextTheme.displaySmall.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit a user research report analyzing 5 user interviews. '
                        'Include pain points, personas, and recommendations. PDF, max 10MB.',
                        style: AppTextTheme.bodyMedium
                            .copyWith(color: AppColors.textSecondary, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _uploaded = !_uploaded),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _uploaded
                          ? AppColors.successLight
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _uploaded ? AppColors.success : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _uploaded
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_outlined,
                          size: 44,
                          color:
                              _uploaded ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _uploaded
                              ? 'user_research_report.pdf'
                              : 'Tap to upload file',
                          style: AppTextTheme.bodySemibold,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _uploaded ? '2.4 MB · PDF' : 'PDF, DOC, PPT up to 10MB',
                          style: AppTextTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Notes (optional)',
                  style: AppTextTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a note to your instructor…',
                    hintStyle: AppTextTheme.inputHint,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: FilledButton(
              onPressed: _uploaded ? () => Navigator.of(context).pop() : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(_uploaded ? 'Submit assignment' : 'Upload file first'),
            ),
          ),
        ],
      ),
    );
  }
}
