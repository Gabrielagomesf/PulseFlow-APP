import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/menstruacao.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class MenstruacaoFormScreen extends StatefulWidget {
  final Menstruacao? menstruacao;

  const MenstruacaoFormScreen({Key? key, this.menstruacao}) : super(key: key);

  @override
  State<MenstruacaoFormScreen> createState() => _MenstruacaoFormScreenState();
}

class _MenstruacaoFormScreenState extends State<MenstruacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _pacienteId;
  late DateTime _dataInicio;
  late DateTime _dataFim;
  bool _isLoading = false;
  
  // Dados por dia
  Map<String, DiaMenstruacao> _diasPorData = {};

  @override
  void initState() {
    super.initState();
    _pacienteId = AuthService.instance.currentUser!.id!;
    _dataInicio = widget.menstruacao?.dataInicio ?? DateTime.now();
    _dataFim = widget.menstruacao?.dataFim ?? DateTime.now().add(const Duration(days: 5));
    
    // Inicializar dados por dia se existir
    if (widget.menstruacao?.diasPorData != null) {
      _diasPorData = Map.from(widget.menstruacao!.diasPorData!);
    } else {
      _initializeDiasPorData();
    }
  }

  void _initializeDiasPorData() {
    _diasPorData.clear();
    final duracao = _dataFim.difference(_dataInicio).inDays + 1;
    
    for (int i = 0; i < duracao; i++) {
      final data = _dataInicio.add(Duration(days: i));
      final dataStr = DateFormat('yyyy-MM-dd').format(data);
      _diasPorData[dataStr] = DiaMenstruacao(
        fluxo: 'Moderado',
        teveColica: false,
        humor: 'Normal',
      );
    }
  }

  Future<void> _selectDataInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataInicio,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _dataInicio) {
      setState(() {
        _dataInicio = picked;
        // Ajustar data fim se necessário
        if (_dataFim.isBefore(_dataInicio)) {
          _dataFim = _dataInicio.add(const Duration(days: 5));
        }
        _initializeDiasPorData();
      });
    }
  }

  Future<void> _selectDataFim(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataFim,
      firstDate: _dataInicio,
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _dataFim) {
      setState(() {
        _dataFim = picked;
        _initializeDiasPorData();
      });
    }
  }

  Future<void> _saveMenstruacao() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_dataFim.isBefore(_dataInicio)) {
        Get.snackbar('Erro', 'A data de fim deve ser posterior à data de início',
            backgroundColor: AppTheme.error, colorText: Colors.white);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final novaMenstruacao = Menstruacao(
        id: widget.menstruacao?.id,
        pacienteId: _pacienteId,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        diasPorData: _diasPorData,
        createdAt: widget.menstruacao?.createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.menstruacao == null) {
          await DatabaseService().createMenstruacao(novaMenstruacao);
          Get.snackbar('Sucesso', 'Ciclo menstrual registrado com sucesso!',
              backgroundColor: AppTheme.success, colorText: Colors.white);
        } else {
          await DatabaseService().updateMenstruacao(novaMenstruacao);
          Get.snackbar('Sucesso', 'Ciclo menstrual atualizado com sucesso!',
              backgroundColor: AppTheme.success, colorText: Colors.white);
        }
        Get.back();
      } catch (e) {
        Get.snackbar('Erro', 'Falha ao salvar ciclo menstrual: $e',
            backgroundColor: AppTheme.error, colorText: Colors.white);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.menstruacao == null ? 'Novo Ciclo Menstrual' : 'Editar Ciclo',
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
              // Header estilo Flo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E3A8A),
                      const Color(0xFF3B82F6),
                      const Color(0xFF60A5FA),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ícone principal
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Título principal
                    Text(
                      'Registrar Ciclo',
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtítulo
                    Text(
                      'Acompanhe seu ciclo menstrual com detalhes',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Estatísticas rápidas
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Duração', '${_dataFim.difference(_dataInicio).inDays + 1} dias'),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem('Período', '${DateFormat('dd/MM').format(_dataInicio)} - ${DateFormat('dd/MM').format(_dataFim)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Data de Início
              _buildInfoCard(
                icon: Icons.play_circle_outline_rounded,
                title: 'Data de Início',
                child: InkWell(
                  onTap: () => _selectDataInicio(context),
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
                          DateFormat('dd/MM/yyyy').format(_dataInicio),
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

              // Data de Fim
              _buildInfoCard(
                icon: Icons.stop_circle_outlined,
                title: 'Data de Fim',
                child: InkWell(
                  onTap: () => _selectDataFim(context),
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
                          DateFormat('dd/MM/yyyy').format(_dataFim),
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

              // Informações do Ciclo
              _buildInfoCard(
                icon: Icons.info_outline_rounded,
                title: 'Informações do Ciclo',
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
                            Icons.schedule_rounded,
                            color: const Color(0xFF1E3A8A),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Duração do ciclo:',
                            style: AppTheme.bodyMedium.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_dataFim.difference(_dataInicio).inDays + 1} dias',
                            style: AppTheme.bodyMedium.copyWith(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: const Color(0xFF1E3A8A),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Período:',
                            style: AppTheme.bodyMedium.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${DateFormat('dd/MM').format(_dataInicio)} - ${DateFormat('dd/MM').format(_dataFim)}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dados por Dia
              _buildInfoCard(
                icon: Icons.calendar_view_day_rounded,
                title: 'Dados por Dia',
                child: Column(
                  children: [
                    for (int i = 0; i < _dataFim.difference(_dataInicio).inDays + 1; i++) ...[
                      _buildDiaCard(i),
                      if (i < _dataFim.difference(_dataInicio).inDays) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botão Salvar estilo Flo
              Container(
                width: double.infinity,
                height: 60,
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
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _isLoading ? null : _saveMenstruacao,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading) ...[
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            _isLoading 
                                ? 'Salvando...' 
                                : (widget.menstruacao == null ? 'Registrar Ciclo' : 'Atualizar Ciclo'),
                            style: AppTheme.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
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
                  borderRadius: BorderRadius.circular(8),
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

  Widget _buildDiaCard(int index) {
    final data = _dataInicio.add(Duration(days: index));
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final dia = _diasPorData[dataStr]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do dia com estilo Flo
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E3A8A),
                      const Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    '${data.day}',
                    style: AppTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE', 'pt_BR').format(data),
                      style: AppTheme.bodyMedium.copyWith(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy', 'pt_BR').format(data),
                      style: AppTheme.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Fluxo com indicadores visuais
          _buildFluxoSection(dataStr, dia),
          
          const SizedBox(height: 16),
          
          // Cólica e Humor em linha
          Row(
            children: [
              Expanded(
                child: _buildColicaSection(dataStr, dia),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHumorSection(dataStr, dia),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFluxoSection(String dataStr, DiaMenstruacao dia) {
    final fluxoOptions = [
      {'value': 'Leve', 'color': const Color(0xFF10B981), 'icon': Icons.water_drop_outlined},
      {'value': 'Moderado', 'color': const Color(0xFFF59E0B), 'icon': Icons.water_drop_rounded},
      {'value': 'Intenso', 'color': const Color(0xFFEF4444), 'icon': Icons.water_drop_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fluxo',
          style: AppTheme.bodyMedium.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: fluxoOptions.map((option) {
            final isSelected = dia.fluxo == option['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _diasPorData[dataStr] = DiaMenstruacao(
                      fluxo: option['value'] as String,
                      teveColica: dia.teveColica,
                      humor: dia.humor,
                    );
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (option['color'] as Color).withOpacity(0.1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? option['color'] as Color
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        option['icon'] as IconData,
                        color: isSelected 
                            ? option['color'] as Color
                            : const Color(0xFF64748B),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['value'] as String,
                        style: AppTheme.bodySmall.copyWith(
                          color: isSelected 
                              ? option['color'] as Color
                              : const Color(0xFF64748B),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColicaSection(String dataStr, DiaMenstruacao dia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cólica',
          style: AppTheme.bodyMedium.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _diasPorData[dataStr] = DiaMenstruacao(
                fluxo: dia.fluxo,
                teveColica: !dia.teveColica,
                humor: dia.humor,
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: dia.teveColica 
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: dia.teveColica 
                    ? Colors.red
                    : const Color(0xFFE2E8F0),
                width: dia.teveColica ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  dia.teveColica ? Icons.favorite : Icons.favorite_border,
                  color: dia.teveColica ? Colors.red : const Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  dia.teveColica ? 'Sim' : 'Não',
                  style: AppTheme.bodySmall.copyWith(
                    color: dia.teveColica ? Colors.red : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHumorSection(String dataStr, DiaMenstruacao dia) {
    final humorOptions = [
      {'value': 'Feliz', 'emoji': '😊', 'color': const Color(0xFF10B981)},
      {'value': 'Normal', 'emoji': '😐', 'color': const Color(0xFF6B7280)},
      {'value': 'Triste', 'emoji': '😢', 'color': const Color(0xFF3B82F6)},
      {'value': 'Ansioso', 'emoji': '😰', 'color': const Color(0xFFF59E0B)},
      {'value': 'Raiva', 'emoji': '😠', 'color': const Color(0xFFEF4444)},
      {'value': 'Cansado', 'emoji': '😴', 'color': const Color(0xFF8B5CF6)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Humor',
          style: AppTheme.bodyMedium.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButton<String>(
            value: dia.humor,
            isExpanded: true,
            underline: Container(),
            items: humorOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'] as String,
                child: Row(
                  children: [
                    Text(
                      option['emoji'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option['value'] as String,
                      style: AppTheme.bodySmall.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _diasPorData[dataStr] = DiaMenstruacao(
                    fluxo: dia.fluxo,
                    teveColica: dia.teveColica,
                    humor: newValue,
                  );
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
