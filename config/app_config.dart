/// Configuration file for MSAI Chat environment, API endpoints, and secrets.
/// NEVER hardcode production private keys or credentials directly in source files.
class AppConfig {
  static const String appName = 'MSAI Chat';
  static const String appVersion = '1.0.0';

  // Backend API Endpoints (Configurable for production)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.msaichat.com/v1',
  );

  static const String webRtcSignalingServer = String.fromEnvironment(
    'WEBRTC_SIGNALING_URL',
    defaultValue: 'wss://signaling.msaichat.com',
  );

  // Firebase / Backend Project Config Placeholder
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'msai-chat-prod',
  );

  static const bool enableOfflineMode = true;
  static const int syncIntervalSeconds = 15;
}
