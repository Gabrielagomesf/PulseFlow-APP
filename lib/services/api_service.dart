import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import 'auth_service.dart';
import '../utils/http_client_helper.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Cliente HTTP personalizado que aceita certificados SSL não confiáveis (para desenvolvimento)
  http.Client get _httpClient {
    print('🔧 [ApiService] Obtendo cliente HTTP personalizado');
    return HttpClientHelper.getClient();
  }

  // URL base do backend web
  String get baseUrl => AppConfig.apiBaseUrl;

  // Headers padrão para requisições
  Map<String, String> get _defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Adicionar headers do ngrok se estiver usando ngrok (para evitar página de aviso)
    if (baseUrl.contains('ngrok')) {
      headers['ngrok-skip-browser-warning'] = 'true';
      // Adicionar User-Agent para parecer um navegador e evitar bloqueio
      headers['User-Agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1';
      // Adicionar referer pode ajudar
      headers['Referer'] = baseUrl;
    }
    
    return headers;
  }

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

  Future<http.Response> _postAccessCodeRequest({
    required String base,
    required Map<String, String> headers,
    required Map<String, dynamic> requestBody,
  }) async {
    print('🔧 [ApiService] Executando POST para base: $base');
    return _httpClient.post(
      Uri.parse('$base/api/access-code/gerar'),
      headers: headers,
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 30));
  }

  bool _isLocalTunnelUnavailable(http.Response response) {
    final tunnelStatus = response.headers['x-localtunnel-status'] ?? '';
    return response.statusCode == 503 &&
        tunnelStatus.toLowerCase().contains('tunnel unavailable');
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
      print('🔍 [ApiService] Token presente: ${headers.containsKey('Authorization')}');
      if (headers.containsKey('Authorization')) {
        final authHeader = headers['Authorization']!;
        final tokenPreview = authHeader.length > 20 ? '${authHeader.substring(0, 20)}...' : authHeader;
        print('🔍 [ApiService] Token preview: $tokenPreview');
      }
      print('🔍 [ApiService] Usando cliente HTTP personalizado para SSL');
      print('🔍 [ApiService] Corpo da requisição: ${jsonEncode(requestBody)}');

      var currentBaseUrl = baseUrl;
      var response = await _postAccessCodeRequest(
        base: currentBaseUrl,
        headers: headers,
        requestBody: requestBody,
      );

      if (_isLocalTunnelUnavailable(response)) {
        final fallbackBase = AppConfig.apiFallbackUrl ?? AppConfig.defaultApiBaseUrl;
        if (fallbackBase != currentBaseUrl) {
          print('⚠️ [ApiService] Túnel indisponível. Tentando fallback local: $fallbackBase');
          currentBaseUrl = fallbackBase;
          response = await _postAccessCodeRequest(
            base: currentBaseUrl,
            headers: headers,
            requestBody: requestBody,
          );
          print('📡 [ApiService] Resultado do fallback - Status: ${response.statusCode}');
        } else {
          throw Exception(
            'Túnel local indisponível. Reinicie o serviço do localtunnel/ngrok ou configure API_FALLBACK_URL com o IP do backend.',
          );
        }
      }

      print('✅ [ApiService] Resposta recebida com sucesso');
      
      print('📡 [ApiService] Status code: ${response.statusCode}');
      print('📡 [ApiService] Response body (primeiros 200 chars): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
      print('📡 [ApiService] Response headers: ${response.headers}');
      
      // Verificar se o ngrok está offline (ERR_NGROK_3200)
      final ngrokErrorCode = response.headers['ngrok-error-code'] ?? '';
      final contentType = response.headers['content-type'] ?? '';
      if (ngrokErrorCode == 'ERR_NGROK_3200' || 
          (response.body.contains('is offline') && baseUrl.contains('ngrok'))) {
        print('⚠️ [ApiService] Ngrok está offline (ERR_NGROK_3200). O túnel não está ativo.');
        print('⚠️ [ApiService] Solução: Reinicie o túnel ngrok no servidor backend.');
        throw Exception('Túnel ngrok está offline. O servidor backend não está acessível através do túnel. Reinicie o ngrok no servidor.');
      }
      
      // Verificar se o ngrok está bloqueando (retornando HTML em vez de JSON)
      if (contentType.contains('text/html') && baseUrl.contains('ngrok')) {
        print('⚠️ [ApiService] Ngrok está retornando página HTML (bloqueio). A página de aviso pode estar ativa.');
        print('⚠️ [ApiService] Solução: Visite a URL no navegador uma vez para desbloquear: $baseUrl');
        throw Exception('Ngrok está bloqueando a requisição. Visite $baseUrl no navegador para desbloquear o túnel.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        String errorMessage = 'Erro desconhecido';
        Map<String, dynamic>? errorBody;
        try {
          if (response.body.isNotEmpty) {
            // Tentar decodificar como JSON primeiro
            if (contentType.contains('application/json')) {
              errorBody = jsonDecode(response.body);
              errorMessage = errorBody?['message'] ?? errorBody?['error'] ?? errorBody.toString();
              print('📡 [ApiService] Erro detalhado do servidor: $errorBody');
            } else {
              // Se não for JSON, pode ser HTML do ngrok
              errorMessage = 'Resposta não é JSON (pode ser página de bloqueio do ngrok)';
              print('⚠️ [ApiService] Resposta não é JSON - Content-Type: $contentType');
            }
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body.substring(0, 100) : 'Erro desconhecido';
          print('⚠️ [ApiService] Não foi possível decodificar o corpo da resposta de erro: $e');
        }
        
        // Mensagens específicas por status code
        if (response.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        } else if (response.statusCode == 403) {
          // Melhorar mensagem de erro 403 com mais detalhes
          final detailMessage = errorBody?['message'] ?? errorBody?['error'] ?? 'Acesso negado pelo servidor';
          print('❌ [ApiService] Erro 403 - Detalhes: $detailMessage');
          print('⚠️ [ApiService] Verifique: 1) Se o token JWT é válido, 2) Se o usuário tem permissão para acessar este endpoint, 3) Se o backend está verificando corretamente o token');
          throw Exception('Acesso negado (403). $detailMessage');
        } else if (response.statusCode == 404) {
          // Verificar se é erro do ngrok offline (já tratado acima, mas garantir)
          if (baseUrl.contains('ngrok') && 
              (response.body.contains('is offline') || 
               response.headers['ngrok-error-code'] == 'ERR_NGROK_3200')) {
            throw Exception('Túnel ngrok está offline. Reinicie o ngrok no servidor backend.');
          }
          throw Exception('Endpoint não encontrado. Verifique a configuração do servidor.');
        } else if (response.statusCode == 500) {
          throw Exception('Erro interno do servidor. Tente novamente mais tarde.');
        } else if (response.statusCode == 503) {
          if (_isLocalTunnelUnavailable(response)) {
            throw Exception(
              'Túnel local indisponível (503). Reinicie o túnel ou ajuste API_BASE_URL/API_FALLBACK_URL para uma URL acessível pelo dispositivo.',
            );
          }
          throw Exception('Servidor indisponível (503). Tente novamente em instantes.');
        } else {
          throw Exception('Erro ao enviar código (${response.statusCode}) em $currentBaseUrl - $errorMessage');
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
    } on TlsException catch (e) {
      final errorUrl = '$baseUrl/api/access-code/gerar';
      print('❌ [ApiService] TlsException: ${e.message}');
      print('❌ [ApiService] TlsException OS Error: ${e.osError?.message ?? "N/A"}');
      print('⚠️ [ApiService] Dica: Verifique se o ngrok está rodando e se o servidor backend está acessível');
      print('⚠️ [ApiService] Teste a URL no navegador: $errorUrl');
      throw Exception('Erro de certificado SSL. O servidor pode estar fechando a conexão. Verifique se o ngrok e o servidor backend estão rodando corretamente.');
    } on HandshakeException catch (e) {
      final errorUrl = '$baseUrl/api/access-code/gerar';
      print('❌ [ApiService] HandshakeException: ${e.message}');
      print('❌ [ApiService] HandshakeException OS Error: ${e.osError?.message ?? "N/A"}');
      print('⚠️ [ApiService] Dica: O handshake SSL foi interrompido. Pode ser problema no servidor ou no ngrok');
      print('⚠️ [ApiService] Teste a URL no navegador: $errorUrl');
      throw Exception('Erro de handshake SSL. A conexão foi interrompida durante o handshake. Verifique se o servidor backend está rodando e acessível através do ngrok.');
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
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/access-code/verificar'),
        headers: headers,
        body: jsonEncode({
          'patientId': patientId,
          'accessCode': accessCode,
        }),
      ).timeout(const Duration(seconds: 30));

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
      final response = await _httpClient.get(
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
      final response = await _httpClient.get(
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
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/api/access-code/solicitacoes/$solicitacaoId/visualizar'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> verificarConexaoMedico(String patientId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/pacientes/$patientId/conexao-ativa'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> desconectarMedico(String patientId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/pacientes/$patientId/desconectar-medico'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
