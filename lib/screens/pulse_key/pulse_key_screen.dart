import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class PulseKeyScreen extends StatefulWidget {
  const PulseKeyScreen({super.key});

  @override
  State<PulseKeyScreen> createState() => _PulseKeyScreenState();
}

class _PulseKeyScreenState extends State<PulseKeyScreen> {
  String _currentCode = '123456';
  int _timeRemaining = 120; // 2 minutos em segundos
  bool _isActive = true;
  DateTime? _lastCodeGeneration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCode();
    _startTimer();
  }

  void _initializeCode() {
    // Gera código baseado no timestamp atual para manter consistência
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    _currentCode = (100000 + (timestamp % 900000)).toString();
    _lastCodeGeneration = now;
    
    // Calcula tempo restante baseado no timestamp
    final secondsSinceGeneration = (now.millisecondsSinceEpoch - timestamp) ~/ 1000;
    _timeRemaining = 120 - (secondsSinceGeneration % 120);
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

  void _generateNewCode() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    setState(() {
      _currentCode = (100000 + (timestamp % 900000)).toString();
      _lastCodeGeneration = now;
    });
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Código principal
                    _buildCodeSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Timer
                    _buildTimer(),
                    
                    const SizedBox(height: 40),
                    
                    // Informações resumidas
                    _buildInfoSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Instruções resumidas
                    _buildInstructionsSection(),
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

  Widget _buildCodeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
          Text(
            _currentCode,
            style: AppTheme.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
              letterSpacing: 8,
              fontFamily: 'monospace',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botão copiar
          GestureDetector(
            onTap: () => _copyCode(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Copiar',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informações',
                style: AppTheme.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoItem(
            Icons.timer,
            'Válido por 2 minutos',
            'Código expira automaticamente',
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            Icons.security,
            'Acesso seguro',
            'Logs de acesso registrados',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Como usar',
                style: AppTheme.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInstructionStep(
            '1',
            'Compartilhe o código com seu médico',
          ),
          
          const SizedBox(height: 8),
          
          _buildInstructionStep(
            '2',
            'Médico insere o código na plataforma',
          ),
          
          const SizedBox(height: 8),
          
          _buildInstructionStep(
            '3',
            'Acesso temporário aos seus dados',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF00324A),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
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
