import 'package:flutter/material.dart';

import 'app_refresh_scope.dart';

class GlobalRefreshIndicator extends StatelessWidget {
  const GlobalRefreshIndicator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = AppRefreshScope.of(context);

    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      // Let any nested scrollable trigger the refresh.
      notificationPredicate: (notification) => true,
      child: child,
    );
  }
}
