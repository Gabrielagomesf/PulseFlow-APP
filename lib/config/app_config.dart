import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // CONFIGURAÇÕES CENTRALIZADAS DO PULSEFLOW
  
  // PORTA DO SERVIDOR BACKEND (API)
  static const String DEFAULT_BACKEND_PORT = '65432';
  static const String DEFAULT_FRONTEND_PORT = '3000';
  static const String DEFAULT_MONGODB_PORT = '27017';
  
  // URL BASE DA API
  // Para alterar a URL do servidor, edite o arquivo .env na raiz do projeto
  // e adicione: API_BASE_URL=http://seu-ip-ou-dominio:porta
  // Exemplo: API_BASE_URL=http://localhost:65432
  // Exemplo: API_BASE_URL=http://192.168.1.100:65432
  static String get apiBaseUrl {
    try {
      final url = dotenv.env['API_BASE_URL'];
      if (url != null && url.isNotEmpty) {
        // Remover barra final se existir
        return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      }
    } catch (e) {
      // Fallback se não conseguir ler o .env
      print('⚠️ [AppConfig] Erro ao ler API_BASE_URL do .env: $e');
    }
    // URL padrão de fallback (desenvolvimento local)
    return 'http://localhost:$DEFAULT_BACKEND_PORT';
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