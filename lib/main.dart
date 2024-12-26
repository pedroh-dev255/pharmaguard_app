//depedences
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';

//services
import 'package:pharmaguard_app/services/config_service.dart';
import 'package:pharmaguard_app/services/notification_service.dart';

//paginas
import 'package:pharmaguard_app/pages/login.page.dart';


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final apiUrl = inputData?['apiUrl'] as String;
    await NotificationService.fetchAndShowNotifications(apiUrl);
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await ConfigService.loadConfig();
  await NotificationService.initialize();
  
  final String? baseUrl = ConfigService.get("api_base_url");
  final String? notificationsEndpoint = ConfigService.get("notifications_endpoint");
  final String? timerTime = ConfigService.get("timer");
  final String apiUrl = "$baseUrl$notificationsEndpoint";
  
  void startNotificationPolling() {
    if (baseUrl != null && notificationsEndpoint != null && timerTime != null) {
      final int intervalInMinutes = int.tryParse(timerTime) ?? 120;
      
      Timer.periodic(Duration(minutes: intervalInMinutes), (timer) {
        NotificationService.fetchAndShowNotifications(apiUrl);
      });
    } else {
      print("Erro: Não foi possível carregar as configurações da API.");
    }
  }
  
  Workmanager().registerPeriodicTask(
    'fetchNotifications',
    'fetchNotifications',
    inputData: {'apiUrl': apiUrl},
    frequency: Duration(minutes: 240),
    initialDelay: Duration(minutes: 2),
  );


  
  startNotificationPolling();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final String? baseUrl = ConfigService.get("api_base_url");
    final String? notificationsEndpoint = ConfigService.get("notifications_endpoint");
    
    if (baseUrl != null && notificationsEndpoint != null) {
      final String apiUrl = "$baseUrl$notificationsEndpoint";

      NotificationService.fetchAndShowNotifications(apiUrl);
    }
    
    return const MaterialApp(
      title: 'PharmaGuard',
      home: LoginPage(),
    );
  }
}
