import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_channels.dart';

/// Construtores de notificações específicas
class NotificationBuilders {
  /// Cores do app
  static const Color primaryColor = Color(0xFF00324A);

  /// Padrão de vibração padrão
  static final Int64List defaultVibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

  /// Criar detalhes de notificação para solicitação de acesso médico
  static NotificationDetails createDoctorAccessNotification({
    required String doctorName,
    required String specialty,
  }) {
    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.doctorAccessChannelId,
      'Solicitações de Acesso Médico',
      channelDescription: 'Notificações quando um médico solicita acesso ao prontuário',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: defaultVibrationPattern,
      enableLights: true,
      color: primaryColor,
      ledColor: primaryColor,
      ledOnMs: 1000,
      ledOffMs: 500,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'Dr(a). $doctorName ${specialty.isNotEmpty ? "($specialty)" : ""} solicitou acesso ao seu prontuário médico. Abra o app para gerar o código de acesso.',
        htmlFormatBigText: true,
        contentTitle: '🩺 SOLICITAÇÃO DE ACESSO',
        htmlFormatContentTitle: true,
        summaryText: 'PulseFlow',
      ),
      ticker: 'Médico solicitou acesso',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
      threadIdentifier: 'doctor_access',
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Criar detalhes de notificação importante
  static NotificationDetails createImportantNotification() {
    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.importantChannelId,
      'Notificações Importantes',
      channelDescription: 'Notificações importantes do PulseFlow',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: defaultVibrationPattern,
      enableLights: true,
      color: primaryColor,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Criar detalhes de notificação para lembretes de medicação
  static NotificationDetails createMedicationReminder() {
    const androidDetails = AndroidNotificationDetails(
      NotificationChannels.medicationChannelId,
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

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Criar detalhes de notificação para lembretes de consultas
  static NotificationDetails createAppointmentReminder() {
    const androidDetails = AndroidNotificationDetails(
      NotificationChannels.appointmentChannelId,
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

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Criar detalhes de notificação geral
  static NotificationDetails createGeneralNotification() {
    const androidDetails = AndroidNotificationDetails(
      NotificationChannels.generalChannelId,
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

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Criar detalhes para mensagens em background
  static NotificationDetails createBackgroundMessageNotification() {
    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.doctorAccessChannelId,
      'Solicitações de Acesso Médico',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: defaultVibrationPattern,
      enableLights: true,
      color: primaryColor,
      ledColor: primaryColor,
      ledOnMs: 1000,
      ledOffMs: 500,
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }
}

