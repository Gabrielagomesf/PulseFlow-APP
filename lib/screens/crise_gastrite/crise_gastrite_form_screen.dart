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
  int _intensidadeDor = 5;
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
      case 10:
        return 'Dor Muito Intensa';
      default:
        return 'Dor Moderada';
    }
  }

  Color _getIntensidadeColor(int intensidade) {
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
        Get.snackbar(
          'Sucesso',
          'Crise de gastrite registrada com sucesso!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        await DatabaseService().updateCriseGastrite(crise);
        Get.snackbar(
          'Sucesso',
          'Crise de gastrite atualizada com sucesso!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      Get.back();
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.criseGastrite == null ? 'Nova Crise de Gastrite' : 'Editar Crise',
          style: AppTheme.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E3A8A),
                      const Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Registro de Crise de Gastrite',
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registre os detalhes da sua crise para acompanhamento médico',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Data da Crise
              _buildInfoCard(
                icon: Icons.calendar_today_rounded,
                title: 'Data da Crise',
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: const Color(0xFF1E3A8A),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: const Color(0xFF64748B),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Intensidade da Dor
              _buildInfoCard(
                icon: Icons.monitor_heart_rounded,
                title: 'Intensidade da Dor',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                              style: AppTheme.bodyMedium.copyWith(
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
                          min: 1,
                          max: 10,
                          divisions: 9,
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
              ),

              const SizedBox(height: 16),

              // Sintomas
              _buildInfoCard(
                icon: Icons.health_and_safety_rounded,
                title: 'Sintomas Relatados',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _sintomasController,
                      decoration: AppTheme.textFieldDecoration('Descreva os sintomas'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, descreva os sintomas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sintomasComuns.map((sintoma) {
                        final isSelected = _sintomasController.text.contains(sintoma);
                        return FilterChip(
                          label: Text(sintoma),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _sintomasController.text = _sintomasController.text.isEmpty
                                    ? sintoma
                                    : '${_sintomasController.text}, $sintoma';
                              } else {
                                _sintomasController.text = _sintomasController.text
                                    .replaceAll(sintoma, '')
                                    .replaceAll(', ,', ',')
                                    .replaceAll(RegExp(r'^,\s*'), '')
                                    .replaceAll(RegExp(r',\s*$'), '');
                              }
                            });
                          },
                          selectedColor: const Color(0xFF1E3A8A).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF1E3A8A),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Alimentos Ingeridos
              _buildInfoCard(
                icon: Icons.restaurant_rounded,
                title: 'Alimentos Ingeridos',
                child: TextFormField(
                  controller: _alimentosController,
                  decoration: AppTheme.textFieldDecoration('Descreva os alimentos consumidos'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, descreva os alimentos ingeridos';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Medicação
              _buildInfoCard(
                icon: Icons.medication_rounded,
                title: 'Medicação Usada',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _medicacaoController,
                      decoration: AppTheme.textFieldDecoration('Nome da medicação'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe a medicação usada';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _medicacoesComuns.map((medicacao) {
                        return ActionChip(
                          label: Text(medicacao),
                          onPressed: () {
                            setState(() {
                              _medicacaoController.text = medicacao;
                            });
                          },
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: AppTheme.bodySmall.copyWith(
                            color: const Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Alívio após Medicação
              _buildInfoCard(
                icon: Icons.healing_rounded,
                title: 'Alívio após Medicação',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.health_and_safety_rounded,
                            color: const Color(0xFF1E3A8A),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Houve alívio após tomar a medicação?',
                              style: AppTheme.bodyMedium.copyWith(
                                color: const Color(0xFF1E293B),
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
                            style: AppTheme.bodySmall.copyWith(
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
                            activeColor: const Color(0xFF1E3A8A),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Sim',
                            style: AppTheme.bodySmall.copyWith(
                              color: _alivioMedicacao ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Observações Adicionais
              _buildInfoCard(
                icon: Icons.note_alt_rounded,
                title: 'Observações Adicionais',
                child: TextFormField(
                  controller: _observacoesController,
                  decoration: AppTheme.textFieldDecoration('Observações adicionais (opcional)'),
                  maxLines: 4,
                ),
              ),

              const SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCrise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.criseGastrite == null ? 'Registrar Crise' : 'Atualizar Crise',
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1E3A8A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.titleSmall.copyWith(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
