import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Configurações do Banco de Dados MongoDB
  static String get mongodbUri {
    try {
      final uri = dotenv.env['MONGODB_URI'];
      if (uri == null || uri.isEmpty) {
        return 'mongodb://localhost:27017/paciente_app';
      }
      return uri;
    } catch (e) {
      return 'mongodb://localhost:27017/paciente_app';
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

  // Configurações de E-mail (Gmail)
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