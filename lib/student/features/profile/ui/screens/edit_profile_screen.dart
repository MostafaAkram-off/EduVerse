import 'package:flutter/material.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final p = AppPreferences.instance;
    _nameCtrl = TextEditingController(text: p.userName);
    _emailCtrl = TextEditingController(text: p.userEmail);
    _phoneCtrl = TextEditingController(text: p.userPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await AppPreferences.instance.saveProfile(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileUpdated)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    AppPreferences.instance.initials(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Material(
                    color: cs.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.isRtl
                                  ? 'رفع الصورة قريباً'
                                  : 'Photo upload coming soon',
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.camera_alt_rounded,
                            size: 18, color: cs.onPrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return l10n.isRtl
                          ? 'أدخل الاسم الكامل'
                          : 'Enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.isRtl ? 'أدخل البريد' : 'Enter email';
                    }
                    if (!v.contains('@')) {
                      return l10n.isRtl
                          ? 'بريد غير صالح'
                          : 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 8) {
                      return l10n.isRtl
                          ? 'أدخل رقماً صالحاً'
                          : 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _save,
                  child: Text(l10n.saveChanges),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
