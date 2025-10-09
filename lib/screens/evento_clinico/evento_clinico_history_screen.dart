import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/evento_clinico.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class EventoClinicoHistoryScreen extends StatefulWidget {
  const EventoClinicoHistoryScreen({super.key});

  @override
  State<EventoClinicoHistoryScreen> createState() => _EventoClinicoHistoryScreenState();
}

class _EventoClinicoHistoryScreenState extends State<EventoClinicoHistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<EventoClinico> _eventos = [];
  List<EventoClinico> _filteredEventos = [];
  bool _isLoading = true;
  String? _error;

  // Filtros
  String? _selectedTipo;
  String? _selectedEspecialidade;
  String? _selectedIntensidadeDor;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;
  
  // Listas para os filtros
  final List<String> _especialidades = [
    'Cardiologia',
    'Neurologia',
    'Ortopedia',
    'Pediatria',
    'Ginecologia',
    'Dermatologia',
    'Oftalmologia',
    'Otorrinolaringologia',
    'Psiquiatria',
    'Anestesiologia',
    'Patologia',
    'Radiologia',
    'Urologia',
    'Endocrinologia',
    'Gastroenterologia',
    'Pneumologia',
    'Reumatologia',
    'Oncologia',
    'Hematologia',
    'Nefrologia',
  ];
  
  final List<String> _tiposConsulta = [
    'Consulta Regular',
    'Consulta de Emergência',
    'Consulta de Retorno',
    'Acompanhamento de Condição',
    'Episódio Psicológico ou Emocional',
    'Exame Médico',
    'Procedimento Médico',
    'Cirurgia',
    'Terapia',
    'Reabilitação',
  ];
  
  final List<String> _intensidadesDor = [
    'Sem Dor (0/10)',
    'Dor Leve (1-2/10)',
    'Dor Moderada (3-4/10)',
    'Dor Moderada a Intensa (5-6/10)',
    'Dor Intensa (7-8/10)',
    'Dor Muito Intensa (9/10)',
    'Dor Insuportável (10/10)',
  ];

  @override
  void initState() {
    super.initState();
    _loadEventos();
  }

  Future<void> _loadEventos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser?.id == null) {
        throw 'Usuário não autenticado';
      }

      final eventos = await _databaseService.getEventosClinicosByPacienteId(currentUser!.id!);
      
      setState(() {
        _eventos = eventos;
        _filteredEventos = eventos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEventos = _eventos.where((evento) {
        // Filtro por especialidade
        if (_selectedEspecialidade != null && evento.especialidade != _selectedEspecialidade) {
          return false;
        }
        
        // Filtro por tipo de consulta
        if (_selectedTipo != null && evento.tipoEvento != _selectedTipo) {
          return false;
        }
        
        // Filtro por intensidade da dor
        if (_selectedIntensidadeDor != null) {
          final intensidade = int.tryParse(evento.intensidadeDor) ?? 0;
          bool matchesIntensity = false;
          
          switch (_selectedIntensidadeDor) {
            case 'Sem Dor (0/10)':
              matchesIntensity = intensidade == 0;
              break;
            case 'Dor Leve (1-2/10)':
              matchesIntensity = intensidade >= 1 && intensidade <= 2;
              break;
            case 'Dor Moderada (3-4/10)':
              matchesIntensity = intensidade >= 3 && intensidade <= 4;
              break;
            case 'Dor Moderada a Intensa (5-6/10)':
              matchesIntensity = intensidade >= 5 && intensidade <= 6;
              break;
            case 'Dor Intensa (7-8/10)':
              matchesIntensity = intensidade >= 7 && intensidade <= 8;
              break;
            case 'Dor Muito Intensa (9/10)':
              matchesIntensity = intensidade == 9;
              break;
            case 'Dor Insuportável (10/10)':
              matchesIntensity = intensidade == 10;
              break;
          }
          
          if (!matchesIntensity) {
            return false;
          }
        }
        
        // Filtro por data (se implementado futuramente)
        if (_selectedDateFrom != null && evento.dataHora.isBefore(_selectedDateFrom!)) {
          return false;
        }
        if (_selectedDateTo != null && evento.dataHora.isAfter(_selectedDateTo!)) {
          return false;
        }
        
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedTipo = null;
      _selectedEspecialidade = null;
      _selectedIntensidadeDor = null;
      _selectedDateFrom = null;
      _selectedDateTo = null;
      _filteredEventos = _eventos;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00324A),
      body: Column(
        children: [
          // Header moderno com gradiente
          _buildModernHeader(),
          
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _filteredEventos.isEmpty
                            ? _buildEmptyState()
                            : _buildEventosList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/evento-clinico-form');
        },
        backgroundColor: const Color(0xFF00324A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Evento',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
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
      child: Column(
        children: [
          // Linha com botão voltar e título
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Histórico Evento Clínico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          
          // Campos de filtro
          const SizedBox(height: 18),
          _buildFilterSection(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final hasActiveFilters = _selectedEspecialidade != null || _selectedTipo != null || _selectedIntensidadeDor != null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasActiveFilters 
            ? [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ]
            : [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasActiveFilters 
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
          width: hasActiveFilters ? 1.5 : 1,
        ),
        boxShadow: hasActiveFilters ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ] : null,
      ),
      child: Column(
        children: [
          // Header melhorado com indicador
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: hasActiveFilters 
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilters 
                    ? Colors.white
                    : Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_getActiveFilterCount()} ativo${_getActiveFilterCount() > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasActiveFilters)
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.8),
                            Colors.red.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Limpar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Filtros melhorados
          Row(
            children: [
              Expanded(
                child: _buildEnhancedDropdown(
                  hint: 'Especialidade',
                  value: _selectedEspecialidade,
                  items: _especialidades,
                  icon: Icons.medical_services_rounded,
                  isActive: _selectedEspecialidade != null,
                  onChanged: (value) {
                    setState(() {
                      _selectedEspecialidade = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnhancedDropdown(
                  hint: 'Tipo',
                  value: _selectedTipo,
                  items: _tiposConsulta,
                  icon: Icons.event_note_rounded,
                  isActive: _selectedTipo != null,
                  onChanged: (value) {
                    setState(() {
                      _selectedTipo = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnhancedDropdown(
                  hint: 'Dor',
                  value: _selectedIntensidadeDor,
                  items: _intensidadesDor,
                  icon: Icons.favorite_rounded,
                  isActive: _selectedIntensidadeDor != null,
                  onChanged: (value) {
                    setState(() {
                      _selectedIntensidadeDor = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedEspecialidade != null) count++;
    if (_selectedTipo != null) count++;
    if (_selectedIntensidadeDor != null) count++;
    return count;
  }

  Widget _buildEnhancedDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required bool isActive,
    required Function(String?) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive 
            ? [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ]
            : [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive 
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isActive 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon,
                    color: isActive 
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                    size: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      color: isActive 
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          dropdownColor: const Color(0xFF00324A),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          icon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedRotation(
              turns: isActive ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isActive 
                  ? Colors.white
                  : Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.all_inclusive_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Todos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00324A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF00324A),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Carregando eventos clínicos...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Erro ao carregar eventos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadEventos,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00324A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00324A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00324A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 48,
                color: Color(0xFF00324A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum evento encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Você ainda não registrou nenhum evento clínico.\nComece registrando seu primeiro evento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/evento-clinico-form');
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Registrar Primeiro Evento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00324A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventosList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com contador e filtros ativos
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_filteredEventos.length} eventos encontrados',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _loadEventos,
                    icon: const Icon(Icons.refresh_rounded),
                    color: const Color(0xFF00324A),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF00324A).withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_selectedTipo != null || _selectedEspecialidade != null || _selectedDateFrom != null || _selectedDateTo != null)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00324A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedTipo = null;
                            _selectedEspecialidade = null;
                            _selectedDateFrom = null;
                            _selectedDateTo = null;
                            _filteredEventos = _eventos;
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                          size: 16,
                          color: Color(0xFF00324A),
                        ),
                        label: const Text(
                          'Limpar Filtros',
                          style: TextStyle(
                            color: Color(0xFF00324A),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Mostrar filtros ativos
              if (_selectedTipo != null || _selectedEspecialidade != null || _selectedDateFrom != null || _selectedDateTo != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedTipo != null)
                      _buildFilterChip('Tipo: $_selectedTipo', () => setState(() => _selectedTipo = null)),
                    if (_selectedEspecialidade != null)
                      _buildFilterChip('Especialidade: $_selectedEspecialidade', () => setState(() => _selectedEspecialidade = null)),
                    if (_selectedDateFrom != null)
                      _buildFilterChip('De: ${_selectedDateFrom!.day}/${_selectedDateFrom!.month}/${_selectedDateFrom!.year}', () => setState(() => _selectedDateFrom = null)),
                    if (_selectedDateTo != null)
                      _buildFilterChip('Até: ${_selectedDateTo!.day}/${_selectedDateTo!.month}/${_selectedDateTo!.year}', () => setState(() => _selectedDateTo = null)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Lista de eventos
        Expanded(
          child: ListView.builder(
            itemCount: _filteredEventos.length,
            itemBuilder: (context, index) {
              final evento = _filteredEventos[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildEventoCard(evento),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00324A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00324A).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF00324A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFF00324A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventoCard(EventoClinico evento) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventoDetails(evento),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com especialidade e data
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00324A).withOpacity(0.1),
                            const Color(0xFF00324A).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00324A).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.medical_services,
                            size: 16,
                            color: Color(0xFF00324A),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              evento.especialidade,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00324A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${evento.dataHora.day}/${evento.dataHora.month}/${evento.dataHora.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Título principal do evento
                Text(
                  evento.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
                
                if (evento.descricao.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    evento.descricao,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Informações adicionais em chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.event_note,
                      evento.tipoEvento,
                      const Color(0xFF00324A),
                    ),
                    if (int.tryParse(evento.intensidadeDor) != null && int.tryParse(evento.intensidadeDor)! > 0)
                      _buildInfoChip(
                        Icons.favorite,
                        '${_getIntensidadeLabel(int.parse(evento.intensidadeDor))} (${evento.intensidadeDor}/10)',
                        _getIntensidadeColor(int.parse(evento.intensidadeDor)),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Botão de ação
                Row(
                  children: [
                    const Text(
                      'Toque para ver detalhes',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00324A), Color(0xFF00324A)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00324A).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver detalhes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  void _showEventoDetails(EventoClinico evento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventoDetailsModal(evento),
    );
  }

  Widget _buildEventoDetailsModal(EventoClinico evento) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 24,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.titulo.isNotEmpty ? evento.titulo : 'Detalhes do Evento',
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        evento.especialidade,
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações básicas
                  _buildDetailSection(
                    title: 'Informações do Registro',
                    icon: Icons.info_rounded,
                    children: [
                      _buildDetailRow('Especialidade', evento.especialidade),
                      _buildDetailRow('Data do Atendimento', _formatDate(evento.dataHora)),
                      _buildDetailRow('Médico Responsável', 'Dr. ${evento.especialidade.split(' ').first}'),
                      _buildDetailRow('Tipo da Consulta', evento.tipoEvento),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Descrição do registro, sintomas e intensidade da dor
                  if (evento.descricao.isNotEmpty || evento.sintomas.isNotEmpty || (int.tryParse(evento.intensidadeDor) != null && int.tryParse(evento.intensidadeDor)! > 0))
                    _buildDetailSection(
                      title: '',
                      icon: Icons.description_rounded,
                      children: [
                        if (evento.descricao.isNotEmpty) ...[
                          Text(
                            'Descrição do evento:',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            evento.descricao,
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (evento.sintomas.isNotEmpty || (int.tryParse(evento.intensidadeDor) != null && int.tryParse(evento.intensidadeDor)! > 0)) const SizedBox(height: 16),
                        ],
                        if (evento.sintomas.isNotEmpty) ...[
                          Text(
                            'Sintomas:',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            evento.sintomas,
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (int.tryParse(evento.intensidadeDor) != null && int.tryParse(evento.intensidadeDor)! > 0) const SizedBox(height: 16),
                        ],
                        if (int.tryParse(evento.intensidadeDor) != null && int.tryParse(evento.intensidadeDor)! > 0) ...[
                          Text(
                            'Intensidade da Dor:',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getIntensidadeColor(int.parse(evento.intensidadeDor)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_getIntensidadeLabel(int.parse(evento.intensidadeDor))} (${evento.intensidadeDor}/10)',
                                style: TextStyle(
                                  color: _getIntensidadeColor(int.parse(evento.intensidadeDor)),
                                  fontSize: 15,
                                  height: 1.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  
                  if (evento.alivio.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      title: 'Medicação/Alívio',
                      icon: Icons.medication_rounded,
                      children: [
                        Text(
                          evento.alivio,
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: const Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Fechar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.snackbar(
                        'Exportar PDF',
                        'Funcionalidade em desenvolvimento',
                        backgroundColor: const Color(0xFF1E3A8A),
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Exportar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }


}