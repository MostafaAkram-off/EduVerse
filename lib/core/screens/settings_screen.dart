import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final prefs = AppPreferences.instance;
        final l10n = AppLocalizations.of(context);
        final topPadding = MediaQuery.of(context).padding.top;

        return Scaffold(
          backgroundColor: context.bg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Gradient Header ────────────────────────────────────
                Container(
                  height: 140 + topPadding,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.gradient1Start, AppColors.gradient1End],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // Back button
                        Positioned(
                          left: 4,
                          top: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),
                        // Title + subtitle
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.settingsTitle,
                                style: AppTextTheme.displayMedium
                                    .colored(Colors.white)
                                    .copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.customizeExperience,
                                style: AppTextTheme.bodySmall.colored(
                                  Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Body ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // APPEARANCE SECTION
                      _SectionHeader(l10n.appearance),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          // Dark Mode
                          _ToggleTile(
                            icon: Icons.dark_mode_rounded,
                            gradientColors: const [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                            ],
                            title: l10n.darkMode,
                            subtitle: l10n.darkModeDesc,
                            value: prefs.darkMode,
                            onChanged: (v) => prefs.setDarkMode(v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ABOUT SECTION
                      _SectionHeader('About'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _InfoTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.primary,
                            title: 'App Version',
                            trailing: Text(
                              '1.0.0',
                              style: AppTextTheme.labelMedium.colored(
                                context.textTertiary,
                              ),
                            ),
                            onTap: null,
                            isLast: false,
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: context.divider,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _InfoTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: AppColors.success,
                            title: 'Privacy Policy',
                            isLast: false,
                            onTap: () {},
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: context.divider,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _InfoTile(
                            icon: Icons.description_outlined,
                            iconColor: AppColors.warning,
                            title: 'Terms of Service',
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Section Header ────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        title.toUpperCase(),
        style: AppTextTheme.sectionHeader.copyWith(
          color: context.textTertiary,
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Settings Card Container ────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

// ─── Toggle Tile ────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Gradient circle icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextTheme.cardTitle.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextTheme.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.50),
          ),
        ],
      ),
    );
  }
}

// ─── Info Tile ──────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isLast,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isLast;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextTheme.cardTitle.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
