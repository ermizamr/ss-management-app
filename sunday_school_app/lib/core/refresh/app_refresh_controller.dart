import 'package:flutter/foundation.dart';

typedef AppRefreshCallback = Future<void> Function();

class AppRefreshController extends ChangeNotifier {
  AppRefreshController({required AppRefreshCallback defaultOnRefresh})
    : _defaultOnRefresh = defaultOnRefresh;

  final AppRefreshCallback _defaultOnRefresh;
  AppRefreshCallback? _onRefresh;

  AppRefreshCallback get onRefresh => _onRefresh ?? _defaultOnRefresh;

  void setOnRefresh(AppRefreshCallback? callback) {
    _onRefresh = callback;
    notifyListeners();
  }
}
