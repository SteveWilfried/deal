// ═══════════════════════════════════════════════════════════
//  NDOKOTI — Configuration centralisée
//
//  ⚠️  NE JAMAIS committer les vraies clés dans Git.
//      En production, charger via --dart-define ou un .env.
//      Exemple de build :
//        flutter run \
//          --dart-define=NDOKOTI_API_URL=https://api.ndokoti.cm \
//          --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//          --dart-define=SUPABASE_ANON_KEY=eyJ...
// ═══════════════════════════════════════════════════════════

class AppConfig {
  AppConfig._();

  // ── URLs ────────────────────────────────────────────────

  /// URL de base de l'API FastAPI Ndokoti.
  /// En développement local : http://10.0.2.2:8000  (émulateur Android)
  ///                          http://localhost:8000  (simulateur iOS)
  /// En production           : https://api.ndokoti.cm
  static const String apiBaseUrl = String.fromEnvironment(
    'NDOKOTI_API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Version de l'API — préfixe de tous les endpoints
  static const String apiVersion = '/v1';

  /// URL complète avec version
  static String get apiUrl => '$apiBaseUrl$apiVersion';

  // ── Supabase ─────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://VOTRE_PROJECT_ID.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'VOTRE_ANON_KEY',
  );

  // ── Timeouts HTTP ────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout    = Duration(seconds: 30);

  // ── Pagination ───────────────────────────────────────────
  static const int defaultPerPage = 20;
  static const int flashDealsLimit = 8;
  static const int popularDealsLimit = 20;

  // ── Mode ─────────────────────────────────────────────────
  /// true = utilise le vrai backend Ndokoti
  /// false = fallback sur DummyJSON (mode démo)
  static const bool useRealBackend = bool.fromEnvironment(
    'USE_REAL_BACKEND',
    defaultValue: false,
  );

  // ── Flags fonctionnels ───────────────────────────────────
  static const bool enableVoiceSearch  = false; // sprint 2
  static const bool enableImageSearch  = false; // sprint 2
  static const bool enableAiGeneration = false; // sprint 2
}
