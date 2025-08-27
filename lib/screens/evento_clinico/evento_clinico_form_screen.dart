import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../models/evento_clinico.dart';
import '../../services/database_service.dart';
import '../login/paciente_controller.dart';

class EventoClinicoFormScreen extends StatefulWidget {
  const EventoClinicoFormScreen({super.key});

  @override
  State<EventoClinicoFormScreen> createState() => _EventoClinicoFormScreenState();
}

class _EventoClinicoFormScreenState extends State<EventoClinicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _tipoEventoController = TextEditingController();
  final _especialidadeController = TextEditingController();
  final _intensidadeController = TextEditingController(text: '0');
  final _alivioController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _sintomasController = TextEditingController();
  DateTime _dataHora = DateTime.now();
  bool _submitting = false;
  final List<Map<String, String>> _intensityOptions = const [
    {'label': 'Sem dor', 'value': '0'},
    {'label': 'Dor leve (1-3)', 'value': '2'},
    {'label': 'Dor moderada (4-6)', 'value': '5'},
    {'label': 'Intensa (7-9)', 'value': '8'},
    {'label': 'Insuportável 10', 'value': '10'},
  ];
  String? _selectedIntensity;
  final GlobalKey _intensityFieldKey = GlobalKey();
  final List<Map<String, String>> _tipoOptions = const [
    {'label': 'Todos os tipos', 'value': 'Todos os tipos'},
    {'label': 'Crise/Emergência', 'value': 'Crise/Emergência'},
    {'label': 'Acompanhamento de Condição Crônica', 'value': 'Acompanhamento de Condição Crônica'},
    {'label': 'Episódio Psicológico ou Emocional', 'value': 'Episódio Psicológico ou Emocional'},
    {'label': 'Evento Relacionado à Medicação', 'value': 'Evento Relacionado à Medicação'},
  ];
  String? _selectedTipo;
  final GlobalKey _tipoFieldKey = GlobalKey();

  @override
  void dispose() {
    _tituloController.dispose();
    _tipoEventoController.dispose();
    _especialidadeController.dispose();
    _intensidadeController.dispose();
    _alivioController.dispose();
    _descricaoController.dispose();
    _sintomasController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora),
    );
    if (time == null) return;
    setState(() {
      _dataHora = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final pacienteId = Get.find<PacienteController>().pacienteId.value;
      final evento = EventoClinico(
        paciente: pacienteId,
        titulo: _tituloController.text.trim(),
        dataHora: _dataHora,
        tipoEvento: _tipoEventoController.text.trim(),
        especialidade: _especialidadeController.text.trim(),
        intensidadeDor: _intensidadeController.text.trim(),
        alivio: _alivioController.text.trim(),
        descricao: _descricaoController.text.trim(),
        sintomas: _sintomasController.text.trim(),
      );
      await DatabaseService().createEventoClinico(evento);
      if (mounted) {
        Get.back();
        Get.snackbar('Sucesso', 'Evento clínico registrado com sucesso');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Erro', e.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Evento Clínico'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderCardForm(title: 'Registrar evento clínico', subtitle: 'Preencha os campos abaixo para documentar um evento.'),
                    const SizedBox(height: 16),

                    _SectionCard(
                      icon: Icons.info_outline,
                      title: 'Informações básicas',
                      child: Column(
                        children: [
                          _textField(controller: _tituloController, label: 'Título do evento', validator: _required),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, c) {
                              final two = c.maxWidth > 560;
                              if (!two) {
                                return Column(
                                  children: [
                                    _buildTipoDropdown(),
                                    const SizedBox(height: 12),
                                    _textField(controller: _especialidadeController, label: 'Especialidade', validator: _required),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: _buildTipoDropdown()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _textField(controller: _especialidadeController, label: 'Especialidade', validator: _required)),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.healing_outlined,
                      title: 'Intensidade e data/hora',
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final two = c.maxWidth > 560;

                          final headerValue = '__header__';
                          final intensity = _buildIntensityDropdown();

                          final date = InkWell(
                            onTap: _pickDateTime,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: AppTheme.textFieldDecoration('Data e hora'),
                              child: Row(
                                children: [
                                  const Icon(Icons.event, color: Color(0xFF1E88E5)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${_dataHora.day.toString().padLeft(2, '0')}/${_dataHora.month.toString().padLeft(2, '0')}/${_dataHora.year}  •  ${_dataHora.hour.toString().padLeft(2, '0')}:${_dataHora.minute.toString().padLeft(2, '0')}',
                                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (two) {
                            return Row(children: [Expanded(child: intensity), const SizedBox(width: 12), Expanded(child: date)]);
                          }
                          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [intensity, const SizedBox(height: 12), date]);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.description_outlined,
                      title: 'Sintomas e descrição',
                      child: Column(
                        children: [
                          _multiline(controller: _sintomasController, label: 'Sintomas', validator: _required),
                          const SizedBox(height: 12),
                          _multiline(controller: _descricaoController, label: 'Registro clínico / descrição', validator: _required),
                          const SizedBox(height: 12),
                          _multiline(controller: _alivioController, label: 'Alívio / Medicação'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitting ? null : () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1F4068)),
                              foregroundColor: const Color(0xFF1F4068),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: _submitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check_circle_outline),
                            label: Text(_submitting ? 'Salvando...' : 'Salvar Evento Clínico'),
                            style: AppTheme.primaryButtonStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntensityDropdown() {
    final currentLabel = _intensityOptions
        .firstWhere(
          (e) => e['value'] == _selectedIntensity,
          orElse: () => {'label': 'Todas as intensidades'},
        )['label'];

    return InkWell(
      key: _intensityFieldKey,
      onTap: () async {
        await _openIntensityMenu();
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: AppTheme
            .textFieldDecoration('Intensidade da dor')
            .copyWith(labelText: null, hintText: 'Todas as intensidades'),
        child: Row(
          children: [
            Expanded(
              child: Text(
                currentLabel!,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _openIntensityMenu() async {
    final renderBox = _intensityFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = Rect.fromLTWH(offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
    final position = RelativeRect.fromRect(rect, Offset.zero & overlay.size);

    final header = PopupMenuItem<String>(
      enabled: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('Todas as intensidades', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
      ),
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        header,
        ..._intensityOptions.map((opt) {
          final isSelected = _selectedIntensity == opt['value'];
          return PopupMenuItem<String>(
            value: opt['value']!,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(opt['label']!, style: AppTheme.bodyMedium.copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_rounded, size: 18, color: Color(0xFF1E88E5)),
              ],
            ),
          );
        })
      ],
    );

    if (result != null) {
      setState(() {
        _selectedIntensity = result;
        _intensidadeController.text = result;
      });
    }
  }

  Widget _buildTipoDropdown() {
    final currentLabel = _tipoOptions
        .firstWhere(
          (e) => e['value'] == _selectedTipo,
          orElse: () => {'label': 'Todos os tipos'},
        )['label'];

    return InkWell(
      key: _tipoFieldKey,
      onTap: () async {
        await _openTipoMenu();
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: AppTheme
            .textFieldDecoration('Tipo do evento')
            .copyWith(labelText: null, hintText: 'Todos os tipos'),
        child: Row(
          children: [
            Expanded(
              child: Text(
                currentLabel!,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _openTipoMenu() async {
    final renderBox = _tipoFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = Rect.fromLTWH(offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
    final position = RelativeRect.fromRect(rect, Offset.zero & overlay.size);

    final header = PopupMenuItem<String>(
      enabled: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('Todos os tipos', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
      ),
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        header,
        ..._tipoOptions.map((opt) {
          final isSelected = _selectedTipo == opt['value'];
          return PopupMenuItem<String>(
            value: opt['value']!,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(opt['label']!, style: AppTheme.bodyMedium.copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_rounded, size: 18, color: Color(0xFF1E88E5)),
              ],
            ),
          );
        })
      ],
    );

    if (result != null) {
      setState(() {
        _selectedTipo = result;
        _tipoEventoController.text = result;
      });
    }
  }

  // Header estilizado
  Widget _HeaderCardForm({required String title, required String subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))],
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cartão de seção reutilizável
  Widget _SectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: const Color(0xFF1E88E5), size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTheme.bodySmall.copyWith(color: const Color(0xFF1C4A7D), fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTheme.titleSmall.copyWith(color: const Color(0xFF1C4A7D))),
      );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: AppTheme.textFieldDecoration(label),
      validator: validator,
    );
  }

  Widget _multiline({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: AppTheme.textFieldDecoration(label),
      validator: validator,
    );
  }

  String? _required(String? v) => (v == null || v.isEmpty) ? 'Obrigatório' : null;
}



