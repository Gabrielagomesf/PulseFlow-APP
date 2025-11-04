import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class PulseKeyScreen extends StatefulWidget {
  const PulseKeyScreen({super.key});

  @override
  State<PulseKeyScreen> createState() => _PulseKeyScreenState();
}

class _PulseKeyScreenState extends State<PulseKeyScreen> {
  String _currentCode = '';
  int _timeRemaining = 120; // 2 minutos em segundos
  bool _isActive = true;
  DateTime? _lastCodeGeneration;
  Timer? _timer;
  final ApiService _apiService = ApiService();
  final AuthService _authService = Get.find<AuthService>();
  bool _isSendingCode = false;

  @override
  void initState() {
    super.initState();
    _initializeCode();
    _startTimer();
  }

  void _initializeCode() async {
    final now = DateTime.now();
    final random = Random();
    final newCode = (100000 + random.nextInt(900000)).toString();
    final expiresAt = now.add(const Duration(minutes: 2));
    
    setState(() {
      _currentCode = newCode;
      _lastCodeGeneration = now;
      _timeRemaining = 120;
      _isSendingCode = true;
    });

    await _sendCodeToBackend(newCode, expiresAt);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isActive) {
        setState(() {
          _timeRemaining--;
          if (_timeRemaining <= 0) {
            _generateNewCode();
            _timeRemaining = 120;
          }
        });
      }
    });
  }

  void _generateNewCode() async {
    final now = DateTime.now();
    final random = Random();
    final newCode = (100000 + random.nextInt(900000)).toString();
    final expiresAt = now.add(const Duration(minutes: 2));
    
    setState(() {
      _currentCode = newCode;
      _lastCodeGeneration = now;
      _isSendingCode = true;
    });

    // Enviar código para o backend
    await _sendCodeToBackend(newCode, expiresAt);
  }

  Future<void> _sendCodeToBackend(String code, DateTime expiresAt) async {
    try {
      final currentUser = _authService.currentUser;
      
      if (currentUser == null || currentUser.id == null) {
        if (mounted) {
          Get.snackbar(
            'Aviso',
            'Usuário não autenticado. O código está disponível mas não será sincronizado.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
        return;
      }

      await _apiService.sendAccessCode(
        patientId: currentUser.id!,
        accessCode: code,
        expiresAt: expiresAt,
      );
      
      print('✅ [PulseKeyScreen] Código sincronizado com sucesso');
      
    } catch (e) {
      // Não bloquear a funcionalidade - o código ainda funciona localmente
      if (mounted) {
        String errorMessage = 'Não foi possível sincronizar com o servidor.';
        String fullError = e.toString();
        
        // Debug: mostrar erro completo no console
        print('⚠️ [PulseKeyScreen] Erro de sincronização (código ainda funciona): $fullError');
        
        // Detectar tipo de erro específico
        if (fullError.contains('Token de autenticação não encontrado') || 
            fullError.contains('Sessão expirada')) {
          errorMessage = 'Sessão expirada. O código está disponível mas não será sincronizado.';
        } else if (fullError.contains('Servidor não está acessível') ||
                   fullError.contains('URL do servidor inválida') || 
                   fullError.contains('não foi possível conectar ao servidor') ||
                   fullError.contains('Connection refused') ||
                   fullError.contains('Network is unreachable')) {
          // Para erros de conexão, mostrar aviso mais amigável
          errorMessage = 'Servidor não acessível. O código está disponível localmente.\n\nVerifique a conexão com o servidor nas configurações.';
        } else if (fullError.contains('CORS')) {
          errorMessage = 'Erro de configuração do servidor (CORS). O código está disponível localmente.';
        } else if (fullError.contains('401') || fullError.contains('Unauthorized')) {
          errorMessage = 'Sessão expirada. O código está disponível mas não será sincronizado.';
        } else if (fullError.contains('403') || fullError.contains('Forbidden')) {
          errorMessage = 'Acesso negado. O código está disponível localmente.';
        } else if (fullError.contains('404') || fullError.contains('not found')) {
          errorMessage = 'Endpoint não encontrado. O código está disponível localmente.';
        } else if (fullError.contains('500') || fullError.contains('Internal Server Error')) {
          errorMessage = 'Erro no servidor. O código está disponível localmente.';
        } else if (fullError.contains('Tempo de espera esgotado') || 
                   fullError.contains('Timeout')) {
          errorMessage = 'Servidor não respondeu. O código está disponível localmente.';
        }
        
        // Mostrar aviso (não erro) já que o código ainda funciona
        Get.snackbar(
          'Aviso de Sincronização',
          errorMessage,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _currentCode));
    Get.snackbar(
      'Código copiado!',
      'O código foi copiado para a área de transferência',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFF00324A),
      body: SafeArea(
        child: Column(
          children: [
            // Header minimalista
            _buildHeader(),
            
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: isSmallScreen ? 16 : 24,
                ),
                child: Column(
                  children: [
                    // Código principal
                    _buildCodeSection(isSmallScreen),
                    
                    SizedBox(height: isSmallScreen ? 20 : 32),
                    
                    // Timer
                    _buildTimer(),
                    
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    
                    // Informações resumidas
                    _buildInfoSection(isSmallScreen),
                    
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    
                    // Instruções resumidas
                    _buildInstructionsSection(isSmallScreen),
                    
                    // Espaço extra para garantir que o botão seja visível
                    SizedBox(height: isSmallScreen ? 20 : 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botão voltar
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          
          const SizedBox(width: 16),
          
          // Título
          Text(
            'Pulse Key',
            style: AppTheme.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Código principal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _currentCode,
                  style: AppTheme.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 36 : 48,
                    letterSpacing: isSmallScreen ? 6 : 8,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_isSendingCode) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: isSmallScreen ? 16 : 20,
                  height: isSmallScreen ? 16 : 20,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Botão copiar
          GestureDetector(
            onTap: () => _copyCode(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 24, 
                vertical: isSmallScreen ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Text(
                    'Copiar',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _timeRemaining < 30 
            ? Colors.red.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _timeRemaining < 30 
              ? Colors.red.withOpacity(0.5)
              : Colors.orange.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: _timeRemaining < 30 ? Colors.red : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Expira em: ${_formatTime(_timeRemaining)}',
            style: AppTheme.titleMedium.copyWith(
              color: _timeRemaining < 30 ? Colors.red : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.8),
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Informações',
                style: AppTheme.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          _buildInfoItem(
            Icons.timer,
            'Válido por 2 minutos',
            'Código expira automaticamente',
            isSmallScreen,
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          _buildInfoItem(
            Icons.security,
            'Acesso seguro',
            'Logs de acesso registrados',
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: isSmallScreen ? 14 : 16,
        ),
        SizedBox(width: isSmallScreen ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildInstructionsSection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Colors.white.withOpacity(0.8),
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Como usar',
                style: AppTheme.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          _buildInstructionStep(
            '1',
            'Compartilhe o código com seu médico',
            isSmallScreen,
          ),
          
          SizedBox(height: isSmallScreen ? 6 : 8),
          
          _buildInstructionStep(
            '2',
            'Médico insere o código na plataforma',
            isSmallScreen,
          ),
          
          SizedBox(height: isSmallScreen ? 6 : 8),
          
          _buildInstructionStep(
            '3',
            'Acesso temporário aos seus dados',
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 20 : 24,
          height: isSmallScreen ? 20 : 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: const Color(0xFF00324A),
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 10 : 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

