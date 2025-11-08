import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/evento_clinico.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class EventoClinicoFormScreen extends StatefulWidget {
  final String? pacienteId;

  const EventoClinicoFormScreen({super.key, this.pacienteId});

  @override
  State<EventoClinicoFormScreen> createState() => _EventoClinicoFormScreenState();
}

class _EventoClinicoFormScreenState extends State<EventoClinicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _medicacaoController = TextEditingController();
  final _sintomasController = TextEditingController();
  
  final DatabaseService _databaseService = DatabaseService();
  
  String? _selectedTipo;
  int _intensidadeDor = 0;
  String? _selectedEspecialidade;
  DateTime _selectedDate = DateTime.now();

  final List<String> _tipos = [
    'Crise/Emergência',
    'Acompanhamento de Condição Crônica',
    'Episódio Psicológico ou Emocional',
    'Evento Relacionado à Medicação',
  ];

  final List<String> _especialidades = [
    'Acupuntura',
    'Alergia e imunologia',
    'Anestesiologia',
    'Angiologia',
    'Cardiologia',
    'Cirurgia cardiovascular',
    'Cirurgia da mão',
    'Cirurgia de cabeça e pescoço',
    'Cirurgia do aparelho digestivo',
    'Cirurgia geral',
    'Cirurgia oncológica',
    'Cirurgia pediátrica',
    'Cirurgia plástica',
    'Cirurgia torácica',
    'Cirurgia vascular',
    'Clínica médica',
    'Coloproctologia',
    'Dermatologia',
    'Endocrinologia e metabologia',
    'Endoscopia',
    'Gastroenterologia',
    'Genética médica',
    'Geriatria',
    'Ginecologia e obstetrícia',
    'Hematologia e hemoterapia',
    'Homeopatia',
    'Infectologia',
    'Mastologia',
    'Medicina de emergência',
    'Medicina de família e comunidade',
    'Medicina do trabalho',
    'Medicina do tráfego',
    'Medicina esportiva',
    'Medicina física e reabilitação',
    'Medicina intensiva',
    'Medicina legal e perícia médica',
    'Medicina nuclear',
    'Medicina preventiva e social',
    'Nefrologia',
    'Neurocirurgia',
    'Neurologia',
    'Nutrologia',
    'Oftalmologia',
    'Oncologia clínica',
    'Ortopedia e traumatologia',
    'Otorrinolaringologia',
    'Patologia',
    'Patologia clínica/medicina laboratorial',
    'Pediatria',
    'Pneumologia',
    'Psiquiatria',
    'Radiologia e diagnóstico por imagem',
    'Radioterapia',
    'Reumatologia',
    'Urologia',
  ];

  String _getIntensidadeLabel(int intensidade) {
    switch (intensidade) {
      case 0:
        return 'Sem Dor';
      case 1:
      case 2:
        return 'Dor Leve';
      case 3:
      case 4:
        return 'Dor Moderada';
      case 5:
      case 6:
        return 'Dor Moderada a Intensa';
      case 7:
      case 8:
        return 'Dor Intensa';
      case 9:
        return 'Dor Muito Intensa';
      case 10:
        return 'Dor Insuportável';
      default:
        return 'Sem Dor';
    }
  }

  Color _getIntensidadeColor(int intensidade) {
    if (intensidade == 0) return Colors.green;
    if (intensidade <= 3) return Colors.green;
    if (intensidade <= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _medicacaoController.dispose();
    _sintomasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00324A),
      body: Column(
        children: [
          // Header azul como outras telas
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        
                        // Campos principais
                        _buildTextField(
                          controller: _tituloController,
                          label: 'Título do Evento',
                          hint: 'Ex: Controle de epilepsia',
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildDropdownField(
                          label: 'Especialidade',
                          value: _selectedEspecialidade,
                          items: _especialidades,
                          onChanged: (value) => setState(() => _selectedEspecialidade = value),
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildDropdownField(
                          label: 'Tipo de Evento',
                          value: _selectedTipo,
                          items: _tipos,
                          onChanged: (value) => setState(() => _selectedTipo = value),
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildIntensidadeField(),
                        const SizedBox(height: 12),
                        
                        _buildDateTimeFields(),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _descricaoController,
                          label: 'Descrição do Evento',
                          hint: 'Descreva os sintomas e detalhes',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _medicacaoController,
                          label: 'Medicação e Alívio',
                          hint: 'Medicamentos utilizados',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _sintomasController,
                          label: 'Sintomas',
                          hint: 'Descreva os sintomas apresentados',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        
                      // Botões de ação
                      _buildActionButtons(),
                    ],
                  ),
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
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF00324A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Botão de voltar
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          
          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registro de Evento Clínico',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Documente seu evento médico',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildIntensidadeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          'Intensidade da Dor',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00324A),
          ),
          ),
          const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                    Icons.favorite_rounded,
                    color: _getIntensidadeColor(_intensidadeDor),
                size: 20,
              ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_getIntensidadeLabel(_intensidadeDor)} (${_intensidadeDor}/10)',
                      style: TextStyle(
                        color: _getIntensidadeColor(_intensidadeDor),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getIntensidadeColor(_intensidadeDor),
                  inactiveTrackColor: _getIntensidadeColor(_intensidadeDor).withOpacity(0.3),
                  thumbColor: _getIntensidadeColor(_intensidadeDor),
                  overlayColor: _getIntensidadeColor(_intensidadeDor).withOpacity(0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _intensidadeDor.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      _intensidadeDor = value.round();
                    });
                  },
                ),
              ),
            ],
                ),
              ),
            ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00324A),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
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
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00324A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00324A),
              ),
            ),
            if (isRequired) ...[
            const SizedBox(width: 4),
              const Text(
              '*',
                style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: (value) {
            if (isRequired && value == null) {
              return 'Este campo é obrigatório';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Selecione uma opção',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00324A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data',
          style: TextStyle(
            fontSize: 14,
                fontWeight: FontWeight.w600,
            color: Color(0xFF00324A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF00324A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _clearForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Limpar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
                ),
                const SizedBox(width: 12),
                Expanded(
          child: ElevatedButton(
            onPressed: _saveEventoClinico,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00324A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF00324A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Início', false, () {
              Get.toNamed('/home');
            }),
            _buildNavItem(Icons.grid_view, 'Históricos', false, () {
              Get.toNamed('/history-selection');
            }),
            _buildNavItem(Icons.add, 'Registro', true, () {
              Get.toNamed('/menu');
            }),
            _buildNavItem(Icons.vpn_key, 'Pulse Key', false, () {
              Get.toNamed('/pulse-key');
            }),
            _buildNavItem(Icons.person, 'Perfil', false, () {
              Get.toNamed('/profile');
            }),
          ],
        ),
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
          mainAxisSize: MainAxisSize.min,
        children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
          Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00324A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  void _clearForm() {
    setState(() {
      _tituloController.clear();
      _descricaoController.clear();
      _medicacaoController.clear();
      _sintomasController.clear();
      _selectedTipo = null;
      _intensidadeDor = 0;
      _selectedEspecialidade = null;
      _selectedDate = DateTime.now();
    });
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00324A).withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com gradiente
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00324A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
            children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Evento Registrado!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Conteúdo
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'O evento clínico foi salvo com sucesso no seu histórico médico.',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Botão de fechar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00324A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                  ),
                ),
              ),
                ),
            ],
          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveEventoClinico() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Data já está preenchida com o dia atual, não precisa validar

    try {
      final eventoClinico = EventoClinico(
        paciente: widget.pacienteId ?? '68a3b77a5b36b8a11580651f', // ID do paciente correto
        titulo: _tituloController.text.trim(),
        especialidade: _selectedEspecialidade!,
        tipoEvento: _selectedTipo!,
        intensidadeDor: _intensidadeDor.toString(), // Usar o valor direto do slider
        dataHora: _selectedDate,
        descricao: _descricaoController.text.trim(),
        sintomas: _sintomasController.text.trim(),
        alivio: _medicacaoController.text.trim(),
      );

      await _databaseService.createEventoClinico(eventoClinico);

      // Mostrar aviso bonito de sucesso
      _showSuccessAlert();
      
      // Limpar campos automaticamente
      _clearForm();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar evento clínico: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}