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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final bool isPhone = viewport.maxWidth < 420;
                  final EdgeInsets pagePadding = EdgeInsets.fromLTRB(
                    isPhone ? 20 : 32, 
                    24, 
                    isPhone ? 20 : 32, 
                    32
                  );
                  
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Detalhes do Registro Clínico'),
                            const SizedBox(height: 24),
                            _buildMainInfoCard(motivo, status, data, especialidade, medico),
                            const SizedBox(height: 24),
                            _buildRecordSection(registro),
                            const SizedBox(height: 32),
                            _buildActionButtons(isPhone),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E3A8A),
                const Color(0xFF2563EB),
                const Color(0xFF3B82F6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Wave decoration at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  painter: WavePainter(),
                  size: const Size(double.infinity, 40),
                ),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registro Clínico',
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.titleLarge.copyWith(
        color: const Color(0xFF1E293B),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMainInfoCard(String motivo, String status, String data, String especialidade, String medico) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOTIVO DA CONSULTA',
                        style: AppTheme.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        motivo,
                        style: AppTheme.titleLarge.copyWith(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                _buildStatusChip(status),
              ],
            ),
          ),
          
          // Info fields
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                _buildInfoRow('Data do Atendimento', data, Icons.event_rounded),
                const SizedBox(height: 24),
                _buildInfoRow('Especialidade', especialidade, Icons.local_hospital_rounded),
                const SizedBox(height: 24),
                _buildInfoRow('Tipo da Consulta', 'Consulta Regular', Icons.category_rounded),
                const SizedBox(height: 24),
                _buildInfoRow('Médico Responsável', medico, Icons.person_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  value,
                  style: AppTheme.titleMedium.copyWith(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: AppTheme.bodySmall.copyWith(
              color: const Color(0xFF16A34A),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordSection(String registro) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              'REGISTRO CLÍNICO',
              style: AppTheme.bodySmall.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                registro.isEmpty ? 'Sem texto disponível para este registro.' : registro,
                style: AppTheme.bodyMedium.copyWith(
                  color: const Color(0xFF374151),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isPhone) {
    if (isPhone) {
      return Column(
        children: [
          _buildActionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Excluir Anotação',
            color: const Color(0xFFDC2626),
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Salvar PDF',
            color: const Color(0xFF1E3A8A),
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.print_rounded,
            label: 'Imprimir Registro',
            color: const Color(0xFF059669),
            onPressed: () {},
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Excluir Anotação',
            color: const Color(0xFFDC2626),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Salvar PDF',
            color: const Color(0xFF1E3A8A),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.print_rounded,
            label: 'Imprimir Registro',
            color: const Color(0xFF059669),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: color.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) return 4;
          if (states.contains(MaterialState.hovered)) return 2;
          return 0;
        }),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for wave decoration
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height);
    path.quadraticBezierTo(size.width * 0.75, size.height * 1.2, size.width, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



