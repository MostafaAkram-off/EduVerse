import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
  static const _kPush              = 'settings_push';
  static const _kEmail             = 'settings_email';
  static const _kSessionReminders  = 'settings_session_reminders';
  static const _kGradeAlerts       = 'settings_grade_alerts';
  static const _kBiometric         = 'settings_biometric';
  static const _kAutoDownload      = 'settings_auto_download';

  bool _push             = true;
  bool _email            = true;
  bool _sessionReminders = true;
  bool _gradeAlerts      = true;
  bool _biometric        = true;
  bool _autoDownload     = false;
  bool _settingsLoaded   = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _push             = p.getBool(_kPush)             ?? true;
      _email            = p.getBool(_kEmail)            ?? true;
      _sessionReminders = p.getBool(_kSessionReminders) ?? true;
      _gradeAlerts      = p.getBool(_kGradeAlerts)      ?? true;
      _biometric        = p.getBool(_kBiometric)        ?? true;
      _autoDownload     = p.getBool(_kAutoDownload)     ?? false;
      _settingsLoaded   = true;
    });
  }

  Future<void> _save(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will clear all cached images and temporary data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    PaintingBinding.instance.imageCache.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
      body: _settingsLoaded
          ? _buildBody(context, l10n)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return ListView(
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
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Notifications',
          children: [
            _ToggleTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              subtitle: 'All app notifications',
              value: _push,
              onChanged: (v) {
                setState(() => _push = v);
                _save(_kPush, v);
              },
            ),
            _ToggleTile(
              icon: Icons.mail_outline_rounded,
              label: 'Email Alerts',
              subtitle: 'Important updates via email',
              value: _email,
              onChanged: (v) {
                setState(() => _email = v);
                _save(_kEmail, v);
              },
            ),
            _ToggleTile(
              icon: Icons.event_note_rounded,
              label: 'Session Reminders',
              subtitle: '30 min before sessions',
              value: _sessionReminders,
              onChanged: (v) {
                setState(() => _sessionReminders = v);
                _save(_kSessionReminders, v);
              },
              accent: AppColors.success,
            ),
            _ToggleTile(
              icon: Icons.grade_outlined,
              label: 'Grade Alerts',
              subtitle: 'When assignments are graded',
              value: _gradeAlerts,
              onChanged: (v) {
                setState(() => _gradeAlerts = v);
                _save(_kGradeAlerts, v);
              },
              accent: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Security',
          children: [
            _ToggleTile(
              icon: Icons.fingerprint_rounded,
              label: 'Biometric Login',
              subtitle: 'Face ID / Fingerprint',
              value: _biometric,
              onChanged: (v) {
                setState(() => _biometric = v);
                _save(_kBiometric, v);
              },
              accent: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Storage & Data',
          children: [
            _ToggleTile(
              icon: Icons.download_outlined,
              label: 'Auto-Download Materials',
              subtitle: 'Download session files on Wi-Fi',
              value: _autoDownload,
              onChanged: (v) {
                setState(() => _autoDownload = v);
                _save(_kAutoDownload, v);
              },
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
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABOUT',
                    style: AppTextTheme.badgeSm.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _AboutRow('App Version', '1.0.0 (Build 1)'),
                  const _AboutRow('Last Updated', 'Jun 2026'),
                  _AboutRow(
                    'Privacy Policy',
                    'View',
                    isLink: true,
                    onTap: () => _openUrl('https://eduverse.app/privacy'),
                  ),
                  _AboutRow(
                    'Terms of Service',
                    'View',
                    isLink: true,
                    onTap: () => _openUrl('https://eduverse.app/terms'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _clearCache,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Clear Cache & Data',
            style: AppTextTheme.bodySemibold.copyWith(color: AppColors.error),
          ),
        ),
        const SizedBox(height: 100),
      ],
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
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
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
          Switch.adaptive(value: value, onChanged: onChanged),
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
            Text(k, style: Theme.of(context).textTheme.bodySmall),
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
