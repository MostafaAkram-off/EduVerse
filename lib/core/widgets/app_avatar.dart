import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 22,
  });

  final String? imageUrl;
  final String? name;
  final double radius;

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          httpHeaders: AuthSession.token != null
              ? {'Authorization': 'Bearer ${AuthSession.token}'}
              : const {},
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => _fallback(),
          errorWidget: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.gradient1Start, AppColors.gradient1End],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            _initials,
            style: AppTextTheme.labelLarge.colored(AppColors.textOnPrimary).copyWith(
              fontSize: (radius * 0.55).clamp(10, 22),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
