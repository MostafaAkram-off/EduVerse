import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/primary_button.dart';
import 'package:edu_verse/core/widgets/app_text_field.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/auth/login/ui/cubit/login_cubit.dart';
import 'package:edu_verse/features/auth/login/ui/cubit/login_state.dart';
import 'package:edu_verse/features/auth/shared/user_role.dart';

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5, size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 40,
      size.width, size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final List<AnimationController> _fieldControllers;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  static const _fieldCount = 5;

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
      Future.delayed(Duration(milliseconds: 150 + i * 100), () {
        if (mounted) _fieldControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    for (final c in _fieldControllers) { c.dispose(); }
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Widget _animated(int index, Widget child) => SlideTransition(
    position: _slideAnimations[index],
    child: FadeTransition(opacity: _fadeAnimations[index], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        } else if (state is LoginSuccess) {
          if (state.role == UserRole.instructor) {
            context.go(AppRoutes.instructorHome);
          } else {
            context.go(AppRoutes.studentHome);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return Scaffold(
          backgroundColor: context.bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient header ──
                ClipPath(
                  clipper: _WaveClipper(),
                  child: Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('assets/images/EduVerse_logo.png', width: 90),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Form card ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          _animated(0, AppTextField(
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

                          // Password
                          _animated(1, AppTextField(
                            label: l10n.passwordLabel,
                            hint: l10n.passwordHint,
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outlined,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.fieldRequired;
                              return null;
                            },
                          )),
                          const SizedBox(height: 8),

                          // Forgot password
                          _animated(2, Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.comingSoon),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.forgotPassword,
                                style: AppTextTheme.buttonSmall.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          )),
                          const SizedBox(height: 8),

                          // Sign In button
                          _animated(3, PrimaryButton(
                            label: l10n.signIn,
                            onPressed: _onLogin,
                            isLoading: isLoading,
                            fullWidth: true,
                          )),
                          const SizedBox(height: 24),

                          // Divider + social + sign up
                          _animated(4, Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(l10n.orContinueWith, style: AppTextTheme.labelMedium),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _SocialButton(
                                    label: 'Google',
                                    icon: Icons.g_mobiledata_rounded,
                                    onPressed: () {},
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(child: _SocialButton(
                                    label: 'Apple',
                                    icon: Icons.apple,
                                    onPressed: () {},
                                  )),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: () => context.push(AppRoutes.register),
                                  child: RichText(
                                    text: TextSpan(
                                      text: '${l10n.noAccount} ',
                                      style: AppTextTheme.bodyMedium.copyWith(
                                        color: context.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(text: l10n.signUp, style: AppTextTheme.link),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: context.textPrimary),
      label: Text(label, style: AppTextTheme.buttonSmall.copyWith(color: context.textPrimary)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: context.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
