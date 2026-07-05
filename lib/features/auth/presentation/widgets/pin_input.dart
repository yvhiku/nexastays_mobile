import 'package:flutter/material.dart';

// ━━━ PinBoxRow ━━━

class PinBoxRow extends StatefulWidget {
  final int filledCount;
  final bool hasError;

  const PinBoxRow({
    super.key,
    required this.filledCount,
    this.hasError = false,
  });

  @override
  State<PinBoxRow> createState() => _PinBoxRowState();
}

class _PinBoxRowState extends State<PinBoxRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(PinBoxRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.hasError && widget.hasError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Widget _buildBox(int index) {
    final bool isFilled = index < widget.filledCount;
    final bool isActive = index == widget.filledCount;

    Color borderColor;
    Color bgColor;
    List<BoxShadow> shadows = [];

    if (widget.hasError) {
      borderColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEF2F2);
    } else if (isFilled) {
      borderColor = const Color(0xFFE8507A);
      bgColor = const Color(0xFFFDF0F3);
    } else if (isActive) {
      borderColor = const Color(0xFFE8507A);
      bgColor = const Color(0xFFF8F2F5);
      shadows = [
        BoxShadow(
          color: const Color(0xFFE8507A).withOpacity(0.10),
          blurRadius: 0,
          spreadRadius: 3,
        ),
      ];
    } else {
      borderColor = const Color(0xFFEDE0E5);
      bgColor = const Color(0xFFF8F2F5);
    }

    return Container(
      width: 52,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: shadows,
      ),
      child: isFilled
          ? const Center(
              child: CircleAvatar(
                radius: 5,
                backgroundColor: Color(0xFFE8507A),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < 3 ? 12.0 : 0.0),
            child: _buildBox(i),
          );
        }),
      ),
    );
  }
}

// ━━━ NumericKeypad ━━━

class NumericKeypad extends StatelessWidget {
  final Function(String digit) onDigit;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: ((MediaQuery.of(context).size.width - 48 - 20) / 3) / 46,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox.shrink();
        } else if (key == '⌫') {
          return GestureDetector(
            onTap: onBackspace,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '⌫',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE8507A),
                  ),
                ),
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () => onDigit(key),
            child: Material(
              color: const Color(0xFFF8F2F5),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onDigit(key),
                borderRadius: BorderRadius.circular(12),
                splashColor: const Color(0xFFE8507A).withOpacity(0.1),
                highlightColor: Colors.transparent,
                child: SizedBox(
                  height: 46,
                  child: Center(
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1118),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}
