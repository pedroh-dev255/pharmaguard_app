import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ConfigService {
  static Map<String, dynamic>? _config;

  // Carregar o arquivo config.json
  static Future<void> loadConfig() async {
    final String configString = await rootBundle.loadString('assets/config.json');
    _config = jsonDecode(configString);
  }

  // Obter valores do arquivo de configuração
  static String? get(String key) {
    return _config?[key];
  }
}
