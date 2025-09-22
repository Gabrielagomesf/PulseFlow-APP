import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../enxaqueca/enxaqueca_screen.dart';
import '../diabetes/diabetes_screen.dart';
import '../login/paciente_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  padding: const EdgeInsets.only(bottom: 24),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  children: [
                    // Botão Enxaqueca
                    _buildMenuButton(
                      icon: Icons.medical_services,
                      title: 'Enxaqueca',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        print('Clicou em Enxaqueca');
                        Get.to(() => EnxaquecaScreen(
                          pacienteId: pacienteController.pacienteId.value,
                        ));
                      },
                    ),

                    // Botão Diabetes
                    _buildMenuButton(
                      icon: Icons.monitor_heart,
                      title: 'Diabetes',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        print('Clicou em Diabetes');
                        Get.to(() => DiabetesScreen(
                          pacienteId: pacienteController.pacienteId.value,
                        ));
                      },
                    ),

                    // Botão Pressão Arterial
                    _buildMenuButton(
                      icon: Icons.bloodtype,
                      title: 'Pressão\nArterial',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.PRESSAO);
                      },
                    ),

                    // Botão Histórico
                    _buildMenuButton(
                      icon: Icons.history,
                      title: 'Histórico',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed('/medical-records');
                        Get.snackbar('Em breve', 'Tela de histórico ainda não implementada');
                      },
                    ),

                    // Botão Evento Clínico
                    _buildMenuButton(
                      icon: Icons.event_note,
                      title: 'Evento Clínico',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.EVENTO_CLINICO_FORM);
                      },
                    ),

                    // Botão Histórico de Eventos Clínicos
                    _buildMenuButton(
                      icon: Icons.history_rounded,
                      title: 'Histórico de\nEventos',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.EVENTO_CLINICO_HISTORY);
                      },
                    ),

                    // Botão Crise de Gastrite
                    _buildMenuButton(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Crise de\nGastrite',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.CRISE_GASTRITE_FORM);
                      },
                    ),

                    // Botão Histórico de Crises de Gastrite
                    _buildMenuButton(
                      icon: Icons.history_rounded,
                      title: 'Histórico\nGastrite',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.CRISE_GASTRITE_HISTORY);
                      },
                    ),

                    // Botão Ciclo Menstrual
                    _buildMenuButton(
                      icon: Icons.favorite_rounded,
                      title: 'Ciclo\nMenstrual',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.MENSTRUACAO_FORM);
                      },
                    ),

                    // Botão Histórico de Ciclos Menstruais
                    _buildMenuButton(
                      icon: Icons.history_rounded,
                      title: 'Histórico\nMenstrual',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.MENSTRUACAO_HISTORY);
                      },
                    ),

                    // Botão Smartwatch
                    _buildMenuButton(
                      icon: Icons.watch,
                      title: 'Smartwatch',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.toNamed(Routes.SMARTWATCH);
                      },
                    ),

                    // Botão Configurações
                    _buildMenuButton(
                      icon: Icons.settings,
                      title: 'Configurações',
                      color: const Color(0xFF00324A),
                      onPressed: () {
                        Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento');
                      },
                    ),
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
        color: Color(0xFF00324A), // Nova cor azul
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Início', false, () {
            Get.offAllNamed('/home');
          }),
          _buildNavItem(Icons.grid_view, 'Relatórios', false, () {
            Get.toNamed('/medical-records');
          }),
          _buildNavItem(Icons.add, 'Registro', true, () {}),
          _buildNavItem(Icons.vpn_key, 'Pulse Key', false, () {
            // TODO: Implementar tela Pulse Key
            Get.snackbar(
              'Em Breve',
              'Funcionalidade Pulse Key será implementada em breve!',
              backgroundColor: const Color(0xFF00324A), // Nova cor azul
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }),
          _buildNavItem(Icons.person, 'Perfil', false, () {
            // TODO: Implementar tela de perfil
            Get.snackbar(
              'Em Breve',
              'Tela de perfil será implementada em breve!',
              backgroundColor: const Color(0xFF00324A), // Nova cor azul
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
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
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 44,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
