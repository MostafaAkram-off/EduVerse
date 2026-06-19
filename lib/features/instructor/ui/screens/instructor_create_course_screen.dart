import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';

class InstructorCreateCourseScreen extends StatefulWidget {
  const InstructorCreateCourseScreen({super.key, required this.onCreated});
  final VoidCallback onCreated;

  @override
  State<InstructorCreateCourseScreen> createState() =>
      _InstructorCreateCourseScreenState();
}

class _InstructorCreateCourseScreenState
    extends State<InstructorCreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _priceCtrl       = TextEditingController();
  final _durationCtrl    = TextEditingController();
  final _categoryCtrl    = TextEditingController();

  String _level = 'Beginner';
  bool _isLoading = false;
  String? _error;

  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = GetIt.instance<Dio>();
      await dio.post<dynamic>(
        ApiEndpoints.createCourse,
        data: {
          'Name':        _titleCtrl.text.trim(),
          'Title':       _titleCtrl.text.trim(),
          'Description': _descCtrl.text.trim(),
          'Price':       double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
          'Duration':    double.tryParse(_durationCtrl.text.trim()) ?? 0.0,
          'Level':       _level,
          'Categories':  _categoryCtrl.text.trim(),
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (mounted) {
        widget.onCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      final msg = (e is DioException)
          ? (e.response?.data?['message']?.toString() ?? 'Failed to create course')
          : 'Failed to create course';
      setState(() { _error = msg; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Course', style: AppTextTheme.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.30)),
                ),
                child: Text(_error!,
                    style:
                        AppTextTheme.bodySmall.colored(AppColors.error)),
              ),
              const SizedBox(height: 16),
            ],

            _Field(
              label: 'Course Title',
              controller: _titleCtrl,
              hint: 'e.g. Flutter for Beginners',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            _Field(
              label: 'Description',
              controller: _descCtrl,
              hint: 'What will students learn?',
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            _Field(
              label: 'Category',
              controller: _categoryCtrl,
              hint: 'e.g. Mobile Dev, Web Dev, Design',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Category is required' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Price (USD)',
                    controller: _priceCtrl,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: 'Duration (hours)',
                    controller: _durationCtrl,
                    hint: '0.0',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text('Level',
                style: AppTextTheme.inputLabel.colored(context.textSecondary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.surface,
                border: Border.all(color: context.border),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _level,
                  isExpanded: true,
                  style: AppTextTheme.bodyMedium,
                  items: _levels
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _level = v);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable labeled text field ─────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextTheme.inputLabel.colored(context.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextTheme.inputHint.colored(context.textSecondary),
            filled: true,
            fillColor: context.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
