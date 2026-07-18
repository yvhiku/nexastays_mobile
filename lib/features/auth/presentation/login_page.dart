import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/utils/phone_normalizer.dart';
import '../../../navigation/app_routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'widgets/auth_header.dart';
import 'widgets/otp_input_row.dart';
import 'widgets/pin_input.dart';

/// Phone-login palette — blush surfaces with saturated brand pink for actions.
abstract final class _AuthColors {
  static const primary = Color(0xFFE8507A);
  static const primaryDark = Color(0xFFC93A62);
  static const surface = Color(0xFFFFF8F8);
  static const surfaceContainer = Color(0xFFFDF1F2);
  static const ink = Color(0xFF0F172A);
  static const inkMuted = Color(0xFF64748B);
  static const inkLabel = Color(0xFF475569);
  static const borderSubtle = Color(0xFFCBD5E1);
  static const homeIndicator = Color(0xFFE2E8F0);
  static const error = Color(0xFFDC2626);

  // OTP verify screen
  static const primaryBerry = Color(0xFF864E5E);
  static const onSurface = Color(0xFF201A1B);
  static const onSurfaceVariant = Color(0xFF514346);
  static const outline = Color(0xFF837376);
}

enum _LoginStep { phoneEntry, otpVerify, pinLogin }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginStep _step = _LoginStep.phoneEntry;
  String _phoneInput = '';
  String _selectedCountryCode = 'MA';
  String _selectedPhoneCode = '212';
  String _phone = '';
  bool _agreedToTerms = false;
  bool _termsError = false;
  String _otpValue = '';
  String _pinValue = '';
  int _resendCountdown = 0;
  Timer? _resendTimer;

  final GlobalKey<OtpInputRowState> _otpKey = GlobalKey<OtpInputRowState>();

  String get _maskedPhone {
    if (_phone.length > 6) {
      return '${_phone.substring(0, 6)}*** ***${_phone.substring(_phone.length - 2)}';
    }
    return _phone;
  }

  String get _displayPhone {
    final digits = _phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+212') && digits.length >= 12) {
      final local = digits.substring(4);
      return '+212 ${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
    }
    if (digits.startsWith('+') && digits.length > 4) {
      return digits.replaceAllMapped(
        RegExp(r'^(\+\d{1,3})(\d+)'),
        (m) => '${m[1]} ${m[2]!.replaceAllMapped(RegExp(r'.{1,3}'), (g) => '${g[0]} ').trim()}',
      );
    }
    return _maskedPhone;
  }

  String _normalizePhoneForApi(String raw) {
    var value = raw.replaceAll(RegExp(r'\s+'), '');
    if (value.startsWith('+')) {
      value = '+${value.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    } else {
      value = value.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (!value.startsWith('+')) {
      value = '+$_selectedPhoneCode$value';
    }

    return normalizePhone(value);
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _onPhoneNext() {
    if (!_agreedToTerms) {
      setState(() => _termsError = true);
      return;
    }
    setState(() => _termsError = false);
    final normalized = _normalizePhoneForApi(_phone);
    setState(() => _phone = normalized);
    context.read<AuthBloc>().add(
          AuthPhoneSubmitted(phone: normalized, agreedToTerms: true),
        );
  }

  void _onResend() {
    final normalized = _normalizePhoneForApi(_phone);
    setState(() => _phone = normalized);
    context.read<AuthBloc>().add(AuthOtpResendRequested(phone: normalized));
    _startResendTimer(45);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Widget _buildHomeIndicator() {
    return Center(
      child: Container(
        width: 128,
        height: 6,
        margin: const EdgeInsets.only(bottom: 24, top: 8),
        decoration: BoxDecoration(
          color: _AuthColors.homeIndicator,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(AuthState state) {
    final isLoading = state is AuthLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(
                  iconWidget: Icon(
                    Icons.phone_android_outlined,
                    size: 32,
                    color: _AuthColors.primary,
                  ),
                  title: 'Enter Your Phone Number',
                  subtitle: "We'll send you a verification code",
                  showBack: false,
                ),

                Text(
                  'Phone Number',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _AuthColors.inkLabel,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              hintText: 'Start typing to search',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _AuthColors.borderSubtle.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountryCode = country.countryCode;
                              _selectedPhoneCode = country.phoneCode;
                              _phone = '+$_selectedPhoneCode$_phoneInput';
                            });
                          },
                        );
                      },
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _AuthColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_selectedCountryCode +$_selectedPhoneCode',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _AuthColors.ink,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: _AuthColors.inkMuted.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: _PhoneTextField(
                          onChanged: (val) {
                            setState(() {
                              _phoneInput = val;
                              _phone = '+$_selectedPhoneCode$_phoneInput';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: _AuthColors.primary,
                        checkColor: Colors.white,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: _termsError
                              ? _AuthColors.error
                              : _AuthColors.borderSubtle,
                          width: 1.5,
                        ),
                        onChanged: (v) => setState(() {
                          _agreedToTerms = v ?? false;
                          if (_agreedToTerms) _termsError = false;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: _AuthColors.inkMuted,
                              height: 1.35,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Terms of service',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _AuthColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Privacy Policy',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _AuthColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_termsError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'Please agree to the Terms of Service',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _AuthColors.error,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                _NexaAuthButton(
                  label: 'Next',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _onPhoneNext,
                ),
              ],
            ),
          ),
        ),
        _buildHomeIndicator(),
      ],
    );
  }

  Widget _buildOtpStep(AuthState state) {
    final isLoading = state is AuthLoading;
    final isOtpError = state is AuthError && state.isOtpError;
    final canVerify = _otpValue.length >= 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Verify your number',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: _AuthColors.onSurface,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: _AuthColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "We've sent a 6-digit code to "),
                      TextSpan(
                        text: '$_displayPhone.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: _AuthColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                OtpInputRow(
                  key: _otpKey,
                  onCompleted: (otp) => setState(() => _otpValue = otp),
                  onResend: _onResend,
                  resendCountdown: _resendCountdown,
                  hasError: isOtpError,
                ),
                if (isOtpError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      (state as AuthError).message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _AuthColors.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                _OtpVerifyButton(
                  isLoading: isLoading,
                  enabled: canVerify,
                  onPressed: canVerify && !isLoading
                      ? () => context.read<AuthBloc>().add(
                            AuthOtpSubmitted(
                              phone: _normalizePhoneForApi(_phone),
                              otp: _otpValue,
                            ),
                          )
                      : null,
                ),
                const SizedBox(height: 40),
                const _OtpSecurityPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinStep(AuthState state) {
    final isPinError = state is AuthError && state.isPinError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: GestureDetector(
            onTap: () => setState(() => _step = _LoginStep.phoneEntry),
            child: const Text('←',
                style: TextStyle(fontSize: 16, color: Color(0xFF1A1118))),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthHeader(
                  iconWidget: Icon(Icons.lock_outline,
                      size: 28, color: Color(0xFFE8507A)),
                  title: 'Welcome back',
                  subtitle: 'Enter your PIN to sign in',
                  showBack: false,
                ),
                PinBoxRow(
                  filledCount: _pinValue.length,
                  hasError: isPinError,
                ),
                if (isPinError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text((state as AuthError).message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFFDC2626))),
                  ),
                const SizedBox(height: 24),
                NumericKeypad(
                  onDigit: (d) {
                    if (_pinValue.length < 4) {
                      setState(() => _pinValue += d);
                      if (_pinValue.length == 4) {
                        context.read<AuthBloc>().add(
                              AuthPinLoginRequested(
                                  phone: _normalizePhoneForApi(_phone),
                                  pin: _pinValue),
                            );
                      }
                    }
                  },
                  onBackspace: () {
                    if (_pinValue.isNotEmpty) {
                      setState(() => _pinValue =
                          _pinValue.substring(0, _pinValue.length - 1));
                    }
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() {
                    _step = _LoginStep.phoneEntry;
                    _pinValue = '';
                  }),
                  child: const Text('Forgot PIN? Use OTP →',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8507A))),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        _buildHomeIndicator(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          setState(() {
            _step = _LoginStep.otpVerify;
            _otpValue = '';
          });
          _startResendTimer(45);
        } else if (state is AuthOtpVerified) {
          if (state.isNewUser) {
            context.push(AppRoutes.register);
          } else {
            context.go(AppRoutes.home);
          }
        } else if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthPinRequired) {
          setState(() {
            _step = _LoginStep.pinLogin;
            _phone = state.phone;
            _pinValue = '';
          });
        } else if (state is AuthError &&
            !state.isOtpError &&
            !state.isPinError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        } else if (state is AuthError && state.isOtpError) {
          // Clear OTP input on error
          _otpKey.currentState?.clear();
          setState(() => _otpValue = '');
        } else if (state is AuthError && state.isPinError) {
          setState(() => _pinValue = '');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _AuthColors.surface,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: _AuthColors.surface.withValues(alpha: 0.92),
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 56,
            centerTitle: _step == _LoginStep.otpVerify,
            title: _step == _LoginStep.otpVerify
                ? Text(
                    'Nexa Stays',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _AuthColors.primary,
                    ),
                  )
                : null,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _step == _LoginStep.otpVerify
                      ? _AuthColors.primary
                      : _AuthColors.ink,
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  shape: const CircleBorder(),
                ),
                onPressed: () {
                  if (_step == _LoginStep.phoneEntry) {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.onboarding);
                    }
                  } else {
                    setState(() => _step = _LoginStep.phoneEntry);
                  }
                },
              ),
            ),
          ),
          body: SafeArea(
            child: switch (_step) {
              _LoginStep.phoneEntry => _buildPhoneStep(state),
              _LoginStep.otpVerify => _buildOtpStep(state),
              _LoginStep.pinLogin => _buildPinStep(state),
            },
          ),
        );
      },
    );
  }
}

