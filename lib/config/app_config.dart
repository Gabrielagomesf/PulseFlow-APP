import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Configurações do Banco de Dados MongoDB
  static String get mongodbUri => 
    dotenv.env['MONGODB_URI'] ?? 'mongodb://localhost:27017/paciente_app';

  // Configurações JWT
  static String get jwtSecret => 
    dotenv.env['JWT_SECRET'] ?? 'default_secret_key_for_development_2024';

  // Configurações de E-mail (Gmail)
  static String get emailUser => 
    dotenv.env['EMAIL_USER'] ?? '';

  static String get emailPass => 
    dotenv.env['EMAIL_PASS'] ?? '';

  // Configurações da API
  static String get apiBaseUrl => 
    dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  // Configurações do App
  static const String appName = 'PulseFlow Saúde';
  static const String appVersion = '1.0.0';
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration twoFactorCodeExpiration = Duration(minutes: 5);
  
  // Validações
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 3;
  static const int maxNameLength = 100;
  
  // URLs
  static const String privacyPolicyUrl = 'https://pulseflow.com.br/privacy';
  static const String termsOfServiceUrl = 'https://pulseflow.com.br/terms';
  static const String supportEmail = 'suporte@pulseflow.com.br';
} 