import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicialização do serviço de notificações
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Exibir uma notificação local
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0, // ID da notificação
      title,
      body,
      notificationDetails,
    );
  }

  // Buscar notificações da API
  
  static Future<void> fetchAndShowNotifications(String apiUrl) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      
      if (response.statusCode == 200) {
        final List notifications = jsonDecode(response.body);

        for (var notification in notifications) {
          showNotification(notification['title'], notification['body']);
        }
      } else {
        print("Erro ao buscar notificações: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao conectar à API: $e");
      print(apiUrl);
    }
  }
}
