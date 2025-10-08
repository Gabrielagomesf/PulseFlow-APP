import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // URL base do backend web
  String get baseUrl => AppConfig.apiBaseUrl;

  // Headers padrão para requisições
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Enviar código de acesso para o backend
  Future<Map<String, dynamic>> sendAccessCode({
    required String patientId,
    required String accessCode,
    required DateTime expiresAt,
  }) async {
    try {
      final requestBody = {
        'patientId': patientId,
        'accessCode': accessCode,
        'expiresAt': expiresAt.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/access-code/gerar'),
        headers: _defaultHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Erro ao enviar código de acesso: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Verificar se o código foi salvo corretamente
  Future<bool> verifyAccessCode({
    required String patientId,
    required String accessCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/access-code/verificar'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'patientId': patientId,
          'accessCode': accessCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valido'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Testar conexão com o backend
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/access-code/test'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
