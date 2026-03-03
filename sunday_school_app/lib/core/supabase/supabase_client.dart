import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseClientManager {
  SupabaseClientManager._();

  static final SupabaseClientManager instance = SupabaseClientManager._();

  bool _initialized = false;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    _initialized = true;
  }
}

