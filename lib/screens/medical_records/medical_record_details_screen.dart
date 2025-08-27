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
    final String status = args?['status'] ?? 'Atendimento Realizado';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
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
        child: LayoutBuilder(
          builder: (context, viewport) {
            final bool isPhone = viewport.maxWidth < 420;
            final EdgeInsets pagePadding = EdgeInsets.fromLTRB(isPhone ? 16 : 24, 16, isPhone ? 16 : 24, 28);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: ListView(
                  padding: pagePadding,
                  children: [
                    _DetailsCard(
                      motivo: motivo,
                      status: status,
                      data: data,
                      especialidade: especialidade,
                      medico: medico,
                      registro: registro,
                      compact: isPhone,
                    ),
                    const SizedBox(height: 18),
                    const _ActionsBar(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String motivo;
  final String status;
  final bool compact;
  const _HeaderCard({required this.motivo, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(colors: [Color(0xFF1CB5E0), Color(0xFF000046)]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 20, compact ? 14 : 18, compact ? 14 : 20, compact ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('MOTIVO DA CONSULTA', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.bodySmall.copyWith(color: const Color(0xFF1C4A7D), fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: _StatusChip(text: status)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(motivo, style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w800), maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String motivo;
  final String status;
  final String data;
  final String especialidade;
  final String medico;
  final String registro;
  final bool compact;

  const _DetailsCard({
    required this.motivo,
    required this.status,
    required this.data,
    required this.especialidade,
    required this.medico,
    required this.registro,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(motivo: motivo, status: status, compact: compact),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 20, compact ? 10 : 14, compact ? 14 : 20, 20),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool twoColumns = constraints.maxWidth >= 880;
                    final tiles = [
                      _InfoTile(icon: Icons.event, label: 'DATA DO ATENDIMENTO', value: data),
                      _InfoTile(icon: Icons.local_hospital_outlined, label: 'ESPECIALIDADE', value: especialidade),
                      _InfoTile(icon: Icons.segment_outlined, label: 'TIPO DA CONSULTA', value: 'Tipo não informado'),
                      _InfoTile(icon: Icons.badge_outlined, label: 'MÉDICO RESPONSÁVEL', value: medico),
                    ];
                    if (!twoColumns) {
                      return Column(
                        children: tiles
                            .map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: t))
                            .toList(),
                      );
                    }
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.8,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: tiles,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _RecordTextBox(texto: registro),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  const _StatusChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(minWidth: 0, maxWidth: 220),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB2F5EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodySmall.copyWith(color: const Color(0xFF0F9D58), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E88E5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodySmall.copyWith(color: const Color(0xFF1C4A7D), fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(value, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTextBox extends StatelessWidget {
  final String texto;
  const _RecordTextBox({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REGISTRO CLÍNICO', style: AppTheme.bodySmall.copyWith(color: const Color(0xFF1C4A7D), fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              (texto.isEmpty ? 'Sem texto disponível para este registro.' : texto),
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final Color fg; final Color bg;
  const _ActionButton({required this.icon, required this.label, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: fg.withOpacity(0.25)),
          ),
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
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttons = const [
          _ActionButton(icon: Icons.delete_outline, label: 'Excluir Anotação', fg: Color(0xFFE53935), bg: Color(0xFFFFEBEE)),
          _ActionButton(icon: Icons.picture_as_pdf_outlined, label: 'Salvar PDF', fg: Color(0xFF1E88E5), bg: Color(0xFFE3F2FD)),
          _ActionButton(icon: Icons.print_outlined, label: 'Imprimir Registro', fg: Color(0xFF2E7D32), bg: Color(0xFFE8F5E9)),
        ];
        if (constraints.maxWidth < 540) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final b in buttons) Padding(padding: const EdgeInsets.only(bottom: 10), child: b),
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              buttons[i],
              if (i != buttons.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}



