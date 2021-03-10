import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thin [RefreshIndicator] wrapper that adds a haptic feedback
class PullToRefresh extends StatelessWidget {
  final VoidCallback onRefresh;
  final Widget child;

  const PullToRefresh({Key key, @required this.onRefresh, @required this.child})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () async {
          await HapticFeedback.mediumImpact();
          onRefresh?.call();
        },
        child: child,
      );
}
