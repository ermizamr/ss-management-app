import 'package:flutter/widgets.dart';

import 'app_refresh_controller.dart';
import 'app_refresh_scope.dart';

class AppRefreshConfigurator extends StatefulWidget {
  const AppRefreshConfigurator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final AppRefreshCallback? onRefresh;
  final Widget child;

  @override
  State<AppRefreshConfigurator> createState() => _AppRefreshConfiguratorState();
}

class _AppRefreshConfiguratorState extends State<AppRefreshConfigurator> {
  AppRefreshController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AppRefreshScope.of(context);
    _controller?.setOnRefresh(widget.onRefresh);
  }

  @override
  void didUpdateWidget(covariant AppRefreshConfigurator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onRefresh != widget.onRefresh) {
      _controller?.setOnRefresh(widget.onRefresh);
    }
  }

  @override
  void dispose() {
    _controller?.setOnRefresh(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