// ─── Phone field with mock-matching focus ring ───────────────────────────────

class _PhoneTextField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _PhoneTextField({required this.onChanged});

  @override
  State<_PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<_PhoneTextField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: _AuthColors.primary.withValues(alpha: 0.2),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextField(
        focusNode: _focusNode,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: widget.onChanged,
        style: GoogleFonts.inter(
          fontSize: 18,
          color: _AuthColors.ink,
        ),
        decoration: InputDecoration(
          hintText: '612 345 678',
          hintStyle: GoogleFonts.inter(
            fontSize: 18,
            color: _AuthColors.inkMuted.withValues(alpha: 0.65),
          ),
          filled: true,
          fillColor: _AuthColors.surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _AuthColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── Primary CTA — soft pink, shadow, press scale ────────────────────────────

class _NexaAuthButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _NexaAuthButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_NexaAuthButton> createState() => _NexaAuthButtonState();
}

class _NexaAuthButtonState extends State<_NexaAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.92 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: enabled
                  ? _AuthColors.primary
                  : _AuthColors.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: _AuthColors.primary.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── OTP verify CTA — pill, primary-container ────────────────────────────────

class _OtpVerifyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const _OtpVerifyButton({
    required this.onPressed,
    required this.isLoading,
    required this.enabled,
  });

  @override
  State<_OtpVerifyButton> createState() => _OtpVerifyButtonState();
}

class _OtpVerifyButtonState extends State<_OtpVerifyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onPressed != null && !widget.isLoading;
    return GestureDetector(
      onTapDown: active ? (_) => setState(() => _pressed = true) : null,
      onTapUp: active ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: active ? () => setState(() => _pressed = false) : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: active
                ? _AuthColors.primary
                : _AuthColors.primary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _AuthColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'VERIFY & LOGIN',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Decorative security panel (quiet luxury) ────────────────────────────────

class _OtpSecurityPanel extends StatelessWidget {
  const _OtpSecurityPanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          Positioned(
            top: -40,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _AuthColors.primary.withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFCD6DE).withValues(alpha: 0.35),
              ),
            ),
          ),
          SizedBox(
            height: 160,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: _AuthColors.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secure, end-to-end encrypted verification powered by Nexa Safeguard.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: _AuthColors.outline,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
