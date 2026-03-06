import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap/bootstrap_error_screen.dart';
import 'core/refresh/app_refresh_controller.dart';
import 'core/refresh/app_refresh_scope.dart';
import 'core/refresh/global_refresh_indicator.dart';
import 'core/routing/app_router.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? bootstrapError;
  try {
    await SupabaseClientManager.instance.init();
  } catch (e, st) {
    bootstrapError = e;
    FlutterError.reportError(
      FlutterErrorDetails(exception: e, stack: st, library: 'app bootstrap'),
    );
  }

  runApp(ProviderScope(child: SundaySchoolApp(bootstrapError: bootstrapError)));
}

class SundaySchoolApp extends StatefulWidget {
  const SundaySchoolApp({super.key, this.bootstrapError});

  final Object? bootstrapError;

  @override
  State<SundaySchoolApp> createState() => _SundaySchoolAppState();
}

class _SundaySchoolAppState extends State<SundaySchoolApp> {
  late final AppRefreshController _refreshController = AppRefreshController(
    defaultOnRefresh: () async {
      try {
        await SupabaseClientManager.instance.client.auth.refreshSession();
      } catch (_) {}
      try {
        appRouter.refresh();
      } catch (_) {}
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0EA5E9)),
      useMaterial3: true,
    );

    if (widget.bootstrapError != null) {
      return MaterialApp(
        title: 'Sunday School Management',
        theme: theme,
        home: BootstrapErrorScreen(message: widget.bootstrapError.toString()),
      );
    }

    return MaterialApp.router(
      title: 'Sunday School Management',
      theme: theme,
      routerConfig: appRouter,
      builder: (context, child) {
        final routedChild = child ?? const SizedBox.shrink();
        return AppRefreshScope(
          controller: _refreshController,
          child: GlobalRefreshIndicator(child: routedChild),
        );
      },
    );
  }
}
