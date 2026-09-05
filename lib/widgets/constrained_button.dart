import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/app_constants.dart';

class ConstrainedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final double? maxWidth;
  final double maxHeight;

  const ConstrainedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.style,
    this.maxWidth,
    this.maxHeight = 44,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? AppSizing.buttonMaxWidth,
        maxHeight: maxHeight,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
