import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/app_constants.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool centerContent;
  final double maxWidth;
  final bool useDesktopPadding;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizing.m),
    this.centerContent = true,
    this.maxWidth = 1200,
    this.useDesktopPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width > AppSizing.desktopBreakpoint;

    // Use smaller padding on desktop
    final effectivePadding =
        isDesktop && useDesktopPadding ? const EdgeInsets.all(12) : padding;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}
