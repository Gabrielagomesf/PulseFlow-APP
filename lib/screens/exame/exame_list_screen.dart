import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../models/exame.dart';
import '../login/paciente_controller.dart';
import 'exame_controller.dart';
import '../../theme/app_theme.dart';

class ExameListScreen extends StatefulWidget {
  const ExameListScreen({super.key});

  @override
  State<ExameListScreen> createState() => _ExameListScreenState();
}

class _ExameListScreenState extends State<ExameListScreen> {
  final ExameController _controller = Get.put(ExameController());
  final PacienteController _paciente = Get.find<PacienteController>();

  @override
  void initState() {
    super.initState();
    _controller.carregarExames(_paciente.pacienteId.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      appBar: AppBar(
        title: const Text('Meus Exames'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          Expanded(
            child: Obx(() {
              final List<Exame> exames = _controller.examesFiltrados.isNotEmpty
                  ? _controller.examesFiltrados
                  : _controller.exames;
              if (exames.isEmpty) {
                return const Center(child: Text('Nenhum exame anexado'));
              }
              return ListView.separated(
                itemCount: exames.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F2)),
                itemBuilder: (context, index) {
                  final e = exames[index];
                  return ListTile(
                    leading: Icon(_iconForPath(e.filePath), color: AppTheme.primaryBlue),
                    title: Text(
                      e.nome,
                      style: AppTheme.bodyLarge.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${e.categoria} • ${_formatDate(e.data)}',
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    tileColor: Colors.white,
                    onTap: () async {
                      await OpenFilex.open(e.filePath);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppTheme.error,
                      onPressed: () async {
                        if (e.id == null || e.id!.isEmpty) {
                          // Tenta excluir pelo objeto quando não há _id
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Excluir exame'),
                              content: Text('Deseja excluir "${e.nome}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            try {
                              await _controller.removerExameByObject(e);
                              Get.snackbar('Exame removido', 'O exame foi excluído com sucesso');
                            } catch (err) {
                              Get.snackbar('Erro', err.toString());
                            }
                          }
                          return;
                        }
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Excluir exame'),
                            content: Text('Deseja excluir "${e.nome}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          try {
                            await _controller.removerExame(e.id!);
                            Get.snackbar('Exame removido', 'O exame foi excluído com sucesso');
                          } catch (err) {
                            // fallback adicional: por objeto
                            try {
                              await _controller.removerExameByObject(e);
                              Get.snackbar('Exame removido', 'O exame foi excluído com sucesso');
                            } catch (err2) {
                              Get.snackbar('Erro', err2.toString());
                            }
                          }
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
  );
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final d2 = d.day.toString().padLeft(2, '0');
    return '$d2/$m/$y';
  }

  IconData _iconForPath(String p) {
    final lower = p.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.heic')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: AppTheme.bodySmall,
                  decoration: InputDecoration(
                    labelText: 'Nome do exame',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    labelStyle: AppTheme.bodySmall,
                    floatingLabelStyle: AppTheme.bodySmall,
                  ),
                  onChanged: (v) => _controller.filtroNome.value = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: AppTheme.bodySmall,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: const Icon(Icons.category_outlined),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    labelStyle: AppTheme.bodySmall,
                    floatingLabelStyle: AppTheme.bodySmall,
                  ),
                  onChanged: (v) => _controller.filtroCategoria.value = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _controller.filtroInicio.value ?? now,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) {
                      _controller.filtroInicio.value = picked;
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Obx(() {
                    final d = _controller.filtroInicio.value;
                    return Text(d == null ? 'Data início' : _formatDate(d));
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _controller.filtroFim.value ?? now,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) {
                      _controller.filtroFim.value = picked;
                    }
                  },
                  icon: const Icon(Icons.event),
                  label: Obx(() {
                    final d = _controller.filtroFim.value;
                    return Text(d == null ? 'Data fim' : _formatDate(d));
                  }),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Limpar filtros',
                onPressed: () {
                  _controller.filtroNome.value = '';
                  _controller.filtroCategoria.value = '';
                  _controller.filtroInicio.value = null;
                  _controller.filtroFim.value = null;
                },
                icon: const Icon(Icons.clear_all),
              )
            ],
          ),
        ],
      ),
    );
  }
}


