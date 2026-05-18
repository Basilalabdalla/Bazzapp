import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_client.dart';

/// Handles FCM token registration and foreground notification display.
/// Call [init] once after the user logs in successfully.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission (iOS asks the user; Android 13+ also needs this)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Get the FCM token and register it with the backend
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // Re-register if the token rotates (Firebase rotates tokens periodically)
    _messaging.onTokenRefresh.listen(_registerToken);

    // Show a heads-up notification when the app is in the foreground
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      // The OS shows the notification automatically on iOS with the options above.
      // On Android you'd normally use flutter_local_notifications here,
      // but firebase_messaging v15 shows heads-up notifications natively.
      final data = message.data;
      if (data.isNotEmpty) {
        // You can add in-app banner logic here later if needed
      }
    });
  }

  Future<void> _registerToken(String token) async {
    try {
      await ApiClient.instance.patch('/auth/fcm-token', {'fcmToken': token});
    } catch (_) {
      // Non-fatal — will retry on next token refresh
    }
  }

  /// Call on logout so the backend stops sending to this device
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }
}

/// Top-level background message handler — MUST be a top-level function
/// (not a method), annotated so Flutter isolates can find it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in the main isolate.
  // Background messages are shown automatically by the OS — nothing to do here
  // unless you need to update local state or show a custom notification.
}
