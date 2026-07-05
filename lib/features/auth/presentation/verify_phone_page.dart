import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/app_routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'widgets/auth_header.dart';
import 'widgets/otp_input_row.dart';

class VerifyPhonePage extends StatefulWidget {
  final String phone;

  const VerifyPhonePage({super.key, required this.phone});

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  String _otpValue = '';
  int _resendCountdown = 29;
  Timer? _resendTimer;

  final GlobalKey<OtpInputRowState> _otpKey = GlobalKey<OtpInputRowState>();

  String _maskedPhone(String phone) {
    if (phone.length > 6) {
      return '${phone.substring(0, 6)}*** ***${phone.substring(phone.length - 2)}';
    }
    return phone;
  }

  void _startTimer(int seconds) {
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

  void _onResend() {
    context
        .read<AuthBloc>()
        .add(AuthOtpResendRequested(phone: widget.phone));
    _startTimer(29);
  }

  @override
  void initState() {
    super.initState();
    _startTimer(29);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Widget _buildHomeIndicator() {
    return Center(
      child: Container(
        width: 100,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1118).withOpacity(0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerified) {
          if (state.isNewUser) {
            context.push(AppRoutes.register);
          } else {
            context.go(AppRoutes.home);
          }
        } else if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError && state.isOtpError) {
          _otpKey.currentState?.clear();
          setState(() => _otpValue = '');
        } else if (state is AuthError &&
            !state.isOtpError &&
            !state.isPinError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isOtpError = state is AuthError && state.isOtpError;
        final canVerify = _otpValue.length >= 6;

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBFC),
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: const Color(0xFFFDFBFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1118), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthHeader(
                          iconWidget: const Icon(Icons.phone_android, size: 28, color: Color(0xFFE8507A)),
                          title: 'Verify your number',
                          subtitle:
                              'Enter the 6-digit code sent to ${_maskedPhone(widget.phone)}',
                          showBack: false,
                        ),

                        OtpInputRow(
                          key: _otpKey,
                          onCompleted: (otp) =>
                              setState(() => _otpValue = otp),
                          onResend: _onResend,
                          resendCountdown: _resendCountdown,
                          hasError: isOtpError,
                        ),

                        if (isOtpError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Center(
                              child: Text(
                                (state as AuthError).message,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFDC2626)),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Primary button
                        GestureDetector(
                          onTap: (canVerify && !isLoading)
                              ? () =>
                                  context.read<AuthBloc>().add(
                                        AuthOtpSubmitted(
                                          phone: widget.phone,
                                          otp: _otpValue,
                                        ),
                                      )
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 52,
                            decoration: BoxDecoration(
                              color: canVerify
                                  ? const Color(0xFFE8507A)
                                  : const Color(0xFFEDE0E5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2),
                                    )
                                  : Text(
                                      'Verify & Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: canVerify
                                            ? Colors.white
                                            : const Color(0xFF9E8A93),
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'For demo: Enter any 6-digit code',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9E8A93)),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                _buildHomeIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
