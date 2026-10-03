import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    String url;
    String anonKey;

    try {
      if (kIsWeb) {
        // 1. Web Implementation: Load from JSON Asset
        final String response = await rootBundle.loadString('assets/app_config.json');
        final data = json.decode(response);
        
        url = data['SUPABASE_URL'] ?? '';
        anonKey = data['SUPABASE_ANON_KEY'] ?? '';

        if (url.isEmpty || anonKey.isEmpty) {
          throw Exception("Web config: SUPABASE_URL or ANON_KEY is missing in app_config.json");
        }
      } else {
        // 2. Mobile Implementation: Load from .env using flutter_dotenv
        await dotenv.load(fileName: ".env");
        
        url = dotenv.env['SUPABASE_URL'] ?? '';
        anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

        if (url.isEmpty || anonKey.isEmpty) {
          throw Exception("Mobile config: SUPABASE_URL or ANON_KEY is missing in .env");
        }
      }

      // 3. Initialize Supabase with the resolved credentials
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      
      debugPrint("Supabase initialized successfully on ${kIsWeb ? 'Web' : 'Mobile'}");
      
    } on FlutterError catch (e) {
      debugPrint("Asset loading error: $e");
      rethrow;
    } catch (e) {
      debugPrint("Supabase Initialization Error: $e");
      rethrow;
    }
  }
}
