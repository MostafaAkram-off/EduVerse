import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.gradientColors = const [AppColors.gradient1Start, AppColors.gradient1End],
  });

  final List<Color> gradientColors;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;

  // Pending photo (picked but not yet saved)
  Uint8List? _pendingBytes;
  String? _pendingFilename;
  bool _removePhoto = false;

  @override
  void initState() {
    super.initState();
    final p = AppPreferences.instance;
    _nameCtrl  = TextEditingController(text: p.userName);
    _emailCtrl = TextEditingController(text: p.userEmail);
    _phoneCtrl = TextEditingController(text: p.userPhone);
    AppPreferences.instance.addListener(_onPrefsChanged);
  }

  void _onPrefsChanged() => setState(() {});

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_onPrefsChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    setState(() {
      _pendingBytes = file.bytes;
      _pendingFilename = file.name;
      _removePhoto = false;
    });
  }

  void _clearPhoto() {
    setState(() {
      _pendingBytes = null;
      _pendingFilename = null;
      _removePhoto = true;
    });
  }

  static String? _extractFilename(dynamic data) {
    String? raw;
    if (data is Map) {
      raw = (data['profilePicture']
              ?? data['ProfilePicture']
              ?? data['profilePictureUrl']
              ?? data['ProfilePictureUrl']
              ?? data['imageUrl']
              ?? data['ImageUrl'])
          ?.toString();
      if ((raw == null || raw.isEmpty) && data['data'] is Map) {
        final d = data['data'] as Map<dynamic, dynamic>;
        raw = (d['profilePicture'] ?? d['ProfilePicture']
            ?? d['profilePictureUrl'] ?? d['ProfilePictureUrl'])?.toString();
      }
      if ((raw == null || raw.isEmpty) && data['user'] is Map) {
        final user = data['user'] as Map<dynamic, dynamic>;
        raw = (user['profilePicture'] ?? user['ProfilePicture'])?.toString();
      }
    } else if (data is String && data.isNotEmpty) {
      raw = data.replaceAll('"', '');
    }
    if (raw == null || raw.isEmpty) return null;
    // Handle full URL or path like /Cloud/Get/ProfilePicture/abc.jpg
    return raw.contains('/') ? raw.split('/').last : raw;
  }

  static String _mimeSubtype(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'jpeg',
      'png'           => 'png',
      'gif'           => 'gif',
      'webp'          => 'webp',
      _               => 'jpeg',
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final Dio dio = GetIt.instance<Dio>();

      final Map<String, dynamic> fields = {
        'FullName': _nameCtrl.text.trim(),
        'PhoneNumber': _phoneCtrl.text.trim(),
      };

      if (_pendingBytes != null && _pendingFilename != null) {
        fields['ProfilePicture'] = MultipartFile.fromBytes(
          _pendingBytes!,
          filename: _pendingFilename,
          contentType: DioMediaType('image', _mimeSubtype(_pendingFilename!)),
        );
      }

      // 1. Send the update
      await dio.put<dynamic>(
        ApiEndpoints.updateProfile,
        data: FormData.fromMap(fields),
        options: Options(headers: {'Accept': '*/*'}),
      );

      // 2. Evict old cached image immediately
      final oldFilename = AppPreferences.instance.profilePictureFilename;
      if (oldFilename.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.getProfilePicture(oldFilename)}',
        );
      }

      // 3. Fetch updated profile — more reliable than parsing the PUT response
      String? newFilename;
      try {
        final profileRes = await dio.get<dynamic>(ApiEndpoints.getProfile);
        newFilename = _extractFilename(profileRes.data);
      } catch (_) {}

      // 4. Persist picture filename (or clear it)
      if (_removePhoto) {
        await AppPreferences.instance.clearProfilePicture();
      } else if (newFilename != null && newFilename.isNotEmpty) {
        // Evict the new URL too so CachedNetworkImage fetches fresh from server
        await CachedNetworkImage.evictFromCache(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.getProfilePicture(newFilename)}',
        );
        await AppPreferences.instance.saveProfilePicture(newFilename);
      }

      // 5. Save name / phone
      await AppPreferences.instance.saveProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdated),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final String msg;
      if (e is DioException) {
        final status = e.response?.statusCode;
        final body = e.response?.data?.toString() ?? '';
        if (body.contains('web app is stopped') ||
            body.contains('Site Disabled')) {
          msg = 'Server is currently unavailable. Please try again later.';
        } else if (status == 403) {
          msg = 'You don\'t have permission to update your profile.';
        } else if (status == 401) {
          msg = 'Session expired. Please log in again.';
        } else {
          msg = 'Update failed (${status ?? 'no connection'}). Try again.';
        }
      } else {
        msg = 'Update failed. Check your connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferences.instance;
    final savedFilename = prefs.profilePictureFilename;
    final hasRemotePhoto = savedFilename.isNotEmpty && !_removePhoto;
    final hasPendingPhoto = _pendingBytes != null;
    final photoUrl = hasRemotePhoto
        ? '${ApiEndpoints.baseUrl}${ApiEndpoints.getProfilePicture(savedFilename)}'
        : null;
    final initials = prefs.initials();
    final grad = widget.gradientColors;

    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                        ),
                        Expanded(
                          child: Text(
                            'Edit Profile',
                            style: AppTextTheme.displaySmall
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Glow ring
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        // Photo
                        Positioned(
                          left: 7,
                          top: 7,
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: hasPendingPhoto
                                  ? Image.memory(
                                      _pendingBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : photoUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: photoUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: grad.first),
                                          ),
                                          errorWidget: (_, __, ___) => Center(
                                            child: Text(initials,
                                                style: AppTextTheme
                                                    .displayMedium
                                                    .copyWith(
                                                        color: grad.first)),
                                          ),
                                        )
                                      : Center(
                                          child: Text(initials,
                                              style: AppTextTheme.displayMedium
                                                  .copyWith(
                                                      color: grad.first)),
                                        ),
                            ),
                          ),
                        ),
                        // Camera badge
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickPhoto,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.camera_alt_rounded,
                                  size: 16, color: grad.first),
                            ),
                          ),
                        ),
                        // Remove badge
                        if (hasPendingPhoto || hasRemotePhoto)
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _clearPhoto,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasPendingPhoto
                          ? 'Photo selected — tap Save Changes to apply'
                          : (hasRemotePhoto
                              ? 'Tap camera to change photo'
                              : 'Tap camera to add photo'),
                      style: AppTextTheme.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────────
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Personal Information',
                      style: AppTextTheme.sectionHeader),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    icon: Icons.person_outline_rounded,
                    action: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().length < 2) {
                        return 'Enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Email',
                    controller: _emailCtrl,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    readOnly: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter email';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Phone',
                    controller: _phoneCtrl,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    action: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.trim().length < 8) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _saving ? null : _save,
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: grad),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: grad.first.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          height: 54,
                          alignment: Alignment.center,
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_rounded,
                                        size: 18, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('Save Changes',
                                        style: AppTextTheme.buttonLarge
                                            .copyWith(color: Colors.white)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable animated field ──────────────────────────────────────────────────
class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.action = TextInputAction.next,
    this.validator,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction action;
  final FormFieldValidator<String>? validator;
  final bool readOnly;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()
      ..addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.readOnly ? context.borderLight : (_focused ? AppColors.primary : context.borderLight);
    final borderWidth = _focused && !widget.readOnly ? 1.8 : 1.0;
    final iconColor = _focused && !widget.readOnly
        ? AppColors.primary
        : context.textTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: AppTextTheme.inputLabel.copyWith(
            color: (_focused && !widget.readOnly)
                ? AppColors.primary
                : context.textSecondary,
            fontWeight: (_focused && !widget.readOnly)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: (_focused && !widget.readOnly)
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.action,
            style: AppTextTheme.bodyMedium,
            validator: widget.validator,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.readOnly
                  ? context.surface.withValues(alpha: 0.5)
                  : context.surface,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(widget.icon, size: 20, color: iconColor),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 48, minHeight: 0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: borderColor, width: borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.8),
              ),
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),
      ],
    );
  }
}
