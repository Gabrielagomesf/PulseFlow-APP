import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF00324A),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header section
              Expanded(
                flex: isSmallScreen ? 1 : 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isSmallScreen ? 5 : 8),
                    // Logo
                    Image.asset(
                      'assets/images/pulseflow2.png',
                      width: isSmallScreen ? 70 : isMediumScreen ? 90 : isLargeScreen ? 110 : 130,
                      height: isSmallScreen ? 70 : isMediumScreen ? 90 : isLargeScreen ? 110 : 130,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Text(
                      'Termos de Uso',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : isMediumScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 30),
                      child: Text(
                        'PulseFlow - Plataforma de Saúde Digital',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 5 : 8),
                  ],
                ),
              ),
              
              // Content section
              Expanded(
                flex: isSmallScreen ? 6 : 7,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: isSmallScreen ? 10 : isMediumScreen ? 15 : isLargeScreen ? 20 : 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header do container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 16 : 20,
                          horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: const Color(0xFF00324A),
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Termos de Uso e Privacidade',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : isMediumScreen ? 20 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00324A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48), // Espaço para balancear o layout
                          ],
                        ),
                      ),
                      // Conteúdo dos termos
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                            0,
                            isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                            isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                          ),
                          child: _buildTermsContent(isSmallScreen, isMediumScreen, isLargeScreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsContent(bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          title: '1. Sobre o PulseFlow',
          content: 'O PulseFlow é uma plataforma digital focada na área da saúde, desenvolvida para facilitar a interação segura entre médicos e pacientes. Nossa aplicação oferece funcionalidades como autenticação em dois fatores, visualização de prontuários médicos, anexos de exames e comunicação protegida entre profissionais da saúde e seus pacientes.',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        _buildSection(
          title: '2. Aceitação dos Termos',
          content: 'Ao utilizar o PulseFlow, você concorda em cumprir e estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não deve utilizar nossa plataforma.',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        _buildSection(
          title: '3. Uso da Plataforma',
          content: 'O PulseFlow destina-se exclusivamente a fins médicos e de saúde. Os usuários devem:\n\n• Fornecer informações verdadeiras e precisas\n• Manter a confidencialidade de suas credenciais de acesso\n• Utilizar a plataforma de forma ética e responsável\n• Respeitar a privacidade de outros usuários\n• Não compartilhar informações médicas sem autorização',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        _buildSection(
          title: '4. Proteção de Dados',
          content: 'Comprometemo-nos a proteger seus dados pessoais e informações médicas de acordo com a Lei Geral de Proteção de Dados (LGPD) e as melhores práticas de segurança. Implementamos medidas técnicas e organizacionais para garantir a segurança e confidencialidade de suas informações.',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        _buildSection(
          title: '5. Responsabilidades do Usuário',
          content: 'Você é responsável por:\n\n• Manter a segurança de sua conta e senha\n• Informar-nos imediatamente sobre qualquer uso não autorizado\n• Usar a plataforma apenas para fins legítimos\n• Não tentar acessar sistemas ou dados de outros usuários\n• Cumprir todas as leis e regulamentações aplicáveis',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        _buildSection(
          title: '6. Limitação de Responsabilidade',
          content: 'O PulseFlow é fornecido "como está". Não garantimos que a plataforma estará sempre disponível ou livre de erros. Nossa responsabilidade é limitada ao máximo permitido por lei.',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        _buildSection(
          title: '7. Modificações',
          content: 'Reservamo-nos o direito de modificar estes termos a qualquer momento. As alterações entrarão em vigor imediatamente após a publicação. O uso continuado da plataforma constitui aceitação dos novos termos.',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        _buildSection(
          title: '8. Contato',
          content: 'Para dúvidas sobre estes termos ou sobre o PulseFlow, entre em contato conosco através dos canais oficiais da plataforma.',
          isSmallScreen: isSmallScreen,
          isMediumScreen: isMediumScreen,
          isLargeScreen: isLargeScreen,
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Botão de aceitar
        Container(
          width: double.infinity,
          height: isSmallScreen ? 48 : isMediumScreen ? 52 : isLargeScreen ? 56 : 60,
          decoration: BoxDecoration(
            color: const Color(0xFF00324A),
            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00324A).withValues(alpha: 0.3),
                blurRadius: isSmallScreen ? 10 : isMediumScreen ? 12 : isLargeScreen ? 15 : 18,
                offset: Offset(0, isSmallScreen ? 5 : isMediumScreen ? 6 : isLargeScreen ? 8 : 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                vertical: isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22),
                SizedBox(width: isSmallScreen ? 8 : isMediumScreen ? 10 : isLargeScreen ? 12 : 14),
                Text(
                  'Entendi os Termos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 15 : isMediumScreen ? 16 : isLargeScreen ? 17 : 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isLargeScreen,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00324A).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : isMediumScreen ? 17 : isLargeScreen ? 18 : 19,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00324A),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            content,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 