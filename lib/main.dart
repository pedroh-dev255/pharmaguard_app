//depedences
import 'package:flutter/material.dart';
import 'dart:async';

//services
import 'package:pharmaguard_app/services/config_service.dart';
import 'package:pharmaguard_app/services/notification_service.dart';

//paginas
import 'package:pharmaguard_app/pages/login.page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConfigService.loadConfig();
  //await NotificationService.initialize();
  

  /*
  void startNotificationPolling() {
    final String? baseUrl = ConfigService.get("api_base_url");
    final String? notificationsEndpoint = ConfigService.get("notifications_endpoint");
    final String? timerTime = ConfigService.get("timer");

    if (baseUrl != null && notificationsEndpoint != null && timerTime != null) {
      final String apiUrl = "$baseUrl$notificationsEndpoint";

      final int intervalInMinutes = int.tryParse(timerTime) ?? 30;
      // Iniciar polling para buscar notificações periodicamente
      Timer.periodic(Duration(minutes: intervalInMinutes), (timer) {
        NotificationService.fetchAndShowNotifications(apiUrl);
      });
    } else {
      print("Erro: Não foi possível carregar as configurações da API.");
    }
  }
  
  startNotificationPolling();*/
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*
    final String? baseUrl = ConfigService.get("api_base_url");
    final String? notificationsEndpoint = ConfigService.get("notifications_endpoint");
    
    if (baseUrl != null && notificationsEndpoint != null) {
      final String apiUrl = "$baseUrl$notificationsEndpoint";

      NotificationService.fetchAndShowNotifications(apiUrl);
    }
    */
    return const MaterialApp(
      title: 'PharmaGuard',
      home: LoginPage(),
    );
  }
}
