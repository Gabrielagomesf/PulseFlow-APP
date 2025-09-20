import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/background_wave.dart';

class PulseKeyScreen extends StatelessWidget {
  const PulseKeyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00324A), // Cor de fundo azul para ocupar toda a tela
      body: Column(
        children: [
          // Header com perfil - sem SafeArea para ocupar toda a área superior
          _buildHeader(),
          
          // Conteúdo principal
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção do código
                    _buildCodeSection(),
                    const SizedBox(height: 24),
                    
                    // Seção de instruções
                    _buildInstructionsSection(),
                    const SizedBox(height: 24),
                    
                    // Seção de informações
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16, // Adiciona padding da status bar
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF00324A), // Nova cor azul
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Top row com logo centralizado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo do PulseFlow
              _buildPulseFlowLogo(),
            ],
          ),
          const SizedBox(height: 20),
          
          // Título da seção
          Row(
            children: [
              // Botão de voltar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Título
              Expanded(
                child: Text(
                  'Pulse Key',
                  style: AppTheme.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulseFlowLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone do coração
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.favorite,
              color: Color(0xFFE53935),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Texto do logo
          Text(
            'PulseFlow',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícone
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.vpn_key,
              color: Color(0xFF1E3A8A),
              size: 40,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Código
          Text(
            '123456',
            style: AppTheme.titleLarge.copyWith(
              color: const Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
              fontSize: 36,
              letterSpacing: 8,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Expira em: 2:00',
              style: AppTheme.titleSmall.copyWith(
                color: const Color(0xFF059669),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF1E3A8A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Como usar',
                style: AppTheme.titleLarge.copyWith(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Instruções
          _buildInstructionItem(
            '1',
            'Compartilhe este código com seu médico',
            Icons.share,
          ),
          
          const SizedBox(height: 16),
          
          _buildInstructionItem(
            '2',
            'O médico inserirá o código na plataforma',
            Icons.medical_services,
          ),
          
          const SizedBox(height: 16),
          
          _buildInstructionItem(
            '3',
            'Acesso será concedido aos seus dados',
            Icons.security,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E3A8A),
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Segurança',
                style: AppTheme.titleLarge.copyWith(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Informações de segurança
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF059669).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Código válido por 2 minutos',
                        style: AppTheme.bodyMedium.copyWith(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Acesso limitado aos dados necessários',
                        style: AppTheme.bodyMedium.copyWith(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Logs de acesso registrados',
                        style: AppTheme.bodyMedium.copyWith(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
