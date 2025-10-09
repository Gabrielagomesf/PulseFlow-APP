import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../enxaqueca/enxaqueca_screen.dart';
import '../diabetes/diabetes_screen.dart';
import '../login/paciente_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/bp_menu_icon.dart';
import '../../widgets/common/hormonal_icon.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pacienteController = Get.find<PacienteController>();

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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção Dados de Saúde
                    _buildSectionHeader('Dados de Saúde'),
                    const SizedBox(height: 16),
                    _buildHealthDataSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Seção Registros de Saúde
                    _buildSectionHeader('Registros de Saúde'),
                    const SizedBox(height: 16),
                    _buildHealthRecordsGrid(pacienteController),
                    
                    const SizedBox(height: 32),
                    
                    // Seção Históricos
                    _buildSectionHeader('Históricos'),
                    const SizedBox(height: 16),
                    _buildHistoryGrid(),
                    
                    const SizedBox(height: 24),
                  ],
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
          
          // Título do menu
          const Text(
            'Menu Principal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          // Fallback caso a imagem não seja encontrada
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
          _buildNavItem(Icons.grid_view, 'Históricos', false, () {
            Get.toNamed('/medical-records');
          }),
          _buildNavItem(Icons.add, 'Registro', true, () {}),
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
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cabeçalho de seção
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  // Grid de registros de saúde
  Widget _buildHealthRecordsGrid(PacienteController pacienteController) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMenuButton(
          icon: Icons.attach_file,
          title: 'Exames\n(Anexos)',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.EXAME_UPLOAD);
          },
        ),
        _buildMenuButton(
          icon: Icons.psychology,
          title: 'Enxaqueca',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.to(() => EnxaquecaScreen(
              pacienteId: pacienteController.pacienteId.value,
            ));
          },
        ),
        _buildMenuButton(
          icon: Icons.bloodtype,
          title: 'Diabetes',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.to(() => DiabetesScreen(
              pacienteId: pacienteController.pacienteId.value,
            ));
          },
        ),
        _buildMenuButtonCustomIcon(
          icon: const BpMenuIcon(size: 40, color: Colors.white),
          title: 'Pressão\nArterial',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.PRESSAO);
          },
        ),
        _buildMenuButton(
          icon: Icons.sick,
          title: 'Crise de\nGastrite',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.CRISE_GASTRITE_FORM);
          },
        ),
        _buildMenuButton(
          icon: Icons.event_note,
          title: 'Evento\nClínico',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.EVENTO_CLINICO_FORM);
          },
        ),
        _buildMenuButtonCustomIcon(
          icon: const HormonalIcon(size: 40, color: Colors.white),
          title: 'Hormonal',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.HORMONAL);
          },
        ),
        _buildMenuButton(
          icon: Icons.favorite,
          title: 'Ciclo\nMenstrual',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.MENSTRUACAO_FORM);
          },
        ),
      ],
    );
  }

  // Grid de históricos
  Widget _buildHistoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMenuButton(
          icon: Icons.history,
          title: 'Histórico\nGeral',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed('/medical-records');
          },
        ),
        _buildMenuButton(
          icon: Icons.event_available,
          title: 'Histórico\nEventos',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.EVENTO_CLINICO_HISTORY);
          },
        ),
        _buildMenuButton(
          icon: Icons.restaurant,
          title: 'Histórico\nGastrite',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.CRISE_GASTRITE_HISTORY);
          },
        ),
        _buildMenuButton(
          icon: Icons.timeline,
          title: 'Histórico\nMenstrual',
          color: const Color(0xFF00324A),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(Routes.MENSTRUACAO_HISTORY);
          },
        ),
      ],
    );
  }

  // Grid de dispositivos - removido (smartwatch e configurações)

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: title,
      hint: 'Toque para acessar $title',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildMenuButtonCustomIcon({
    required Widget icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: title,
      hint: 'Toque para acessar $title',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  // Seção de dados de saúde
  Widget _buildHealthDataSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF059669).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: const Color(0xFF059669),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dados Sincronizados',
                style: AppTheme.bodyLarge.copyWith(
                  color: const Color(0xFF059669),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Grid de dados de saúde
          Row(
            children: [
              Expanded(
                child: _buildHealthDataCard(
                  icon: Icons.favorite,
                  label: 'Frequência Cardíaca',
                  value: '72 bpm',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthDataCard(
                  icon: Icons.bedtime,
                  label: 'Qualidade do Sono',
                  value: '85%',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthDataCard(
                  icon: Icons.directions_walk,
                  label: 'Passos Diários',
                  value: '8500',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botões de ação
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/health-history');
                  },
                  icon: const Icon(Icons.analytics, size: 18),
                  label: const Text('Ver Histórico'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/profile');
                  },
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sincronizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7280),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card de dados de saúde
  Widget _buildHealthDataCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
