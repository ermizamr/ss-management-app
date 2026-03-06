import 'package:flutter/widgets.dart';

import 'app_refresh_controller.dart';

class AppRefreshScope extends InheritedNotifier<AppRefreshController> {
  const AppRefreshScope({
    super.key,
    required AppRefreshController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppRefreshController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppRefreshScope>();
    assert(scope != null, 'AppRefreshScope not found in widget tree');
    return scope!.notifier!;
  }
}
