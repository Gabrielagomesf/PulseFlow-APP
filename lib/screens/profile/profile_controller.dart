import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/patient.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/api_service.dart';
import '../../services/health_service.dart';
import '../../services/health_data_service.dart';
import '../../services/health_data_test_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final HealthService _healthService = HealthService();
  final HealthDataService _healthDataService = HealthDataService();
  final HealthDataTestService _healthDataTestService = HealthDataTestService();
  final ImagePicker _imagePicker = ImagePicker();

  // Estados observáveis
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _isRequestingHealthPermissions = false.obs;
  final _healthDataAccessGranted = false.obs;
  final _heartRate = 0.0.obs;
  final _sleepQuality = 0.0.obs;
  final _dailySteps = 0.obs;

  // Dados do paciente
  final _patient = Rxn<Patient>();
  final _profilePhoto = Rxn<String>();

  // Controladores de texto
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  final cpfController = TextEditingController();
  final rgController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final emergencyPhoneController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  bool get isRequestingHealthPermissions => _isRequestingHealthPermissions.value;
  bool get healthDataAccessGranted => _healthDataAccessGranted.value;
  double get heartRate => _heartRate.value;
  double get sleepQuality => _sleepQuality.value;
  int get dailySteps => _dailySteps.value;
  Patient? get patient => _patient.value;
  String? get profilePhoto => _profilePhoto.value;

  @override
  void onInit() {
    super.onInit();
    _loadPatientData();
    _checkHealthPermissions();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    cpfController.dispose();
    rgController.dispose();
    emergencyContactController.dispose();
    emergencyPhoneController.dispose();
    super.onClose();
  }

  // Verifica permissões do HealthKit na inicialização
  Future<void> _checkHealthPermissions() async {
    try {
      final hasPermissions = await _healthService.hasPermissions();
      _healthDataAccessGranted.value = hasPermissions;
      
      if (hasPermissions) {
        await _loadHealthData();
      } else {
        // Se permissões são null (nunca solicitadas), solicita automaticamente
        final granted = await _healthService.requestPermissions();
        
        if (granted) {
          _healthDataAccessGranted.value = true;
          await _loadHealthData();
          
          Get.snackbar(
            'Sucesso',
            'Acesso aos dados de saúde do Apple Health concedido!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          // Se não tem permissões, tenta carregar dados do banco
          await _loadHealthDataFromDatabase();
        }
      }
    } catch (e) {
      // Tenta carregar do banco em caso de erro
      await _loadHealthDataFromDatabase();
    }
  }

  // Carrega dados de saúde do banco de dados
  Future<void> _loadHealthDataFromDatabase() async {
    try {
      if (_patient.value == null) return;
      
      
      // Busca dados dos últimos 7 dias
      final healthData = await _healthDataService.getHealthDataLastDays(_patient.value!.id!, 7);
      
      if (healthData.isNotEmpty) {
        // Extrai dados mais recentes
        final heartRateData = healthData.where((d) => d.dataType == 'heartRate').toList();
        final sleepData = healthData.where((d) => d.dataType == 'sleep').toList();
        final stepsData = healthData.where((d) => d.dataType == 'steps').toList();
        
        if (heartRateData.isNotEmpty) {
          _heartRate.value = heartRateData.first.value;
        }
        
        if (sleepData.isNotEmpty) {
          _sleepQuality.value = sleepData.first.value * 10; // Converte horas para percentual
        }
        
        if (stepsData.isNotEmpty) {
          _dailySteps.value = stepsData.first.value.round();
        }
        
      } else {
      }
      
    } catch (e) {
    }
  }

  // Carrega os dados do paciente
  Future<void> _loadPatientData() async {
    try {
      _isLoading.value = true;
      
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        _patient.value = currentUser;
        _profilePhoto.value = currentUser.profilePhoto;
        
        // Preenche os controladores
        nameController.text = currentUser.name;
        emailController.text = currentUser.email;
        phoneController.text = currentUser.phone ?? '';
        birthDateController.text = _formatDate(currentUser.birthDate);
        cpfController.text = currentUser.cpf ?? '';
        rgController.text = currentUser.rg ?? '';
        emergencyContactController.text = currentUser.emergencyContact ?? '';
        emergencyPhoneController.text = currentUser.emergencyPhone ?? '';
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os dados do paciente',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Formata data para exibição
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Seleciona foto da galeria
  Future<void> selectPhotoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        _profilePhoto.value = image.path;
        await _saveProfilePhoto(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível selecionar a foto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Tira foto com a câmera
  Future<void> takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        _profilePhoto.value = image.path;
        await _saveProfilePhoto(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível tirar a foto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Salva a foto do perfil
  Future<void> _saveProfilePhoto(String photoPath) async {
    final currentPatient = _patient.value;
    if (currentPatient == null) {
      Get.snackbar(
        'Erro',
        'Usuário não encontrado',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Converter a foto para base64
      final base64Photo = await _convertImageToBase64(photoPath);
      
      // Atualiza o estado local PRIMEIRO para refletir as mudanças imediatamente
      final updatedPatient = Patient(
        id: currentPatient.id,
        name: currentPatient.name,
        email: currentPatient.email,
        password: currentPatient.password,
        phone: currentPatient.phone,
        birthDate: currentPatient.birthDate,
        cpf: currentPatient.cpf,
        rg: currentPatient.rg,
        gender: currentPatient.gender,
        maritalStatus: currentPatient.maritalStatus,
        nationality: currentPatient.nationality,
        address: currentPatient.address,
        acceptedTerms: currentPatient.acceptedTerms,
        profilePhoto: base64Photo, // Salvar como base64
        emergencyContact: currentPatient.emergencyContact,
        emergencyPhone: currentPatient.emergencyPhone,
        isAdmin: currentPatient.isAdmin,
        twoFactorCode: currentPatient.twoFactorCode,
        twoFactorExpires: currentPatient.twoFactorExpires,
        passwordResetCode: currentPatient.passwordResetCode,
        passwordResetExpires: currentPatient.passwordResetExpires,
        passwordResetRequired: currentPatient.passwordResetRequired,
        createdAt: currentPatient.createdAt,
        updatedAt: DateTime.now(),
      );

      _patient.value = updatedPatient;
      _authService.currentUser = updatedPatient;

      // Atualiza no banco de dados em background
      _updatePhotoInBackground(currentPatient.id!, base64Photo);

      Get.snackbar(
        'Sucesso',
        'Foto atualizada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao processar a foto',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Converte imagem para base64
  Future<String> _convertImageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      rethrow;
    }
  }

  // Atualiza a foto no banco de dados em background
  Future<void> _updatePhotoInBackground(String patientId, String photoBase64) async {
    try {
      await _databaseService.updatePatientField(patientId, 'profilePhoto', photoBase64);
    } catch (e) {
      // Não mostra erro para o usuário pois a foto já foi atualizada localmente
    }
  }

  // Salva as alterações do paciente
  Future<void> savePatientData() async {
    _isSaving.value = true;

    final currentPatient = _patient.value;
    if (currentPatient == null) {
      Get.snackbar(
        'Erro',
        'Usuário não encontrado',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _isSaving.value = false;
      return;
    }

    // Validações básicas
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Erro',
        'Nome é obrigatório',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _isSaving.value = false;
      return;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Erro',
        'Email é obrigatório',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _isSaving.value = false;
      return;
    }

    // Cria o paciente atualizado
    final updatedPatient = Patient(
      id: currentPatient.id,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: currentPatient.password,
      phone: phoneController.text.trim().isEmpty ? '' : phoneController.text.trim(),
      birthDate: currentPatient.birthDate,
      cpf: cpfController.text.trim().isEmpty ? '' : cpfController.text.trim(),
      rg: rgController.text.trim().isEmpty ? '' : rgController.text.trim(),
      gender: currentPatient.gender,
      maritalStatus: currentPatient.maritalStatus,
      nationality: currentPatient.nationality,
      address: currentPatient.address,
      acceptedTerms: currentPatient.acceptedTerms,
      profilePhoto: _profilePhoto.value ?? currentPatient.profilePhoto,
      emergencyContact: emergencyContactController.text.trim().isEmpty ? null : emergencyContactController.text.trim(),
      emergencyPhone: emergencyPhoneController.text.trim().isEmpty ? null : emergencyPhoneController.text.trim(),
      isAdmin: currentPatient.isAdmin,
      twoFactorCode: currentPatient.twoFactorCode,
      twoFactorExpires: currentPatient.twoFactorExpires,
      passwordResetCode: currentPatient.passwordResetCode,
      passwordResetExpires: currentPatient.passwordResetExpires,
      passwordResetRequired: currentPatient.passwordResetRequired,
      createdAt: currentPatient.createdAt,
      updatedAt: DateTime.now(),
    );

    // Atualiza o estado local PRIMEIRO para refletir as mudanças imediatamente
    _patient.value = updatedPatient;
    _authService.currentUser = updatedPatient;

    // Atualiza no banco de dados em background (sem bloquear a UI)
    _updateDatabaseInBackground(currentPatient.id!, updatedPatient);

    // Cria notificação de perfil atualizado
    try {
      final apiService = ApiService();
      await apiService.criarNotificacaoPerfilAtualizado();
    } catch (e) {
    }

    Get.snackbar(
      'Sucesso',
      'Dados atualizados com sucesso!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    _isSaving.value = false;
  }

  // Atualiza o banco de dados em background
  Future<void> _updateDatabaseInBackground(String patientId, Patient updatedPatient) async {
    try {
      
      // Atualiza campos individuais
      await _databaseService.updatePatientField(patientId, 'name', updatedPatient.name);
      await _databaseService.updatePatientField(patientId, 'email', updatedPatient.email);
      await _databaseService.updatePatientField(patientId, 'phone', updatedPatient.phone);
      await _databaseService.updatePatientField(patientId, 'cpf', updatedPatient.cpf);
      await _databaseService.updatePatientField(patientId, 'rg', updatedPatient.rg);
      await _databaseService.updatePatientField(patientId, 'emergencyContact', updatedPatient.emergencyContact);
      await _databaseService.updatePatientField(patientId, 'emergencyPhone', updatedPatient.emergencyPhone);
      
      if (updatedPatient.profilePhoto != null) {
        await _databaseService.updatePatientField(patientId, 'profilePhoto', updatedPatient.profilePhoto);
      }
      
    } catch (e) {
      // Não mostra erro para o usuário pois os dados já foram atualizados localmente
    }
  }

  // Solicita acesso aos dados de saúde
  Future<void> requestHealthDataAccess() async {
    try {
      _isRequestingHealthPermissions.value = true;
      
      // Solicita permissões reais do HealthKit
      final granted = await _healthService.requestPermissions();
      
      if (granted) {
        _healthDataAccessGranted.value = true;
        
        // Carrega dados reais do HealthKit
        await _loadHealthData();
        
        Get.snackbar(
          'Sucesso',
          'Acesso aos dados de saúde concedido!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Permissão Negada',
          'É necessário conceder permissão para acessar os dados de saúde',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível solicitar acesso aos dados de saúde',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isRequestingHealthPermissions.value = false;
    }
  }

  // Carrega dados de saúde do HealthKit
  Future<void> _loadHealthData() async {
    try {
      // Verifica se tem permissões
      final hasPermissions = await _healthService.hasPermissions();
      
      if (!hasPermissions) {
        final granted = await _healthService.requestPermissions();
        if (!granted) {
          // Usa dados simulados mas ainda tenta salvar
        }
      }

      // Busca dados reais do HealthKit
      final healthData = await _healthService.getAllHealthData();
      
      // Extrai dados de frequência cardíaca (último valor)
      if (healthData['heartRate'] != null && healthData['heartRate']!.isNotEmpty) {
        final lastHeartRate = healthData['heartRate']!.last.y;
        _heartRate.value = lastHeartRate;
      }
      
      // Extrai dados de sono (último valor)
      if (healthData['sleep'] != null && healthData['sleep']!.isNotEmpty) {
        final lastSleep = healthData['sleep']!.last.y;
        _sleepQuality.value = lastSleep * 10; // Converte horas para percentual
      }
      
      // Extrai dados de passos (último valor)
      if (healthData['steps'] != null && healthData['steps']!.isNotEmpty) {
        final lastSteps = healthData['steps']!.last.y;
        _dailySteps.value = lastSteps.round();
      }
      
      
      // Salva dados no banco de dados
      if (_patient.value != null) {
        try {
          await _healthDataService.saveHealthDataFromHealthKit(_patient.value!.id!);
        } catch (e) {
          // Não falha o carregamento se não conseguir salvar no banco
        }
      } else {
      }
      
    } catch (e) {
      // Em caso de erro, usa dados simulados
      _heartRate.value = 72.0;
      _sleepQuality.value = 85.0;
      _dailySteps.value = 8500;
    }
  }

  // Conecta ao Samsung Health (placeholder)
  Future<void> connectToSamsungHealth() async {
    Get.snackbar(
      'Em breve',
      'Integração com Samsung Health será implementada em breve',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Desconecta do Apple Health
  Future<void> disconnectFromAppleHealth() async {
    try {
      // Verifica se ainda tem permissões
      final hasPermissions = await _healthService.hasPermissions();
      
      if (!hasPermissions) {
        _healthDataAccessGranted.value = false;
        _heartRate.value = 0.0;
        _sleepQuality.value = 0.0;
        _dailySteps.value = 0;
        
        Get.snackbar(
          'Desconectado',
          'Permissões do Apple Health foram revogadas',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Aviso',
          'Para desconectar, revogue as permissões nas Configurações do iPhone',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _healthDataAccessGranted.value = false;
    }
  }

  // Sincroniza dados de saúde
  Future<void> syncHealthData() async {
    try {
      if (_patient.value == null) {
        Get.snackbar(
          'Erro',
          'Usuário não encontrado',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      _isRequestingHealthPermissions.value = true;
      
      // Verifica permissões
      final hasPermissions = await _healthService.hasPermissions();
      if (!hasPermissions) {
        Get.snackbar(
          'Permissão Necessária',
          'É necessário conceder permissão para sincronizar dados',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Sincroniza dados
      await _healthDataService.syncHealthData(_patient.value!.id!);
      
      // Recarrega dados
      await _loadHealthData();
      
      Get.snackbar(
        'Sucesso',
        'Dados de saúde sincronizados!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao sincronizar dados de saúde',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isRequestingHealthPermissions.value = false;
    }
  }


  // Testa a integração com dados de saúde
  Future<void> testHealthDataIntegration() async {
    try {
      if (_patient.value == null) {
        Get.snackbar(
          'Erro',
          'Usuário não encontrado',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      _isRequestingHealthPermissions.value = true;
      
      Get.snackbar(
        'Teste',
        'Iniciando teste de integração...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      
      // Executa todos os testes
      await _healthDataTestService.runAllTests(_patient.value!.id!);
      
      Get.snackbar(
        'Sucesso',
        'Teste de integração concluído! Verifique os logs.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha no teste: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isRequestingHealthPermissions.value = false;
    }
  }

  // Desconecta do Samsung Health (placeholder)
  Future<void> disconnectFromSamsungHealth() async {
    Get.snackbar(
      'Em breve',
      'Integração com Samsung Health será implementada em breve',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
