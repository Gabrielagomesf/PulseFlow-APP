import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

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

  // Headers com autenticação
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    try {
      final authService = Get.find<AuthService>();
      // Obter token do storage diretamente se o token.value estiver vazio
      String token = authService.token;
      if (token.isEmpty) {
        // Tentar obter token do storage diretamente
        final storage = const FlutterSecureStorage();
        token = await storage.read(key: 'auth_token') ?? '';
      }
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Se não conseguir obter o AuthService, retorna headers sem autenticação
    }
    return headers;
  }

  // Enviar código de acesso para o backend
  Future<Map<String, dynamic>> sendAccessCode({
    required String patientId,
    required String accessCode,
    required DateTime expiresAt,
  }) async {
    try {
      final url = '$baseUrl/api/access-code/gerar';
      
      // Debug: verificar URL e baseUrl
      print('🔍 [ApiService] Tentando enviar código para: $url');
      print('🔍 [ApiService] Base URL: $baseUrl');
      
      final requestBody = {
        'patientId': patientId,
        'accessCode': accessCode,
        'expiresAt': expiresAt.toIso8601String(),
      };

      final headers = await _getAuthHeaders();
      
      // Verificar se tem token de autenticação
      if (!headers.containsKey('Authorization')) {
        print('❌ [ApiService] Token de autenticação não encontrado');
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }
      
      print('✅ [ApiService] Token de autenticação encontrado');
      print('🔍 [ApiService] Headers (sem token): ${headers.keys.toList()}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));
      
      print('📡 [ApiService] Status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        String errorMessage = 'Erro desconhecido';
        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(response.body);
            errorMessage = errorBody['message'] ?? errorBody.toString();
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : 'Erro desconhecido';
        }
        
        // Mensagens específicas por status code
        if (response.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        } else if (response.statusCode == 403) {
          throw Exception('Acesso negado. Verifique suas permissões.');
        } else if (response.statusCode == 404) {
          throw Exception('Endpoint não encontrado. Verifique a configuração do servidor.');
        } else if (response.statusCode == 500) {
          throw Exception('Erro interno do servidor. Tente novamente mais tarde.');
        } else {
          throw Exception('Erro ao enviar código: ${response.statusCode} - $errorMessage');
        }
      }
    } on SocketException catch (e) {
      print('❌ [ApiService] SocketException: ${e.message}');
      print('❌ [ApiService] OS Error: ${e.osError?.message ?? "N/A"}');
      print('❌ [ApiService] Address: ${e.address}');
      print('❌ [ApiService] Port: ${e.port}');
      // Verificar se é realmente problema de conexão ou configuração
      final osErrorMsg = e.osError?.message ?? '';
      if (osErrorMsg.contains('nodename nor servname provided') ||
          osErrorMsg.contains('No address associated with hostname') ||
          osErrorMsg.contains('Name or service not known')) {
        throw Exception('URL do servidor inválida: $baseUrl. Verifique se o IP/domínio está correto.');
      }
      if (osErrorMsg.contains('Connection refused') || 
          osErrorMsg.contains('Connection reset') ||
          osErrorMsg.contains('Network is unreachable')) {
        throw Exception('Não foi possível conectar ao servidor $baseUrl. Verifique:\n1. Se o servidor está rodando\n2. Se o IP/porta estão corretos\n3. Se há firewall bloqueando');
      }
      throw Exception('Erro de conexão com o servidor $baseUrl: ${osErrorMsg.isNotEmpty ? osErrorMsg : e.message}');
    } on http.ClientException catch (e) {
      print('❌ [ApiService] ClientException: ${e.message}');
      print('❌ [ApiService] URI: ${e.uri}');
      // Pode ser CORS, SSL, ou outros problemas de rede
      if (e.message.contains('CORS') || e.message.contains('cors')) {
        throw Exception('Erro de CORS: O servidor não permite requisições desta origem.');
      }
      throw Exception('Erro de conexão HTTP: ${e.message}');
    } on TimeoutException catch (e) {
      print('❌ [ApiService] TimeoutException: ${e.message}');
      throw Exception('Tempo de espera esgotado. O servidor demorou muito para responder. Verifique se o servidor está acessível.');
    } on FormatException catch (e) {
      print('❌ [ApiService] FormatException: ${e.message}');
      throw Exception('Erro ao processar resposta do servidor: ${e.message}');
    } catch (e) {
      print('❌ [ApiService] Erro genérico: ${e.runtimeType} - ${e.toString()}');
      print('❌ [ApiService] Stack trace: ${StackTrace.current}');
      // Se já é uma Exception com mensagem, relançar sem duplicar
      if (e is Exception) {
        // Se a mensagem já está formatada, apenas relançar
        final errorStr = e.toString();
        if (errorStr.contains('Token') || 
            errorStr.contains('Sessão') || 
            errorStr.contains('Erro ao enviar') ||
            errorStr.contains('Servidor não está acessível') ||
            errorStr.contains('não foi possível conectar') ||
            errorStr.contains('URL do servidor')) {
          rethrow;
        }
      }
      // Para outros erros, criar nova Exception com mensagem limpa
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      throw Exception('Erro ao enviar código: $errorMsg');
    }
  }

  // Verificar se o código foi salvo corretamente
  Future<bool> verifyAccessCode({
    required String patientId,
    required String accessCode,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/access-code/verificar'),
        headers: headers,
        body: jsonEncode({
          'patientId': patientId,
          'accessCode': accessCode,
        }),
      ).timeout(const Duration(seconds: 10));

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

  // Buscar solicitações de acesso pendentes
  Future<List<Map<String, dynamic>>> buscarSolicitacoesPendentes(String patientId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/access-code/solicitacoes/$patientId'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['solicitacoes'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Marcar solicitação como visualizada
  Future<bool> marcarSolicitacaoVisualizada(String solicitacaoId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/access-code/solicitacoes/$solicitacaoId/visualizar'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
