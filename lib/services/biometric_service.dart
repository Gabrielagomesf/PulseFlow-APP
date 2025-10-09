import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService extends GetxService {
  static BiometricService get instance => Get.find<BiometricService>();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  final _isAvailable = false.obs;
  final _biometricType = BiometricType.fingerprint.obs;
  final _isEnabled = false.obs;
  
  bool get isAvailable => _isAvailable.value;
  BiometricType get biometricType => _biometricType.value;
  bool get isEnabled => _isEnabled.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _checkBiometricAvailability();
    await _loadBiometricSettings();
  }
  
  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      _isAvailable.value = isAvailable && isDeviceSupported;
      
      if (_isAvailable.value) {
        final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          _biometricType.value = availableBiometrics.first;
        }
      }
    } catch (e) {
      _isAvailable.value = false;
    }
  }
  
  Future<void> _loadBiometricSettings() async {
    try {
      final String? biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      _isEnabled.value = biometricEnabled == 'true';
    } catch (e) {
      _isEnabled.value = false;
    }
  }
  
  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Use sua biometria para continuar',
    String? cancelButton = 'Cancelar',
    String? goToSettingsButton = 'Configurações',
    String? goToSettingsDescription = 'Configure a autenticação biométrica',
  }) async {
    try {
      if (!_isAvailable.value) {
        Get.snackbar(
          'Erro',
          'Autenticação biométrica não disponível neste dispositivo',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return authenticated;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha na autenticação biométrica',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  Future<void> enableBiometricLogin(String email, String password) async {
    try {
      if (!_isAvailable.value) {
        throw Exception('Biometria não disponível');
      }
      
      bool authenticated = await authenticateWithBiometrics(
        localizedReason: 'Confirme sua identidade para habilitar login biométrico',
      );
      
      if (authenticated) {
        await _secureStorage.write(key: 'biometric_email', value: email);
        await _secureStorage.write(key: 'biometric_password', value: password);
        await _secureStorage.write(key: 'biometric_enabled', value: 'true');
        
        _isEnabled.value = true;
        
        Get.snackbar(
          'Sucesso',
          'Login biométrico habilitado com sucesso!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao habilitar login biométrico',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<Map<String, String>?> authenticateAndGetCredentials() async {
    try {
      if (!_isEnabled.value) {
        return null;
      }
      
      bool authenticated = await authenticateWithBiometrics(
        localizedReason: 'Use sua biometria para fazer login',
      );
      
      if (authenticated) {
        final String? email = await _secureStorage.read(key: 'biometric_email');
        final String? password = await _secureStorage.read(key: 'biometric_password');
        
        if (email != null && password != null) {
          return {
            'email': email,
            'password': password,
          };
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> disableBiometricLogin() async {
    try {
      bool authenticated = await authenticateWithBiometrics(
        localizedReason: 'Confirme sua identidade para desabilitar login biométrico',
      );
      
      if (authenticated) {
        await _secureStorage.delete(key: 'biometric_email');
        await _secureStorage.delete(key: 'biometric_password');
        await _secureStorage.write(key: 'biometric_enabled', value: 'false');
        
        _isEnabled.value = false;
        
        Get.snackbar(
          'Sucesso',
          'Login biométrico desabilitado',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao desabilitar login biométrico',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  String getBiometricTypeName() {
    switch (_biometricType.value) {
      case BiometricType.fingerprint:
        return 'Impressão Digital';
      case BiometricType.face:
        return 'Reconhecimento Facial';
      case BiometricType.iris:
        return 'Reconhecimento de Íris';
      case BiometricType.strong:
        return 'Autenticação Forte';
      case BiometricType.weak:
        return 'Autenticação Fraca';
      default:
        return 'Biometria';
    }
  }
  
  String getBiometricIcon() {
    switch (_biometricType.value) {
      case BiometricType.fingerprint:
        return '🔐';
      case BiometricType.face:
        return '👤';
      case BiometricType.iris:
        return '👁️';
      default:
        return '🔒';
    }
  }
  
  Future<bool> canUseDeviceCredentials() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
}
