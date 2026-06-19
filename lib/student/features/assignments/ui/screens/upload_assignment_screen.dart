import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';

class UploadAssignmentScreen extends StatefulWidget {
  const UploadAssignmentScreen({
    super.key,
    required this.assignmentId,
    required this.title,
    required this.description,
    required this.dueDate,
  });

  final String assignmentId;
  final String title;
  final String description;
  final String dueDate;

  @override
  State<UploadAssignmentScreen> createState() =>
      _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  PlatformFile? _pickedFile;
  bool _submitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    final file = _pickedFile;
    if (file == null) return;
    final bytes = file.bytes;
    if (bytes == null) return;
    setState(() => _submitting = true);
    try {
      final Dio dio = GetIt.instance<Dio>();
      final formData = FormData.fromMap({
        'File': MultipartFile.fromBytes(bytes, filename: file.name),
      });
      await dio.post<dynamic>(
        ApiEndpoints.submitAssignmentById(widget.assignmentId),
        data: formData,
        options: Options(headers: {'Accept': '*/*'}),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final msg = e is DioException
          ? 'Submit failed (${e.response?.statusCode ?? 'no connection'}). Try again.'
          : 'Failed to submit. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _pickedFile != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.surface,
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
                // Assignment info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASSIGNMENT',
                        style: AppTextTheme.badgeSm.copyWith(
                          color: context.textTertiary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.title,
                        style: AppTextTheme.displaySmall.copyWith(fontSize: 16),
                      ),
                      if (widget.dueDate.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Due: ${widget.dueDate}',
                            style: AppTextTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                if (widget.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions',
                          style:
                              AppTextTheme.displaySmall.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: AppTextTheme.bodyMedium.copyWith(
                            color: context.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // File picker area
                GestureDetector(
                  onTap: _submitting ? null : _pickFile,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: hasFile
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            hasFile ? AppColors.success : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          hasFile
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_outlined,
                          size: 44,
                          color: hasFile
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hasFile ? _pickedFile!.name : 'Tap to upload file',
                          style: AppTextTheme.bodySemibold,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasFile
                              ? '${_formatSize(_pickedFile!.size)} · ${(_pickedFile!.extension ?? 'file').toUpperCase()}'
                              : 'PDF, DOC, PPT up to 10MB',
                          style: AppTextTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(top: BorderSide(color: context.borderLight)),
            ),
            child: FilledButton(
              onPressed: (hasFile && !_submitting) ? _submit : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                disabledBackgroundColor: context.borderLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(hasFile ? 'Submit assignment' : 'Upload file first'),
            ),
          ),
        ],
      ),
    );
  }
}
