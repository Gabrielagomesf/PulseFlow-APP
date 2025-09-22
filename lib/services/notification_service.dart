import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }
  
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    await _requestPermissions();
  }
  
  Future<void> _initializeFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Usuário autorizou notificações');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Usuário autorizou notificações provisórias');
    } else {
      print('Usuário recusou ou não autorizou notificações');
    }
    
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');
    
    if (_fcmToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', _fcmToken!);
    }
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }
  
  Future<void> _requestPermissions() async {
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    await _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    print('Notificação tocada: ${response.payload}');
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensagem recebida em foreground: ${message.notification?.title}');
    
    _showLocalNotification(
      message.notification?.title ?? 'PulseFlow',
      message.notification?.body ?? 'Nova mensagem',
      message.data,
    );
  }
  
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Mensagem recebida em background: ${message.notification?.title}');
  }
  
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'pulseflow_channel',
      'PulseFlow Notifications',
      channelDescription: 'Canal de notificações do PulseFlow',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: data.toString(),
    );
  }
  
  Future<void> testNotification() async {
    await _showLocalNotification(
      'Teste de Notificação',
      'Esta é uma notificação de teste do PulseFlow!',
      {'type': 'test'},
    );
  }
  
  Future<void> scheduleMedicationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Lembretes de Medicação',
      channelDescription: 'Lembretes para tomar medicamentos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      notificationDetails,
      payload: 'medication_reminder',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Lembretes de Consultas',
      channelDescription: 'Lembretes para consultas médicas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      notificationDetails,
      payload: 'appointment_reminder',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
  
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
  
  Future<void> cancelMedicationReminders() async {
  }
  
  Future<void> cancelAppointmentReminders() async {
  }
  
  dynamic _convertToTZDateTime(DateTime dateTime) {
    return dateTime;
  }
  
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
  
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Inscrito no tópico: $topic');
  }
  
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Desinscrito do tópico: $topic');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem em background: ${message.notification?.title}');
}
