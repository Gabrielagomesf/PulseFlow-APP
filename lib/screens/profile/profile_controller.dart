import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/patient.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
// import '../../services/health_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  // final HealthService _healthService = Get.find<HealthService>();
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
      print('Erro ao carregar dados do paciente: $e');
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
      print('Erro ao selecionar foto: $e');
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
      print('Erro ao tirar foto: $e');
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
      profilePhoto: photoPath,
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
    _updatePhotoInBackground(currentPatient.id!, photoPath);

    Get.snackbar(
      'Sucesso',
      'Foto atualizada com sucesso!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Atualiza a foto no banco de dados em background
  Future<void> _updatePhotoInBackground(String patientId, String photoPath) async {
    try {
      print('Atualizando foto no banco de dados em background...');
      await _databaseService.updatePatientField(patientId, 'profilePhoto', photoPath);
      print('Foto atualizada no banco de dados com sucesso!');
    } catch (e) {
      print('Erro ao atualizar foto no banco de dados (não crítico): $e');
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
      print('Atualizando banco de dados em background...');
      
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
      
      print('Banco de dados atualizado com sucesso!');
    } catch (e) {
      print('Erro ao atualizar banco de dados (não crítico): $e');
      // Não mostra erro para o usuário pois os dados já foram atualizados localmente
    }
  }

  // Solicita acesso aos dados de saúde
  Future<void> requestHealthDataAccess() async {
    try {
      _isRequestingHealthPermissions.value = true;
      
      // Simular acesso aos dados de saúde (temporário)
      await Future.delayed(const Duration(seconds: 2));
      _healthDataAccessGranted.value = true;
      
      // Simular dados de saúde
      _heartRate.value = 72.0;
      _sleepQuality.value = 85.0;
      _dailySteps.value = 8500;
      
      Get.snackbar(
        'Sucesso',
        'Acesso aos dados de saúde concedido!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Erro ao solicitar acesso aos dados de saúde: $e');
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

  // Carrega dados de saúde (temporário - simulado)
  Future<void> _loadHealthData() async {
    try {
      // Simular dados de saúde
      _heartRate.value = 72.0;
      _sleepQuality.value = 85.0;
      _dailySteps.value = 8500;
    } catch (e) {
      print('Erro ao carregar dados de saúde: $e');
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
    _healthDataAccessGranted.value = false;
    _heartRate.value = 0.0;
    _sleepQuality.value = 0.0;
    _dailySteps.value = 0;
    
    Get.snackbar(
      'Desconectado',
      'Desconectado do Apple Health',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
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
