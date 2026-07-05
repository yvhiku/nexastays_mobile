import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/app_routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'widgets/pin_input.dart';

enum _PinStep { create, confirm }

class CreatePinPage extends StatefulWidget {
  final String userId;

  const CreatePinPage({super.key, required this.userId});

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  _PinStep _step = _PinStep.create;
  String _pin = '';
  String _confirmPin = '';
  bool _mismatch = false;
  bool _errorShake = false;
  String? _pinError;

  void _onDigit(String d) {
    if (_step == _PinStep.create) {
      if (_pin.length < 4) {
        setState(() => _pin += d);
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin += d);
        if (_confirmPin.length == 4) _onConfirmComplete();
      }
    }
  }

  void _onBackspace() {
    if (_step == _PinStep.create) {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          _mismatch = false;
        });
      }
    }
  }

  void _onPrimaryTap() {
    if (_step == _PinStep.create) {
      if (_pin.length < 4) return;
      setState(() {
        _step = _PinStep.confirm;
        _confirmPin = '';
        _mismatch = false;
        _pinError = null;
      });
    } else {
      _onConfirmComplete();
    }
  }

  void _onConfirmComplete() {
    if (_confirmPin.length < 4) return;

    if (_pin != _confirmPin) {
      setState(() {
        _mismatch = true;
        _errorShake = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _mismatch = false;
            _errorShake = false;
            _confirmPin = '';
          });
        }
      });
      return;
    }

    context.read<AuthBloc>().add(AuthPinCreated(
          userId: widget.userId,
          pin: _pin,
          confirmPin: _confirmPin,
        ));
  }

  void _goBackToCreate() {
    setState(() {
      _step = _PinStep.create;
      _confirmPin = '';
      _mismatch = false;
      _pinError = null;
    });
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
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError && state.isPinError) {
          setState(() {
            _errorShake = true;
            _confirmPin = '';
            _pinError = state.message;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => _errorShake = false);
          });
        } else if (state is AuthError &&
            !state.isPinError &&
            !state.isOtpError) {
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
        final filledCount =
            _step == _PinStep.create ? _pin.length : _confirmPin.length;

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBFC),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Empty space (no back arrow on create PIN)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
                  child: SizedBox(height: 24),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Lock icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFDF0F3),
                            border: Border.all(
                              color: const Color(0xFFEDE0E5),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.lock_outline,
                                size: 28, color: Color(0xFFE8507A)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          _step == _PinStep.create
                              ? 'Create a PIN'
                              : 'Confirm your PIN',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1118),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          _step == _PinStep.create
                              ? 'Protect your account with a 4-digit PIN'
                              : 'Re-enter your PIN to confirm',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B5460),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // PIN boxes
                        PinBoxRow(
                          filledCount: filledCount,
                          hasError: _mismatch || _errorShake,
                        ),
                        const SizedBox(height: 8),

                        // Mismatch error
                        if (_mismatch) ...[
                          const Text(
                            'PINs do not match',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else if (_pinError != null &&
                            _step == _PinStep.create) ...[
                          Text(
                            _pinError!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else
                          const SizedBox(height: 8),

                        // Numeric keypad
                        NumericKeypad(
                          onDigit: _onDigit,
                          onBackspace: _onBackspace,
                        ),
                        const SizedBox(height: 16),

                        // Primary button
                        GestureDetector(
                          onTap: isLoading ? null : _onPrimaryTap,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8507A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _step == _PinStep.create
                                          ? 'Continue'
                                          : 'Confirm PIN',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Skip / Back
                        if (_step == _PinStep.create)
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.home),
                            child: const Text(
                              'Skip For Now',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE8507A),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _goBackToCreate,
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E8A93),
                              ),
                            ),
                          ),
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
