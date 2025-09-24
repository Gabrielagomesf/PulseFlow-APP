import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/patient.dart';
import '../../models/enxaqueca.dart';
import '../../models/diabetes.dart';
import '../../models/crise_gastrite.dart';
import '../../models/evento_clinico.dart';
import '../../models/menstruacao.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  // Observáveis para os dados do paciente
  final _currentPatient = Rxn<Patient>();
  final _isLoading = false.obs;
  
  // Dados para atalhos
  final _hasEnxaqueca = false.obs;
  final _hasDiabetes = false.obs;
  final _hasCriseGastrite = false.obs;
  final _hasEventoClinico = false.obs;
  final _hasMenstruacao = false.obs;
  
  // Favoritos personalizáveis
  final _favoriteItems = <String>[].obs;
  
  // Dados para estatísticas
  final _enxaquecaData = <Enxaqueca>[].obs;
  final _diabetesData = <Diabetes>[].obs;
  final _gastriteData = <CriseGastrite>[].obs;
  final _eventoClinicoData = <EventoClinico>[].obs;
  final _menstruacaoData = <Menstruacao>[].obs;
  
  // Getters
  Patient? get currentPatient => _currentPatient.value;
  bool get isLoading => _isLoading.value;
  
  // Getters para atalhos
  bool get hasEnxaqueca => _hasEnxaqueca.value;
  bool get hasDiabetes => _hasDiabetes.value;
  bool get hasCriseGastrite => _hasCriseGastrite.value;
  bool get hasEventoClinico => _hasEventoClinico.value;
  bool get hasMenstruacao => _hasMenstruacao.value;
  
  // Getters para favoritos
  List<String> get favoriteItems => _favoriteItems;
  
  @override
  void onInit() {
    super.onInit();
    _loadPatientData();
    _loadAvailableData();
  }
  
  // Carrega os dados do paciente logado
  void _loadPatientData() {
    _currentPatient.value = _authService.currentUser;
  }
  
  // Carrega dados disponíveis do paciente
  Future<void> _loadAvailableData() async {
    if (currentPatient?.id == null) return;
    
    try {
      final patientId = currentPatient!.id!;
      
      // Carrega todos os dados do paciente
      final enxaquecas = await _databaseService.getEnxaquecasByPacienteId(patientId);
      final diabetes = await _databaseService.getDiabetesByPacienteId(patientId);
      final crisesGastrite = await _databaseService.getCrisesGastriteByPacienteId(patientId);
      final eventosClinicos = await _databaseService.getEventosClinicosByPacienteId(patientId);
      final menstruacoes = await _databaseService.getMenstruacoesByPacienteId(patientId);
      
      // Armazena os dados para estatísticas
      _enxaquecaData.value = enxaquecas;
      _diabetesData.value = diabetes;
      _gastriteData.value = crisesGastrite;
      _eventoClinicoData.value = eventosClinicos;
      _menstruacaoData.value = menstruacoes;
      
      // Verifica quais tipos de dados o paciente tem
      _hasEnxaqueca.value = enxaquecas.isNotEmpty;
      _hasDiabetes.value = diabetes.isNotEmpty;
      _hasCriseGastrite.value = crisesGastrite.isNotEmpty;
      _hasEventoClinico.value = eventosClinicos.isNotEmpty;
      _hasMenstruacao.value = menstruacoes.isNotEmpty;
      
      // Inicializa favoritos com dados disponíveis
      _updateFavoriteItems();
      
    } catch (e) {
      print('Erro ao carregar dados disponíveis: $e');
    }
  }

  // Atualiza os dados do paciente
  Future<void> refreshPatientData() async {
    _isLoading.value = true;
    try {
      // Recarrega os dados do usuário atual
      await _authService.init();
      _currentPatient.value = _authService.currentUser;
      await _loadAvailableData();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os dados do paciente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Obtém saudação baseada no horário
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom Dia,';
    } else if (hour < 18) {
      return 'Boa Tarde,';
    } else {
      return 'Boa Noite,';
    }
  }
  
  // Obtém o nome do paciente
  String getPatientName() {
    return currentPatient?.name ?? 'Usuário';
  }
  
  // Obtém a foto de perfil do paciente
  String? getProfilePhoto() {
    return currentPatient?.profilePhoto;
  }

  // Verifica se a foto é base64
  bool isBase64Photo(String? photo) {
    if (photo == null) return false;
    return photo.startsWith('data:image/');
  }

  // Atualiza lista de favoritos baseada nos dados disponíveis
  void _updateFavoriteItems() {
    final availableItems = <String>[];
    
    if (_hasEnxaqueca.value) availableItems.add('enxaqueca');
    if (_hasDiabetes.value) availableItems.add('diabetes');
    if (_hasCriseGastrite.value) availableItems.add('crise_gastrite');
    if (_hasEventoClinico.value) availableItems.add('evento_clinico');
    if (_hasMenstruacao.value) availableItems.add('menstruacao');
    
    // Se não há favoritos definidos, usa os primeiros 3 disponíveis
    if (_favoriteItems.isEmpty && availableItems.isNotEmpty) {
      _favoriteItems.value = availableItems.take(3).toList();
    }
  }

  // Adiciona item aos favoritos
  void addToFavorites(String item) {
    if (!_favoriteItems.contains(item) && _favoriteItems.length < 4) {
      _favoriteItems.add(item);
    }
  }

  // Remove item dos favoritos
  void removeFromFavorites(String item) {
    _favoriteItems.remove(item);
  }

  // Verifica se há dados disponíveis
  bool get hasAnyData {
    return _hasEnxaqueca.value || 
           _hasDiabetes.value || 
           _hasCriseGastrite.value || 
           _hasEventoClinico.value || 
           _hasMenstruacao.value;
  }

  // Calcula estatísticas para enxaqueca
  Map<String, dynamic> getEnxaquecaStats() {
    if (_enxaquecaData.isEmpty) return {};
    
    final intensidades = _enxaquecaData.map((e) => int.tryParse(e.intensidade) ?? 0).toList();
    final maior = intensidades.reduce((a, b) => a > b ? a : b);
    final menor = intensidades.reduce((a, b) => a < b ? a : b);
    final media = intensidades.reduce((a, b) => a + b) / intensidades.length;
    
    return {
      'maior': maior,
      'menor': menor,
      'media': media,
      'total': intensidades.length,
    };
  }

  // Calcula estatísticas para diabetes
  Map<String, dynamic> getDiabetesStats() {
    if (_diabetesData.isEmpty) return {};
    
    final glicoses = _diabetesData.map((d) => d.glicemia).toList();
    final maior = glicoses.reduce((a, b) => a > b ? a : b);
    final menor = glicoses.reduce((a, b) => a < b ? a : b);
    final media = glicoses.reduce((a, b) => a + b) / glicoses.length;
    
    return {
      'maior': maior,
      'menor': menor,
      'media': media,
      'total': glicoses.length,
    };
  }

  // Calcula estatísticas para gastrite
  Map<String, dynamic> getGastriteStats() {
    if (_gastriteData.isEmpty) return {};
    
    final intensidades = _gastriteData.map((g) => g.intensidadeDor).toList();
    final maior = intensidades.reduce((a, b) => a > b ? a : b);
    final menor = intensidades.reduce((a, b) => a < b ? a : b);
    final media = intensidades.reduce((a, b) => a + b) / intensidades.length;
    
    return {
      'maior': maior,
      'menor': menor,
      'media': media,
      'total': intensidades.length,
    };
  }

  // Calcula estatísticas para eventos clínicos
  Map<String, dynamic> getEventoClinicoStats() {
    if (_eventoClinicoData.isEmpty) return {};
    
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    
    final thisMonthEvents = _eventoClinicoData.where((e) {
      final eventDate = e.dataHora;
      return eventDate.isAfter(lastMonth) && eventDate.isBefore(thisMonth.add(const Duration(days: 31)));
    }).length;
    
    return {
      'total': _eventoClinicoData.length,
      'este_mes': thisMonthEvents,
    };
  }

  // Calcula estatísticas para menstruação
  Map<String, dynamic> getMenstruacaoStats() {
    if (_menstruacaoData.isEmpty) return {};
    
    final duracoes = _menstruacaoData.map((m) => m.duracaoEmDias).toList();
    final maior = duracoes.reduce((a, b) => a > b ? a : b);
    final menor = duracoes.reduce((a, b) => a < b ? a : b);
    final media = duracoes.reduce((a, b) => a + b) / duracoes.length;
    
    return {
      'maior': maior,
      'menor': menor,
      'media': media,
      'total': duracoes.length,
    };
  }


  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível fazer logout. Tente novamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 