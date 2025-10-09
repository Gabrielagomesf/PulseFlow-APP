import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_channels.dart';
import 'notification_builders.dart';

/// Handlers para mensagens Firebase
class FirebaseHandlers {
  /// Handler para mensagens em foreground
  static void handleForegroundMessage(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin localNotifications,
  ) {
    _showLocalNotification(
      localNotifications,
      message.notification?.title ?? 'PulseFlow',
      message.notification?.body ?? 'Nova mensagem',
      message.data,
    );
  }

  /// Handler para mensagens em background (app minimizado)
  static void handleBackgroundMessage(RemoteMessage message) {
    // Mensagem recebida em background
  }

  /// Handler para quando o app é aberto via notificação
  static void handleNotificationTap(NotificationResponse response) {
    // Notificação foi tocada
  }

  /// Exibir notificação local
  static Future<void> _showLocalNotification(
    FlutterLocalNotificationsPlugin plugin,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationBuilders.createGeneralNotification(),
      payload: data.toString(),
    );
  }
}

/// Handler global para mensagens em background (app fechado)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase já inicializado
  }

  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  // Criar o canal de notificação
  await localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(NotificationChannels.doctorAccessChannel);

  // Exibir notificação
  await localNotifications.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    message.notification?.title ?? 'PulseFlow',
    message.notification?.body ?? 'Nova mensagem',
    NotificationBuilders.createBackgroundMessageNotification(),
    payload: message.data.toString(),
  );
}

