import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'medical_records_controller.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MedicalRecordsController());
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: controller.toggleSidebar,
          tooltip: 'Menu',
        ),
        title: Text(
          'Histórico De Registro Clínico',
          style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Obx(() => Row(
          children: [
            if (controller.isSidebarOpen.value)
              _Sidebar(name: controller.patient.value?.name),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isLoading.value)
                      const LinearProgressIndicator(minHeight: 2),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final bool stacked = constraints.maxWidth < 700;
                            if (stacked) {
                              return Column(
                                children: [
                                  _searchField(
                                    hint: 'Buscar por especialidade',
                                    prefixIcon: Icons.category_outlined,
                                    suffixIcon: Icons.keyboard_arrow_down,
                                    onTap: () {},
                                  ),
                                  const SizedBox(height: 12),
                                  _searchField(
                                    hint: 'Buscar por médico responsável',
                                    prefixIcon: Icons.search,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: _searchField(
                                    hint: 'Buscar por especialidade',
                                    prefixIcon: Icons.category_outlined,
                                    suffixIcon: Icons.keyboard_arrow_down,
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _searchField(
                                    hint: 'Buscar por médico responsável',
                                    prefixIcon: Icons.search,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final list = controller.notes;
                        if (list.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhum registro clínico encontrado para este paciente.',
                              style: AppTheme.bodyMedium,
                            ),
                          );
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final double maxWidth = constraints.maxWidth.clamp(0, 1400).toDouble();
                            int columns = 1;
                            if (maxWidth >= 1100) {
                              columns = 3;
                            } else if (maxWidth >= 800) {
                              columns = 2;
                            }
                            const spacing = 16.0;
                            final double cardWidth = (maxWidth - spacing * (columns - 1)) / columns;

                            // Identificar o registro mais antigo
                            DateTime? oldestDate;
                            if (list.isNotEmpty) {
                              oldestDate = list
                                  .map((n) => n.data)
                                  .reduce((a, b) => a.isBefore(b) ? a : b);
                            }

                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children: list.map((n) {
                                      final d = n.data;
                                      final dd = d.day.toString().padLeft(2, '0');
                                      final mm = d.month.toString().padLeft(2, '0');
                                      final yy = d.year.toString();
                                      final isOldest = oldestDate != null &&
                                          d.year == oldestDate!.year &&
                                          d.month == oldestDate!.month &&
                                          d.day == oldestDate!.day;
                                      return _recordCard(
                                        width: cardWidth,
                                        titulo: n.titulo,
                                        data: '$dd/$mm/$yy',
                                        categoria: n.categoria,
                                        medico: n.medico,
                                        isOldest: isOldest,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _searchField({
    required String hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TextField(
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF6F8FA),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppTheme.textSecondary) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _recordCard({
    double? width,
    required String titulo,
    required String data,
    required String categoria,
    required String medico,
    bool isOldest = false,
  }) {
    return SizedBox(
      width: width ?? 360,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE5E9F2)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isOldest) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C4A7D).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1C4A7D).withOpacity(0.25)),
                  ),
                  child: const Text(
                    'Registro mais antigo',
                    style: TextStyle(
                      color: Color(0xFF1C4A7D),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              _labelValue('Motivo da Consulta', titulo, color: const Color(0xFF002A42)),
              const SizedBox(height: 12),
              _labelValue('Data', data, color: const Color(0xFF002A42)),
              const SizedBox(height: 8),
              _labelValue('Especialidade', categoria, color: const Color(0xFF002A42)),
              const SizedBox(height: 8),
              _labelValue('Médico Responsável', medico, color: const Color(0xFF002A42)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                  onPressed: () {
                    Get.toNamed(
                      Routes.MEDICAL_RECORD_DETAILS,
                      arguments: {
                        'titulo': titulo,
                        'data': data,
                        'categoria': categoria,
                        'medico': medico,
                        'registro': titulo,
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF002A42),
                    side: const BorderSide(color: Color(0xFF002A42)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size.fromHeight(46),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                        return const Color(0xFF002A42);
                      }
                      return Colors.transparent;
                    }),
                    overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                    side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
                      final color = states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)
                          ? const Color(0xFF002A42)
                          : const Color(0xFF002A42);
                      return BorderSide(color: color, width: 1.25);
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                        return Colors.white;
                      }
                      return const Color(0xFF002A42);
                    }),
                  ),
                  child: Text(
                    'Visualizar Registro Clínico',
                    style: AppTheme.titleSmall.copyWith(
                      color: const Color(0xFF002A42),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value, {Color color = const Color(0xFF1C4A7D)}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label',
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ':  ', style: AppTheme.bodyMedium),
          TextSpan(
            text: value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF22C55E),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}


class _Sidebar extends StatelessWidget {
  final String? name;
  const _Sidebar({this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      color: const Color(0xFF072C3E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              name != null ? 'Dra. ${name!}' : 'Paciente',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SidebarItem(icon: Icons.person_outline, label: 'Perfil Paciente'),
          _SidebarItem(icon: Icons.description_outlined, label: 'Registro Clínico', isActive: true),
          _SidebarItem(icon: Icons.attachment_outlined, label: 'Anexo de Exames'),
          _SidebarItem(icon: Icons.event_note_outlined, label: 'Eventos Clínicos'),
          _SidebarItem(icon: Icons.bar_chart_outlined, label: 'Relatórios e Dashboards'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () async {
                try {
                  await AuthService.instance.logout();
                } catch (_) {}
                Get.offAllNamed(Routes.LOGIN);
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text('Sair', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const _SidebarItem({required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF093A52) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        dense: true,
        horizontalTitleGap: 8,
        onTap: () {},
      ),
    );
  }
}


