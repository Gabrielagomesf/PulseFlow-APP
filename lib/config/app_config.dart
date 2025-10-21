import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // CONFIGURAÇÕES CENTRALIZADAS DO PULSEFLOW
  
  // PORTA DO SERVIDOR BACKEND (API)
  static const String DEFAULT_BACKEND_PORT = '65432';
  static const String DEFAULT_FRONTEND_PORT = '3000';
  static const String DEFAULT_MONGODB_PORT = '27017';
  
  // URL BASE DA API
  static String get apiBaseUrl {
    try {
      final url = dotenv.env['API_BASE_URL'];
      if (url != null && url.isNotEmpty) {
        return url;
      }
    } catch (e) {
      // Fallback se não conseguir ler o .env
    }
    return 'http://192.168.1.207:$DEFAULT_BACKEND_PORT';
  }
  
  // Configurações do Banco de Dados MongoDB
  static String get mongodbUri {
    try {
      final uri = dotenv.env['MONGODB_URI'];
      if (uri == null || uri.isEmpty) {
        return 'mongodb://localhost:$DEFAULT_MONGODB_PORT/paciente_app';
      }
      return uri;
    } catch (e) {
      return 'mongodb://localhost:$DEFAULT_MONGODB_PORT/paciente_app';
    }
  }

  // Configurações JWT
  static String get jwtSecret {
    try {
      final secret = dotenv.env['JWT_SECRET'];
      if (secret == null || secret.isEmpty) {
        return 'default_secret_key_for_development_2024';
      }
      return secret;
    } catch (e) {
      return 'default_secret_key_for_development_2024';
    }
  }

  // Configurações de E-mail
  static String get emailUser {
    try {
      final user = dotenv.env['EMAIL_USER'];
      if (user == null || user.isEmpty) {
        return '';
      }
      return user;
    } catch (e) {
      return '';
    }
  }

  static String get emailPass {
    try {
      final pass = dotenv.env['EMAIL_PASS'];
      if (pass == null || pass.isEmpty) {
        return '';
      }
      return pass;
    } catch (e) {
      return '';
    }
  }
} 