import 'package:flutter/material.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _email = true;
  bool _sessionReminders = true;
  bool _gradeAlerts = true;
  bool _biometric = true;
  bool _autoDownload = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListenableBuilder(
            listenable: AppPreferences.instance,
            builder: (context, _) {
              final p = AppPreferences.instance;
              return _Section(
                title: l10n.appearance,
                children: [
                  _ToggleTile(
                    icon: Icons.dark_mode_outlined,
                    label: l10n.darkMode,
                    subtitle: l10n.darkModeDesc,
                    value: p.darkMode,
                    onChanged: (v) => p.setDarkMode(v),
                    accent: AppColors.secondary,
                  ),
                  _ToggleTile(
                    icon: Icons.translate_rounded,
                    label: l10n.arabicLanguage,
                    subtitle: l10n.arabicDesc,
                    value: p.localeCode == 'ar',
                    onChanged: (v) => p.setArabicEnabled(v),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _Section(
            title: l10n.isRtl ? 'الإشعارات' : 'Notifications',
            children: [
              _ToggleTile(
                icon: Icons.notifications_outlined,
                label: l10n.isRtl ? 'إشعارات الدفع' : 'Push Notifications',
                subtitle: l10n.isRtl ? 'كل إشعارات التطبيق' : 'All app notifications',
                value: _push,
                onChanged: (v) => setState(() => _push = v),
              ),
              _ToggleTile(
                icon: Icons.mail_outline_rounded,
                label: l10n.isRtl ? 'تنبيهات البريد' : 'Email Alerts',
                subtitle: l10n.isRtl ? 'تحديثات عبر البريد' : 'Important updates via email',
                value: _email,
                onChanged: (v) => setState(() => _email = v),
              ),
              _ToggleTile(
                icon: Icons.event_note_rounded,
                label: l10n.isRtl ? 'تذكير الجلسات' : 'Session Reminders',
                subtitle: l10n.isRtl ? 'قبل 30 دقيقة' : '30 min before sessions',
                value: _sessionReminders,
                onChanged: (v) => setState(() => _sessionReminders = v),
                accent: AppColors.success,
              ),
              _ToggleTile(
                icon: Icons.grade_outlined,
                label: l10n.isRtl ? 'تنبيهات الدرجات' : 'Grade Alerts',
                subtitle: l10n.isRtl ? 'عند تصحيح الواجبات' : 'When assignments are graded',
                value: _gradeAlerts,
                onChanged: (v) => setState(() => _gradeAlerts = v),
                accent: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: l10n.isRtl ? 'الأمان' : 'Security',
            children: [
              _ToggleTile(
                icon: Icons.fingerprint_rounded,
                label: l10n.isRtl ? 'دخول بيومتري' : 'Biometric Login',
                subtitle: l10n.isRtl ? 'Face ID / بصمة' : 'Face ID / Fingerprint',
                value: _biometric,
                onChanged: (v) => setState(() => _biometric = v),
                accent: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: l10n.isRtl ? 'التخزين والبيانات' : 'Storage & Data',
            children: [
              _ToggleTile(
                icon: Icons.download_outlined,
                label: l10n.isRtl ? 'تنزيل تلقائي' : 'Auto-Download Materials',
                subtitle: l10n.isRtl ? 'على الـ Wi‑Fi' : 'Download session files on Wi‑Fi',
                value: _autoDownload,
                onChanged: (v) => setState(() => _autoDownload = v),
                accent: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isRtl ? 'حول' : 'ABOUT',
                      style: AppTextTheme.badgeSm.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AboutRow(
                      l10n.isRtl ? 'إصدار التطبيق' : 'App Version',
                      '1.0.0 (Build 1)',
                    ),
                    _AboutRow(
                      l10n.isRtl ? 'آخر تحديث' : 'Last Updated',
                      'Apr 2026',
                    ),
                    _AboutRow(
                      l10n.isRtl ? 'سياسة الخصوصية' : 'Privacy Policy',
                      l10n.isRtl ? 'عرض' : 'View',
                      isLink: true,
                      onTap: () {},
                    ),
                    _AboutRow(
                      l10n.isRtl ? 'شروط الاستخدام' : 'Terms of Service',
                      l10n.isRtl ? 'عرض' : 'View',
                      isLink: true,
                      onTap: () {},
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.isRtl ? 'مسح الذاكرة المؤقتة' : 'Clear Cache & Data',
              style: AppTextTheme.bodySemibold.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextTheme.badgeSm.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  const _ToggleTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: tt.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String k;
  final String v;
  final bool isLink;
  final VoidCallback? onTap;

  const _AboutRow(this.k, this.v, {this.isLink = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              k,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              v,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLink ? cs.primary : cs.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
