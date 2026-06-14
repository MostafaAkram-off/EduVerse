import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';

// ─── Field model ─────────────────────────────────────────────────────────────

class EditProfileField {
  const EditProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? hint;
}

// ─── Sheet entry point ────────────────────────────────────────────────────────

/// Shows the modern edit-profile bottom sheet.
/// Call this from profile screens instead of building inline.
Future<void> showEditProfileSheet({
  required BuildContext context,
  required String title,
  required String initials,
  required List<Color> gradientColors,
  required List<EditProfileField> fields,
  required VoidCallback onSave,
  String saveLabel = 'Save Changes',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProfileSheet(
      title: title,
      initials: initials,
      gradientColors: gradientColors,
      fields: fields,
      onSave: onSave,
      saveLabel: saveLabel,
    ),
  );
}

// ─── Sheet widget ─────────────────────────────────────────────────────────────

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet({
    required this.title,
    required this.initials,
    required this.gradientColors,
    required this.fields,
    required this.onSave,
    required this.saveLabel,
  });

  final String title;
  final String initials;
  final List<Color> gradientColors;
  final List<EditProfileField> fields;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.6,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // ── Drag handle ──
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  // ── Avatar header ──────────────────────────────────
                  _AvatarHeader(
                    title: title,
                    initials: initials,
                    gradientColors: gradientColors,
                  ),

                  const SizedBox(height: 28),

                  // ── Fields ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personal Information',
                            style: AppTextTheme.sectionHeader),
                        const SizedBox(height: 16),
                        ...fields.map((f) => _AnimatedField(field: f)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Save button ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _GradientButton(
                      label: saveLabel,
                      gradientColors: gradientColors,
                      onTap: onSave,
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
}

// ─── Avatar header ────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({
    required this.title,
    required this.initials,
    required this.gradientColors,
  });

  final String title;
  final String initials;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextTheme.displaySmall.colored(Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Avatar with camera badge
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow ring
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              // Avatar circle
              Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTextTheme.displayMedium.colored(
                    gradientColors.first,
                  ),
                ),
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: gradientColors.first,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            'Tap the camera to change photo',
            style: AppTextTheme.labelSmall.colored(
              Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated form field ──────────────────────────────────────────────────────

class _AnimatedField extends StatefulWidget {
  const _AnimatedField({required this.field});
  final EditProfileField field;

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField> {
  late FocusNode _focus;
  bool _focused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()
      ..addListener(() {
        setState(() => _focused = _focus.hasFocus);
      });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isObscure = widget.field.obscure && _obscured;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextTheme.inputLabel.colored(
              _focused ? AppColors.primary : context.textSecondary,
            ),
            child: Text(widget.field.label),
          ),
          const SizedBox(height: 8),

          // Field container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _focused ? AppColors.primary : context.borderLight,
                width: _focused ? 1.8 : 1.0,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.field.icon,
                    size: 18,
                    color: _focused ? AppColors.primary : context.textTertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.field.controller,
                    focusNode: _focus,
                    keyboardType: widget.field.keyboardType,
                    obscureText: isObscure,
                    style: AppTextTheme.bodyMedium,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: widget.field.hint,
                      hintStyle: AppTextTheme.inputHint
                          .colored(context.textTertiary),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                if (widget.field.obscure) ...[
                  GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(
                        _obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                ] else
                  const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient save button ─────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_rounded,
                    size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextTheme.buttonLarge.colored(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
