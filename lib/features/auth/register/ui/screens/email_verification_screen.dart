import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/core/l10n/app_localizations.dart';
import 'package:edu_verse/core/theme/app_colors.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';
import 'package:edu_verse/core/widgets/primary_button.dart';
import 'package:edu_verse/core/navigation/app_routes.dart';
import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_cubit.dart';
import 'package:edu_verse/features/auth/register/ui/cubit/register_state.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  static const _digitCount = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<AnimationController> _bounceControllers;
  late final List<Animation<double>> _bounceAnimations;
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_digitCount, (_) => TextEditingController());
    _focusNodes = List.generate(_digitCount, (_) => FocusNode());
    _bounceControllers = List.generate(
      _digitCount,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 200)),
    );
    _bounceAnimations = _bounceControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _headerFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeIn));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    for (final c in _bounceControllers) { c.dispose(); }
    _headerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      _bounceControllers[index].forward(from: 0);
      if (index < _digitCount - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Map<String, dynamic>? _extras(BuildContext context) =>
      GoRouterState.of(context).extra as Map<String, dynamic>?;

  String _email(BuildContext context) => _extras(context)?['email'] as String? ?? '';

  RegisterRequest? _request(BuildContext context) =>
      _extras(context)?['request'] as RegisterRequest?;

  void _onVerify(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = _otp;
    if (code.length < _digitCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterSixDigit)),
      );
      return;
    }
    final request = _request(context);
    if (request == null) return;
    context.read<RegisterCubit>().verifyEmail(request: request, code: code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = _email(context);

    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        } else if (state is RegisterVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.emailVerifiedMsg),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AppRoutes.login);
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterVerifying;
        final isResending = state is RegisterResending;

        return Scaffold(
          backgroundColor: context.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ── Header ──
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                          ),
                          child: const Icon(Icons.email_outlined, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Text(l10n.verifyEmailTitle,
                            style: AppTextTheme.displayMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        Text(
                          '${l10n.verifyEmailSent}\n$email',
                          style: AppTextTheme.bodyMedium.copyWith(color: context.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── OTP boxes ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_digitCount, (index) {
                    return ScaleTransition(
                      scale: _bounceAnimations[index],
                      child: SizedBox(
                        width: 48,
                        height: 56,
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (e) => _onKeyEvent(index, e),
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: AppTextTheme.displaySmall.copyWith(
                              color: context.textPrimary,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: context.surface,
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.border, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                            onChanged: (v) => _onDigitChanged(index, v),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // ── Resend section ──
                if (isResending)
                  Text(l10n.resending,
                      style: AppTextTheme.bodySmall.copyWith(color: AppColors.primary))
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${l10n.didntReceive} ', style: AppTextTheme.bodySmall),
                      _secondsLeft > 0
                          ? Text(
                              l10n.resendIn(_secondsLeft),
                              style: AppTextTheme.bodySmall.copyWith(
                                  color: context.textSecondary),
                            )
                          : GestureDetector(
                              onTap: () {
                                context.read<RegisterCubit>().resendVerification(email);
                                _startTimer();
                              },
                              child: Text(l10n.resendCode, style: AppTextTheme.link),
                            ),
                    ],
                  ),

                const SizedBox(height: 32),

                PrimaryButton(
                  label: l10n.verifyEmailBtn,
                  onPressed: () => _onVerify(context),
                  isLoading: isLoading,
                  fullWidth: true,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
