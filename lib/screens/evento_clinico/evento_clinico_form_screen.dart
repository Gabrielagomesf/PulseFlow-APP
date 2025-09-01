import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/evento_clinico.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class EventoClinicoFormScreen extends StatefulWidget {
  const EventoClinicoFormScreen({super.key});

  @override
  State<EventoClinicoFormScreen> createState() => _EventoClinicoFormScreenState();
}

class _EventoClinicoFormScreenState extends State<EventoClinicoFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _especialidadeController = TextEditingController();
  final _alivioController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  DateTime _dataHora = DateTime.now();
  String? _selectedTipo;
  String? _selectedIntensity;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, String> _tiposEvento = {
    'Crise/Emergência': 'emergency',
    'Acompanhamento de Condição Crônica': 'chronic',
    'Episódio Psicológico ou Emocional': 'psychological',
    'Evento Relacionado à Medicação': 'medication',
  };

  final Map<String, String> _intensidades = {
    '0': 'Sem dor',
    '2': 'Dor leve (1-3)',
    '5': 'Dor moderada (4-6)',
    '8': 'Intensa (7-9)',
    '10': 'Insuportável 10',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final isPhone = constraints.maxWidth < 400;
            
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(isTablet),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : (isPhone ? 16 : 24),
                      vertical: 16,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildHeroSection(isTablet),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Resumo visual
                          if (_selectedTipo != null || _selectedIntensity != null)
                            _buildVisualSummary(isTablet),
                          
                          const SizedBox(height: 24),
                          
                          // Campos principais
                          _buildMainFields(isTablet, isPhone),
                          const SizedBox(height: 24),
                          
                          // Campos de data/hora e intensidade
                          _buildDateTimeIntensitySection(isTablet, isPhone),
                          const SizedBox(height: 24),
                          
                          // Descrição e medicação
                          _buildDescriptionSection(isTablet, isPhone),
                          const SizedBox(height: 32),
                          
                          // Botões de ação
                          _buildActionButtons(isTablet, isPhone),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 120 : 100,
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
                const Color(0xFF3B82F6),
                const Color(0xFF60A5FA),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: isTablet ? 48 : 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registro de Evento Clínico',
                    style: AppTheme.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildHeroSection(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF0F9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              size: isTablet ? 48 : 40,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Documente um evento clínico',
            style: AppTheme.titleLarge.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha os campos abaixo para registrar detalhes importantes sobre o evento.',
            style: AppTheme.bodyMedium.copyWith(
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSummary(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_rounded,
                color: const Color(0xFF1E3A8A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumo do Evento',
                style: AppTheme.titleMedium.copyWith(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (_selectedTipo != null)
                _buildSummaryChip(
                  icon: _getTipoIcon(_selectedTipo!),
                  label: _selectedTipo!,
                  color: _getTipoColor(_selectedTipo!),
                ),
              if (_selectedIntensity != null)
                _buildSummaryChip(
                  icon: Icons.monitor_heart_rounded,
                  label: _intensidades[_selectedIntensity!]!,
                  color: _getIntensityColor(_selectedIntensity!),
                ),
              _buildSummaryChip(
                icon: Icons.event_rounded,
                label: '${_dataHora.day.toString().padLeft(2, '0')}/${_dataHora.month.toString().padLeft(2, '0')} ${_dataHora.hour.toString().padLeft(2, '0')}:${_dataHora.minute.toString().padLeft(2, '0')}',
                color: const Color(0xFF059669),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFields(bool isTablet, bool isPhone) {
    return Column(
      children: [
        _buildFieldSection(
          title: 'Informações Básicas',
          icon: Icons.info_rounded,
          children: [
            _buildModernTextField(
              controller: _tituloController,
              label: 'Título do Evento',
              hint: 'Ex: Controle de epilepsia idiopática',
              icon: Icons.title_rounded,
              isRequired: true,
            ),
            const SizedBox(height: 20),
            if (isPhone) ...[
              _buildTipoSelector(),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: _especialidadeController,
                label: 'Especialidade',
                hint: 'Ex: Neurologia',
                icon: Icons.medical_services_rounded,
                isRequired: true,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildTipoSelector()),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildModernTextField(
                      controller: _especialidadeController,
                      label: 'Especialidade',
                      hint: 'Ex: Neurologia',
                      icon: Icons.medical_services_rounded,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeIntensitySection(bool isTablet, bool isPhone) {
    return _buildFieldSection(
      title: 'Intensidade e Data/Hora',
      icon: Icons.schedule_rounded,
      children: [
        if (isPhone) ...[
          _buildIntensitySelector(),
          const SizedBox(height: 20),
          _buildDateTimeSelector(),
        ] else ...[
          Row(
            children: [
              Expanded(child: _buildIntensitySelector()),
              const SizedBox(width: 20),
              Expanded(child: _buildDateTimeSelector()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionSection(bool isTablet, bool isPhone) {
    return _buildFieldSection(
      title: 'Descrição e Medicação',
      icon: Icons.description_rounded,
      children: [
        _buildModernTextField(
          controller: _descricaoController,
          label: 'Registro clínico / descrição',
          hint: 'Descreva detalhes do evento, sintomas observados, etc.',
          icon: Icons.edit_note_rounded,
          maxLines: 4,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildModernTextField(
          controller: _alivioController,
          label: 'Alívio / Medicação',
          hint: 'Descreva o tratamento aplicado, medicação, etc.',
          icon: Icons.medication_rounded,
          maxLines: 3,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildFieldSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1E3A8A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'Este campo é obrigatório';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF1E3A8A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTipoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tipo do evento',
              style: AppTheme.bodyMedium.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _openTipoMenu,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedTipo != null
                        ? _selectedTipo!
                        : 'Selecione o tipo',
                    style: AppTheme.bodyMedium.copyWith(
                      color: _selectedTipo != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Intensidade da dor',
              style: AppTheme.bodyMedium.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _openIntensityMenu,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.monitor_heart_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedIntensity != null
                        ? _intensidades[_selectedIntensity!]!
                        : 'Selecione a intensidade',
                    style: AppTheme.bodyMedium.copyWith(
                      color: _selectedIntensity != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Data e Hora',
              style: AppTheme.bodyMedium.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateTime,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_dataHora.day.toString().padLeft(2, '0')}/${_dataHora.month.toString().padLeft(2, '0')}/${_dataHora.year} ${_dataHora.hour.toString().padLeft(2, '0')}:${_dataHora.minute.toString().padLeft(2, '0')}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isTablet, bool isPhone) {
    return Row(
      children: [
        if (isPhone) ...[
          Expanded(
            child: _buildActionButton(
              text: 'Cancelar',
              icon: Icons.close_rounded,
              color: const Color(0xFF6B7280),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              text: 'Salvar',
              icon: Icons.save_rounded,
              color: const Color(0xFF1E3A8A),
              onPressed: _submit,
            ),
          ),
        ] else ...[
          Expanded(
            flex: 2,
            child: _buildActionButton(
              text: 'Cancelar',
              icon: Icons.close_rounded,
              color: const Color(0xFF6B7280),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: _buildActionButton(
              text: 'Salvar Evento Clínico',
              icon: Icons.save_rounded,
              color: const Color(0xFF1E3A8A),
              onPressed: _submit,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) return 8;
          if (states.contains(MaterialState.hovered)) return 4;
          return 0;
        }),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _openTipoMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Todos os tipos',
              style: AppTheme.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        ..._tiposEvento.keys.map((tipo) => PopupMenuItem<String>(
          value: tipo,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tipo,
                  style: AppTheme.bodyMedium.copyWith(
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (_selectedTipo == tipo)
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF1E3A8A),
                  size: 20,
                ),
            ],
          ),
        )),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedTipo = value;
        });
      }
    });
  }

  void _openIntensityMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Todas as intensidades',
              style: AppTheme.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        ..._intensidades.entries.map((entry) => PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (_selectedIntensity == entry.key)
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF1E3A8A),
                  size: 20,
                ),
            ],
          ),
        )),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedIntensity = value;
        });
      }
    });
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dataHora),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1E3A8A),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF1F2937),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _dataHora = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIntensity == null) {
      Get.snackbar(
        'Erro',
        'Selecione a intensidade da dor',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser?.id == null) {
        throw 'Usuário não autenticado';
      }

      final eventoClinico = EventoClinico(
        paciente: currentUser!.id!,
        titulo: _tituloController.text.trim(),
        dataHora: _dataHora,
        tipoEvento: _selectedTipo ?? 'Não especificado',
        especialidade: _especialidadeController.text.trim(),
        intensidadeDor: _selectedIntensity!,
        alivio: _alivioController.text.trim(),
        descricao: _descricaoController.text.trim(),
        sintomas: '', // Campo removido conforme solicitado
      );

      await DatabaseService().createEventoClinico(eventoClinico);
      
      Get.snackbar(
        'Sucesso',
        'Evento clínico registrado com sucesso!',
        backgroundColor: const Color(0xFFD1FAE5),
        colorText: const Color(0xFF065F46),
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao registrar evento clínico: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'Crise/Emergência':
        return Icons.emergency_rounded;
      case 'Acompanhamento de Condição Crônica':
        return Icons.monitor_heart_rounded;
      case 'Episódio Psicológico ou Emocional':
        return Icons.psychology_rounded;
      case 'Evento Relacionado à Medicação':
        return Icons.medication_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'Crise/Emergência':
        return const Color(0xFFDC2626);
      case 'Acompanhamento de Condição Crônica':
        return const Color(0xFF059669);
      case 'Episódio Psicológico ou Emocional':
        return const Color(0xFF7C3AED);
      case 'Evento Relacionado à Medicação':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getIntensityColor(String? value) {
    switch (value) {
      case '0':
        return const Color(0xFF059669);
      case '2':
        return const Color(0xFF10B981);
      case '5':
        return const Color(0xFFF59E0B);
      case '8':
        return const Color(0xFFF97316);
      case '10':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }
}



