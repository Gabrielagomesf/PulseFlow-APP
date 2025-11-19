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
import '../../widgets/pulse_bottom_navigation.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pacienteController = Get.find<PacienteController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.blueSystemOverlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFF00324A),
        body: Column(
          children: [
            _buildHeader(),
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
                      _buildSectionHeader('Dados de Saúde'),
                      const SizedBox(height: 16),
                      _buildHealthDataSection(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Registros de Saúde'),
                      const SizedBox(height: 16),
                      _buildHealthRecordsList(pacienteController),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const PulseBottomNavigation(activeItem: PulseNavItem.menu),
      ),
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
      decoration: const BoxDecoration(
        color: Color(0xFF00324A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              _buildPulseFlowLogo(),
              IconButton(
                icon: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Get.toNamed(Routes.NOTIFICATIONS);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
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
    return SizedBox(
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

  Widget _buildHealthRecordsList(PacienteController pacienteController) {
    final cards = [
      _RecordCardData(
        icon: Icons.attach_file,
        title: 'Exames anexados',
        subtitle: 'Arquivos e resultados clínicos',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.EXAME_UPLOAD);
        },
      ),
      _RecordCardData(
        icon: Icons.psychology,
        title: 'Controle de Enxaqueca',
        subtitle: 'Crises, sintomas e tratamentos',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(() => EnxaquecaScreen(
                pacienteId: pacienteController.pacienteId.value,
              ));
        },
      ),
      _RecordCardData(
        icon: Icons.bloodtype,
        title: 'Monitoramento da Diabetes',
        subtitle: 'Glicemia, medicamentos e hábitos',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(() => DiabetesScreen(
                pacienteId: pacienteController.pacienteId.value,
              ));
        },
      ),
      _RecordCardData(
        customIcon: const BpMenuIcon(size: 40, color: Colors.white),
        title: 'Pressão arterial',
        subtitle: 'Registros de aferições e alertas',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.PRESSAO);
        },
      ),
      _RecordCardData(
        icon: Icons.sick,
        title: 'Crises de gastrite',
        subtitle: 'Sintomas, dieta e medicamentos',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.CRISE_GASTRITE_FORM);
        },
      ),
      _RecordCardData(
        icon: Icons.event_note,
        title: 'Eventos clínicos',
        subtitle: 'Consultas, exames e procedimentos',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.EVENTO_CLINICO_FORM);
        },
      ),
      _RecordCardData(
        customIcon: const HormonalIcon(size: 40, color: Colors.white),
        title: 'Acompanhamento hormonal',
        subtitle: 'Exames, hormônios e tendências',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.HORMONAL);
        },
      ),
      _RecordCardData(
        icon: Icons.favorite,
        title: 'Ciclo menstrual',
        subtitle: 'Calendário e sintomas do ciclo',
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(Routes.MENSTRUACAO_FORM);
        },
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          _RecordCard(data: cards[i]),
          if (i < cards.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCBD5F5).withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCBD5F5).withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: icon,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
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

class _RecordCardData {
  final IconData? icon;
  final Widget? customIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RecordCardData({
    this.icon,
    this.customIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : assert(icon != null || customIcon != null);
}

class _RecordCard extends StatelessWidget {
  final _RecordCardData data;

  const _RecordCard({required this.data});

  @override
  Widget build(BuildContext context) {
    const gradientColors = [Color(0xFF00324A), Color(0xFF004A6B)];
    return Semantics(
      button: true,
      label: data.title,
      hint: 'Toque para acessar ${data.title}',
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.25),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: data.onTap,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
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
                    child: Center(
                      child: data.customIcon ??
                          Icon(
                            data.icon,
                            size: 32,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
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
}

