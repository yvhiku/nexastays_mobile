import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// OTP palette — darker berry digits + brand pink accents.
abstract final class _OtpColors {
  static const primary = Color(0xFF864E5E);
  static const accent = Color(0xFFE8507A);
  static const secondaryContainer = Color(0xFFF5D0DA);
  static const surfaceContainerLow = Color(0xFFFDF1F2);
  static const onSurfaceVariant = Color(0xFF514346);
  static const error = Color(0xFFBA1A1A);
  static const errorSurface = Color(0xFFFFDAD6);
}

class OtpInputRow extends StatefulWidget {
  final Function(String otp) onCompleted;
  final VoidCallback onResend;
  final int resendCountdown;
  final bool hasError;
  final bool showResend;

  const OtpInputRow({
    super.key,
    required this.onCompleted,
    required this.onResend,
    required this.resendCountdown,
    this.hasError = false,
    this.showResend = true,
  });

  @override
  State<OtpInputRow> createState() => OtpInputRowState();
}

class OtpInputRowState extends State<OtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  String get _otp => _controllers.map((c) => c.text).join();

  static String _formatCountdown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());

    for (final node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {});
    _focusNodes.first.requestFocus();
  }

  void _onChanged(String val, int index) {
    if (val.length > 1) {
      _controllers[index].text = val.substring(val.length - 1);
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }
    if (val.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
      if (_otp.length == 6) {
        widget.onCompleted(_otp);
      }
    }
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Widget _buildOtpBox(int i) {
    final isFocused = _focusNodes[i].hasFocus;
    final isFilled = _controllers[i].text.isNotEmpty;
    final hasError = widget.hasError;

    Color borderColor;
    Color bgColor;
    Color textColor;
    List<BoxShadow> shadows = [];

    if (hasError) {
      borderColor = _OtpColors.error;
      bgColor = _OtpColors.errorSurface;
      textColor = _OtpColors.error;
    } else if (isFilled) {
      // Keep filled styling when digits are entered — soft pink fill + berry border.
      borderColor = _OtpColors.primary;
      bgColor = _OtpColors.secondaryContainer;
      textColor = _OtpColors.primary;
    } else if (isFocused) {
      borderColor = _OtpColors.accent;
      bgColor = Colors.white;
      textColor = _OtpColors.primary;
      shadows = [
        BoxShadow(
          color: _OtpColors.accent.withValues(alpha: 0.35),
          blurRadius: 0,
          spreadRadius: 2,
        ),
      ];
    } else {
      borderColor = Colors.transparent;
      bgColor = _OtpColors.surfaceContainerLow;
      textColor = _OtpColors.primary;
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: i < 5 ? 12 : 0),
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: shadows,
                ),
                child: Center(
                  child: Text(
                    _controllers[i].text,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              KeyboardListener(
                focusNode: FocusNode(skipTraversal: true),
                onKeyEvent: (event) => _onKeyEvent(event, i),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 24,
                  ),
                  cursorColor: Colors.transparent,
                  cursorWidth: 0,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _onChanged(val, i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 64,
          child: Row(
            children: List.generate(6, _buildOtpBox),
          ),
        ),
        if (widget.showResend) ...[
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                "Didn't receive the code?",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _OtpColors.onSurfaceVariant,
                ),
              ),
              if (widget.resendCountdown > 0)
                Text(
                  'Resend in ${_formatCountdown(widget.resendCountdown)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _OtpColors.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
                )
              else
                GestureDetector(
                  onTap: widget.onResend,
                  child: Text(
                    'Resend Code',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _OtpColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
