import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static String get connectionString {
    try {
      final envUri = dotenv.env['MONGODB_URI'];
      if (envUri != null && envUri.isNotEmpty) {
        return envUri;
      }
    } catch (e) {
      print('⚠️ dotenv não inicializado ainda, usando configuração padrão: $e');
    }
    // Configuração padrão para desenvolvimento local
    return 'mongodb://localhost:27017/paciente_app';
  }
  
  static const String databaseName = 'paciente_app';
  static const String patientsCollection = 'patients';
  static const String medicalNotesCollection = 'anotacaomedicas';
 static const String enxaquecasCollection = 'enxaquecas';
  static const String diabetesCollection = 'diabetes';
  

  static const Map<String, dynamic> connectionOptions = {
    'retryWrites': true,
    'w': 'majority',
    'connectTimeoutMS': 10000,
    'socketTimeoutMS': 10000,
    'serverSelectionTimeoutMS': 10000,
    'maxPoolSize': 10,
    'minPoolSize': 1,
  };
}


