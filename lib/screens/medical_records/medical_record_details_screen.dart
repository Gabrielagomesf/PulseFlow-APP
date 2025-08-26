import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class MedicalRecordDetailsScreen extends StatelessWidget {
  const MedicalRecordDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String motivo = args?['titulo'] ?? '';
    final String data = args?['data'] ?? '';
    final String especialidade = args?['categoria'] ?? '';
    final String medico = args?['medico'] ?? '';
    final String registro = args?['registro'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Visualizar Registro Clínico',
          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E9F2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MOTIVO DA CONSULTA', style: AppTheme.bodySmall.copyWith(color: const Color(0xFF1C4A7D), fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(
                        motivo,
                        style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _infoRow('DATA DO ATENDIMENTO', data, Icons.event),
                      const SizedBox(height: 12),
                      _infoRow('ESPECIALIDADE', especialidade, Icons.local_hospital_outlined),
                      const SizedBox(height: 12),
                      _infoRow('MÉDICO RESPONSÁVEL', medico, Icons.badge_outlined),
                      const SizedBox(height: 20),
                      Text('REGISTRO CLÍNICO', style: AppTheme.bodySmall.copyWith(color: const Color(0xFF1C4A7D), fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F8FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          registro.isEmpty ? 'Sem texto disponível para este registro.' : registro,
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _actionButton(Icons.delete_outline, 'Excluir Anotação', Colors.red.shade50, Colors.red.shade400),
                    _actionButton(Icons.picture_as_pdf_outlined, 'Salvar PDF', const Color(0xFFE3F2FD), const Color(0xFF1E88E5)),
                    _actionButton(Icons.print_outlined, 'Imprimir Registro', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1C4A7D)),
          const SizedBox(width: 12),
          Text(label, style: AppTheme.bodySmall.copyWith(color: const Color(0xFF1C4A7D), fontWeight: FontWeight.w800)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color bg, Color fg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.bodyMedium.copyWith(color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}


