import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class HistorySelectionScreen extends StatefulWidget {
  const HistorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<HistorySelectionScreen> createState() => _HistorySelectionScreenState();
}

class _HistorySelectionScreenState extends State<HistorySelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00324A),
      body: Column(
        children: [
          // Header
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título da seção
                      Text(
                        'Históricos',
                        style: AppTheme.titleLarge.copyWith(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha o histórico que deseja visualizar',
                        style: AppTheme.bodyMedium.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Lista de históricos
                      _buildHistoryList(),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Botão de voltar
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          
          // Logo
          _buildPulseFlowLogo(),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPulseFlowLogo() {
    return Container(
      width: 140,
      height: 45,
      child: Image.asset(
        'assets/images/PulseNegativo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Center(
              child: Text(
                'PulseFlow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Lista de históricos
  Widget _buildHistoryList() {
    return Column(
      children: [
        _buildHistoryCard(
          icon: Icons.history_rounded,
          title: 'Histórico Geral',
          subtitle: 'Registros médicos completos',
          gradientColors: [
            const Color(0xFF00324A),
            const Color(0xFF004A6B),
          ],
          onPressed: () {
            HapticFeedback.mediumImpact();
            Get.toNamed(Routes.MEDICAL_RECORDS);
          },
        ),
        const SizedBox(height: 16),
        _buildHistoryCard(
          icon: Icons.event_available_rounded,
          title: 'Histórico de Eventos',
          subtitle: 'Consultas e procedimentos',
          gradientColors: [
            const Color(0xFF2563EB),
            const Color(0xFF3B82F6),
          ],
          onPressed: () {
            HapticFeedback.mediumImpact();
            Get.toNamed(Routes.EVENTO_CLINICO_HISTORY);
          },
        ),
        const SizedBox(height: 16),
        _buildHistoryCard(
          icon: Icons.restaurant_menu_rounded,
          title: 'Histórico de Gastrite',
          subtitle: 'Crises e sintomas relacionados',
          gradientColors: [
            const Color(0xFFDC2626),
            const Color(0xFFEF4444),
          ],
          onPressed: () {
            HapticFeedback.mediumImpact();
            Get.toNamed(Routes.CRISE_GASTRITE_HISTORY);
          },
        ),
        const SizedBox(height: 16),
        _buildHistoryCard(
          icon: Icons.timeline_rounded,
          title: 'Histórico Menstrual',
          subtitle: 'Ciclos e acompanhamento',
          gradientColors: [
            const Color(0xFFEC4899),
            const Color(0xFFF472B6),
          ],
          onPressed: () {
            HapticFeedback.mediumImpact();
            Get.toNamed(Routes.MENSTRUACAO_HISTORY);
          },
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: title,
      hint: 'Toque para acessar $title',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onPressed,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Ícone com fundo decorativo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Ícone de seta
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF00324A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Início', false, () {
            Get.offAllNamed('/home');
          }),
          _buildNavItem(Icons.grid_view, 'Históricos', true, () {}),
          _buildNavItem(Icons.add, 'Registro', false, () {
            Get.toNamed('/menu');
          }),
          _buildNavItem(Icons.vpn_key, 'Pulse Key', false, () {
            Get.toNamed('/pulse-key');
          }),
          _buildNavItem(Icons.person, 'Perfil', false, () {
            Get.toNamed('/profile');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

