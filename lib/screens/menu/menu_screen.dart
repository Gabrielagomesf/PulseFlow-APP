import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../enxaqueca/enxaqueca_screen.dart';
import '../diabetes/diabetes_screen.dart';
import '../login/paciente_controller.dart';
import '../../routes/app_routes.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pacienteController = Get.find<PacienteController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2541),
        elevation: 0,
        title: const Text('Menu Principal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.1,
          children: [
            // Botão Enxaqueca
            _buildMenuButton(
              icon: Icons.medical_services,
              title: 'Enxaqueca',
              color: const Color(0xFF1F4068),
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
              color: const Color(0xFF1F4068),
              onPressed: () {
                print('Clicou em Diabetes');
                Get.to(() => DiabetesScreen(
                  pacienteId: pacienteController.pacienteId.value,
                ));
              },
            ),

            // Botão Histórico
            _buildMenuButton(
              icon: Icons.history,
              title: 'Histórico',
              color: const Color(0xFF1F4068),
              onPressed: () {
                Get.toNamed('/medical-records');
                Get.snackbar('Em breve', 'Tela de histórico ainda não implementada');
              },
            ),

            // Botão Evento Clínico
            _buildMenuButton(
              icon: Icons.event_note,
              title: 'Evento Clínico',
              color: const Color(0xFF1F4068),
              onPressed: () {
                Get.toNamed(Routes.EVENTO_CLINICO_FORM);
              },
            ),

            // Botão Configurações
            _buildMenuButton(
              icon: Icons.settings,
              title: 'Configurações',
              color: const Color(0xFF1F4068),
              onPressed: () {
                Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento');
              },
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A506B)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: const Color(0xFF00C3B7),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
