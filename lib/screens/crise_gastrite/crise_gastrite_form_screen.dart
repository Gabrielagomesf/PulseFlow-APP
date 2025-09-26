import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/crise_gastrite.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class CriseGastriteFormScreen extends StatefulWidget {
  final CriseGastrite? criseGastrite;

  const CriseGastriteFormScreen({Key? key, this.criseGastrite}) : super(key: key);

  @override
  State<CriseGastriteFormScreen> createState() => _CriseGastriteFormScreenState();
}

class _CriseGastriteFormScreenState extends State<CriseGastriteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sintomasController = TextEditingController();
  final _alimentosController = TextEditingController();
  final _medicacaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _intensidadeDor = 0;
  bool _alivioMedicacao = false;
  bool _isLoading = false;

  final List<String> _sintomasComuns = [
    'Náusea',
    'Queimação',
    'Dor epigástrica',
    'Vômito',
    'Perda de apetite',
    'Sensação de estômago cheio',
    'Arrotos frequentes',
    'Má digestão',
  ];

  final List<String> _medicacoesComuns = [
    'Omeprazol',
    'Pantoprazol',
    'Ranitidina',
    'Famotidina',
    'Domperidona',
    'Metoclopramida',
    'Simeticona',
    'Buscopan',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.criseGastrite != null) {
      _loadCriseData();
    }
  }

  void _loadCriseData() {
    final crise = widget.criseGastrite!;
    _selectedDate = crise.data;
    _intensidadeDor = crise.intensidadeDor;
    _sintomasController.text = crise.sintomas;
    _alimentosController.text = crise.alimentosIngeridos;
    _medicacaoController.text = crise.medicacao;
    _alivioMedicacao = crise.alivioMedicacao;
    _observacoesController.text = crise.observacoes;
  }

  @override
  void dispose() {
    _sintomasController.dispose();
    _alimentosController.dispose();
    _medicacaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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

  Future<void> _saveCrise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser?.id == null) {
        throw 'Usuário não autenticado';
      }

      final crise = CriseGastrite(
        id: widget.criseGastrite?.id,
        pacienteId: currentUser!.id,
        data: _selectedDate,
        intensidadeDor: _intensidadeDor,
        sintomas: _sintomasController.text.trim(),
        alimentosIngeridos: _alimentosController.text.trim(),
        medicacao: _medicacaoController.text.trim(),
        alivioMedicacao: _alivioMedicacao,
        observacoes: _observacoesController.text.trim(),
        createdAt: widget.criseGastrite?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.criseGastrite == null) {
        await DatabaseService().createCriseGastrite(crise);
      } else {
        await DatabaseService().updateCriseGastrite(crise);
      }

      // Mostrar confirmação e limpar campos
      _showSuccessAlert();
      _clearForm();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar crise de gastrite: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00324A),
        elevation: 0,
        title: Text(
          widget.criseGastrite == null ? 'Registro de Crise de Gastrite' : 'Editar Crise',
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600
          )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Card principal com formulário
                Card(
                  color: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.criseGastrite == null ? 'Nova crise de gastrite' : 'Editar crise',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00324A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Data da Crise
                        _buildModernTextField(
                          label: 'Data da Crise',
                          value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          icon: Icons.calendar_today,
                          onTap: _selectDate,
                        ),
                        const SizedBox(height: 12),

                        // Intensidade da Dor
                        _buildIntensidadeField(),
                        const SizedBox(height: 12),

                        // Sintomas
                        _buildModernTextFormField(
                          controller: _sintomasController,
                          label: 'Sintomas Relatados',
                          hint: 'Descreva os sintomas',
                          icon: Icons.health_and_safety,
                          isRequired: true,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),

                        // Alimentos Ingeridos
                        _buildModernTextFormField(
                          controller: _alimentosController,
                          label: 'Alimentos Ingeridos',
                          hint: 'Descreva os alimentos consumidos',
                          icon: Icons.restaurant,
                          isRequired: true,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),

                        // Medicação
                        _buildModernTextFormField(
                          controller: _medicacaoController,
                          label: 'Medicação Usada',
                          hint: 'Nome da medicação',
                          icon: Icons.medication,
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),

                        // Alívio após Medicação
                        _buildAlivioField(),
                        const SizedBox(height: 12),

                        // Observações Adicionais
                        _buildModernTextFormField(
                          controller: _observacoesController,
                          label: 'Observações Adicionais',
                          hint: 'Observações adicionais (opcional)',
                          icon: Icons.note_alt,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        
                        // Botões de ação
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _clearForm,
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
            onPressed: _isLoading ? null : _saveCrise,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00324A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.criseGastrite == null ? 'Salvar' : 'Atualizar',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com ícone
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00324A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sucesso!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                        widget.criseGastrite == null 
                            ? 'Crise de gastrite registrada com sucesso!'
                            : 'Crise de gastrite atualizada com sucesso!',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00324A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
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

  void _clearForm() {
    setState(() {
      _sintomasController.clear();
      _alimentosController.clear();
      _medicacaoController.clear();
      _observacoesController.clear();
      _intensidadeDor = 0;
      _alivioMedicacao = false;
      _selectedDate = DateTime.now();
    });
  }

  Widget _buildAlivioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alívio após Medicação',
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
                    Icons.healing_rounded,
                    color: const Color(0xFF00324A),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Houve alívio após tomar a medicação?',
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não',
                    style: TextStyle(
                      color: _alivioMedicacao ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: _alivioMedicacao,
                    onChanged: (value) {
                      setState(() {
                        _alivioMedicacao = value;
                      });
                    },
                    activeColor: const Color(0xFF00324A),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Sim',
                    style: TextStyle(
                      color: _alivioMedicacao ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00324A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
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
                Icon(icon, size: 20, color: const Color(0xFF00324A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
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

  Widget _buildModernTextFormField({
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
            prefixIcon: Icon(icon, color: const Color(0xFF00324A)),
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
}
