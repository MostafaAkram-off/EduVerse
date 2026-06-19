import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/primary_button.dart';
import 'package:edu_verse/core/widgets/app_text_field.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_cubit.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_state.dart';
import 'package:edu_verse/features/auth/shared/user_role.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  DateTime? _selectedBirth;
  RegisterRequest? _pendingRequest;

  late final List<AnimationController> _fieldControllers;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  static const _fieldCount = 8;

  @override
  void initState() {
    super.initState();
    _fieldControllers = List.generate(
      _fieldCount,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 450)),
    );
    _slideAnimations = _fieldControllers
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
    _fadeAnimations = _fieldControllers
        .map((c) => Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeIn)))
        .toList();
    for (int i = 0; i < _fieldCount; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 100), () {
        if (mounted) _fieldControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _fieldControllers) { c.dispose(); }
    super.dispose();
  }

  Widget _animated(int index, Widget child) => SlideTransition(
    position: _slideAnimations[index],
    child: FadeTransition(opacity: _fadeAnimations[index], child: child),
  );

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _selectedBirth = picked);
  }

  void _onRegister() {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectBirthDate)),
      );
      return;
    }
    final request = RegisterRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      birth: DateFormat('yyyy-MM-dd').format(_selectedBirth!),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      role: _selectedRole,
    );
    _pendingRequest = request;
    context.read<RegisterCubit>().register(request);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        } else if (state is RegisterSuccess) {
          context.push(AppRoutes.verifyEmail, extra: {
            'email': state.email,
            'request': _pendingRequest,
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

        return Scaffold(
          backgroundColor: context.bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient header ──
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.createAccount,
                          style: AppTextTheme.displayMedium.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.joinLearners,
                          style: AppTextTheme.bodyMedium.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Form ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full name
                        _animated(0, AppTextField(
                          label: l10n.fullName,
                          hint: l10n.fullNameHint,
                          controller: _nameController,
                          prefixIcon: Icons.person_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                            return null;
                          },
                        )),
                        const SizedBox(height: 16),

                        // Email
                        _animated(1, AppTextField(
                          label: l10n.emailLabel,
                          hint: l10n.emailHint,
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                            if (!v.contains('@')) return l10n.validEmail;
                            return null;
                          },
                        )),
                        const SizedBox(height: 16),

                        // Phone (optional)
                        _animated(2, AppTextField(
                          label: l10n.phoneOptional,
                          hint: l10n.phoneHint,
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        )),
                        const SizedBox(height: 16),

                        // Date of birth
                        _animated(3, GestureDetector(
                          onTap: _pickBirthDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: context.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.border, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    color: context.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedBirth == null
                                      ? l10n.dateOfBirth
                                      : DateFormat('MMM d, yyyy').format(_selectedBirth!),
                                  style: AppTextTheme.bodyMedium.copyWith(
                                    color: _selectedBirth == null
                                        ? context.textSecondary
                                        : context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 20),

                        // Role selection
                        _animated(4, Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.iAmA, style: AppTextTheme.inputLabel),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _RoleCard(
                                  icon: Icons.school,
                                  title: l10n.studentRole,
                                  description: l10n.studentRoleDesc,
                                  isSelected: _selectedRole == UserRole.student,
                                  onTap: () => setState(() => _selectedRole = UserRole.student),
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: _RoleCard(
                                  icon: Icons.person_pin,
                                  title: l10n.instructorRole,
                                  description: l10n.instructorRoleDesc,
                                  isSelected: _selectedRole == UserRole.instructor,
                                  onTap: () => setState(() => _selectedRole = UserRole.instructor),
                                )),
                              ],
                            ),
                          ],
                        )),
                        const SizedBox(height: 16),

                        // Password
                        _animated(5, AppTextField(
                          label: l10n.passwordLabel,
                          hint: l10n.createPasswordHint,
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outlined,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.isEmpty) return l10n.fieldRequired;
                            if (v.length < 6) return l10n.passwordMinLength;
                            if (!v.contains(RegExp(r'[A-Z]'))) return 'Must contain an uppercase letter';
                            if (!v.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
                            if (!v.contains(RegExp(r'[^A-Za-z0-9]'))) return 'Must contain a special character (!@#\$...)';
                            return null;
                          },
                        )),
                        const SizedBox(height: 16),

                        // Confirm password
                        _animated(6, AppTextField(
                          label: l10n.confirmPassword,
                          hint: l10n.confirmPasswordHint,
                          controller: _confirmPasswordController,
                          prefixIcon: Icons.lock_outlined,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.isEmpty) return l10n.fieldRequired;
                            if (v != _passwordController.text) return l10n.passwordsNoMatch;
                            return null;
                          },
                        )),
                        const SizedBox(height: 16),

                        // Terms + button
                        _animated(7, Column(
                          children: [
                            Text(
                              l10n.termsText,
                              style: AppTextTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: l10n.createAccount,
                              onPressed: _onRegister,
                              isLoading: isLoading,
                              fullWidth: true,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: RichText(
                                  text: TextSpan(
                                    text: '${l10n.alreadyHaveAccount} ',
                                    style: AppTextTheme.bodyMedium.copyWith(
                                      color: context.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(text: l10n.signIn, style: AppTextTheme.link),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : context.textSecondary,
                size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextTheme.cardTitle.copyWith(
                color: isSelected ? AppColors.primary : context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(description, style: AppTextTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
