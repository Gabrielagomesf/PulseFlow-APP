import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/patient.dart';
import '../config/app_config.dart';
import 'database_service.dart';
import 'encryption_service.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find<AuthService>();
  final _storage = const FlutterSecureStorage();
  final _token = ''.obs;
  final _isAuthenticated = false.obs;
  final _currentUser = Rxn<Patient>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final EncryptionService _encryptionService = EncryptionService();

  String get token => _token.value;
  bool get isAuthenticated => _isAuthenticated.value;
  Patient? get currentUser => _currentUser.value;

  // Inicialização do serviço
  Future<AuthService> init() async {
    await _checkAuthStatus();
    return this;
  }

  // Verifica se há um token válido
  Future<void> _checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        final patientId = JwtDecoder.decode(token)['sub'];
        final patient = await getPatientById(patientId);
        if (patient != null) {
          _currentUser.value = patient;
          _isAuthenticated.value = true;
        } else {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  // Gera token JWT
  String _generateToken(Patient patient) {
    if (patient.id == null) {
      throw 'ID do paciente não encontrado';
    }

    if (patient.id!.isEmpty) {
      throw 'ID do paciente está vazio';
    }

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 7)); // Token válido por 7 dias

    final payload = {
      'sub': patient.id,
      'email': patient.email,
      'name': patient.name,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    };

    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final encodedHeader = base64Url.encode(utf8.encode(json.encode(header)));
    final encodedPayload = base64Url.encode(utf8.encode(json.encode(payload)));
    
    // Usar JWT secret do .env ou uma chave padrão para desenvolvimento
    final jwtSecret = AppConfig.jwtSecret;
    
    final signature = Hmac(sha256, utf8.encode(jwtSecret))
        .convert(utf8.encode('$encodedHeader.$encodedPayload'))
        .bytes;
    final encodedSignature = base64Url.encode(signature);

    final token = '$encodedHeader.$encodedPayload.$encodedSignature';
    
    return token;
  }

  // Gera código 2FA de 6 dígitos
  String _generate2FACode() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  // Envia código 2FA por e-mail
  Future<void> send2FACodeEmail(String email, String code) async {
    try {
      final user = AppConfig.emailUser;
      final pass = AppConfig.emailPass;
      
      if (user.isEmpty || pass.isEmpty) {
        return;
      }
      
      final smtpServer = gmail(user, pass);
      final message = Message()
        ..from = Address(user, 'PulseFlow Saúde')
        ..recipients.add(email)
        ..subject = 'Código de verificação 2FA - PulseFlow'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background: linear-gradient(135deg, #1CB5E0 0%, #000046 100%); padding: 30px; border-radius: 15px; text-align: center;">
              <h1 style="color: white; margin: 0; font-size: 24px;">Verificação em Duas Etapas</h1>
              <p style="color: white; margin: 10px 0 0 0; opacity: 0.9;">PulseFlow Saúde</p>
            </div>
            
            <div style="background: white; padding: 30px; border-radius: 0 0 15px 15px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
              <h2 style="color: #333; margin: 0 0 20px 0;">Olá!</h2>
              <p style="color: #666; line-height: 1.6; margin: 0 0 20px 0;">
                Você solicitou acesso ao seu perfil no PulseFlow Saúde. Para continuar, use o código de verificação abaixo:
              </p>
              
              <div style="background: #f8f9fa; border: 2px dashed #1CB5E0; border-radius: 10px; padding: 20px; margin: 20px 0; text-align: center;">
                <h3 style="color: #1CB5E0; margin: 0; font-size: 32px; letter-spacing: 8px; font-weight: bold;">$code</h3>
                <p style="color: #666; margin: 10px 0 0 0; font-size: 14px;">Código de 6 dígitos</p>
              </div>
              
              <div style="background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 15px; margin: 20px 0;">
                <p style="color: #856404; margin: 0; font-size: 14px;">
                  ⏰ <strong>Importante:</strong> Este código expira em 5 minutos por segurança.
                </p>
              </div>
              
              <p style="color: #666; line-height: 1.6; margin: 20px 0 0 0; font-size: 14px;">
                Se você não solicitou este código, ignore este e-mail ou entre em contato conosco.
              </p>
              
              <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
              <p style="color: #999; font-size: 12px; text-align: center; margin: 0;">
                PulseFlow Saúde - Cuidando da sua saúde com tecnologia
              </p>
            </div>
          </div>
        ''';
      
      await send(message, smtpServer);
    } catch (e) {
      // Silenciosamente falha - o código ainda será mostrado nos logs para teste
    }
  }

  // Login com 2FA
  Future<String> loginWith2FA(String email, String password) async {
    try {
      final patient = await _databaseService.getPatientByEmail(email);
      if (patient == null) {
        throw 'Paciente não encontrado';
      }
      
      final isValidPassword = await _encryptionService.verifyPassword(
        password,
        patient.password,
      );
      if (!isValidPassword) {
        throw 'Senha incorreta';
      }
      
      final code = _generate2FACode();
      final expires = DateTime.now().add(const Duration(minutes: 5));
      
      final patientIdString = patient.id!;
      
      await _databaseService.setTwoFactorCode(patientIdString, code, expires);
      await send2FACodeEmail(patient.email, code);
      
      return patientIdString;
    } catch (e) {
      rethrow;
    }
  }

  // Valida o código 2FA e finaliza o login
  Future<Patient> verify2FACode(String patientId, String code) async {
    final isValid = await _databaseService.validateTwoFactorCode(patientId, code);
    if (!isValid) throw 'Código de verificação inválido ou expirado';
    final patient = await _databaseService.getPatientById(ObjectId.parse(patientId));
    if (patient == null) throw 'Paciente não encontrado';
    // Gera o token JWT e autentica
    final token = _generateToken(patient);
    await _storage.write(key: 'auth_token', value: token);
    _token.value = token;
    _isAuthenticated.value = true;
    _currentUser.value = patient;
    
    // Redireciona para tela de sucesso em vez da home
    Get.offAllNamed('/success');
    
    return patient;
  }

  // Reenvia código 2FA
  Future<void> resend2FACode(String patientId) async {
    try {
      final patient = await _databaseService.getPatientById(ObjectId.parse(patientId));
      if (patient == null) throw 'Paciente não encontrado';
      
      final code = _generate2FACode();
      final expires = DateTime.now().add(const Duration(minutes: 5));
      
      await _databaseService.setTwoFactorCode(patientId, code, expires);
      await send2FACodeEmail(patient.email, code);
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<Patient> login(String email, String password) async {
    try {
      final patient = await _databaseService.getPatientByEmail(email);
      
      if (patient == null) {
        throw 'Paciente não encontrado';
      }

      // Verifica a senha usando o serviço de criptografia
      final isValidPassword = await _encryptionService.verifyPassword(
        password,
        patient.password,
      );

      if (!isValidPassword) {
        throw 'Senha incorreta';
      }

      // Gera o token JWT
      final token = _generateToken(patient);
      await _storage.write(key: 'auth_token', value: token);
      
      _token.value = token;
      _isAuthenticated.value = true;
      _currentUser.value = patient;

      return patient;
    } catch (e) {
      _token.value = '';
      _isAuthenticated.value = false;
      _currentUser.value = null;
      rethrow;
    }
  }

  // Registro
  Future<Patient> register(Patient patient) async {
    try {
      // Verificar se o e-mail já existe
      final existingPatient = await _databaseService.getPatientByEmail(patient.email);
      if (existingPatient != null) {
        throw 'E-mail já cadastrado';
      }

      // Criptografar senha
      final hashedPassword = await _encryptionService.hashPassword(patient.password);
      
      // Cria uma nova instância com a senha criptografada
      final patientWithHashedPassword = Patient(
        name: patient.name,
        email: patient.email,
        password: hashedPassword,
        cpf: patient.cpf,
        rg: patient.rg,
        phone: patient.phone,
        secondaryPhone: patient.secondaryPhone,
        birthDate: patient.birthDate,
        gender: patient.gender,
        maritalStatus: patient.maritalStatus,
        nationality: patient.nationality,
        address: patient.address,
        acceptedTerms: patient.acceptedTerms,
      );

      // Salvar no banco de dados
      final createdPatient = await _databaseService.createPatient(patientWithHashedPassword);
      
      if (createdPatient.id == null || createdPatient.id!.isEmpty) {
        throw 'Erro ao criar paciente: ID não foi gerado';
      }

      // Gerar token JWT
      final token = _generateToken(createdPatient);
      await _storage.write(key: 'auth_token', value: token);
      
      _token.value = token;
      _isAuthenticated.value = true;
      _currentUser.value = createdPatient;

      return createdPatient;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      _token.value = '';
      _isAuthenticated.value = false;
      _currentUser.value = null;
    } catch (e) {
      rethrow;
    }
  }

  // Verificar autenticação
  bool checkAuth() {
    return _token.value.isNotEmpty && _isAuthenticated.value;
  }

  // Verifica se o token está expirado
  Future<bool> isTokenExpired() async {
    try {
      final storedToken = await _storage.read(key: 'auth_token');
      if (storedToken == null) return true;
      return JwtDecoder.isExpired(storedToken);
    } catch (e) {
      return true;
    }
  }

  // Atualiza dados do usuário
  Future<void> updateUserData(Patient updatedPatient) async {
    try {
      // Se a senha foi alterada, criptografa a nova senha
      String password = updatedPatient.password;
      if (currentUser?.password != updatedPatient.password) {
        password = await _encryptionService.hashPassword(updatedPatient.password);
      }

      // Cria uma nova instância com a senha criptografada
      final patientWithHashedPassword = Patient(
        id: updatedPatient.id,
        name: updatedPatient.name,
        email: updatedPatient.email,
        password: password,
        cpf: updatedPatient.cpf,
        rg: updatedPatient.rg,
        phone: updatedPatient.phone,
        secondaryPhone: updatedPatient.secondaryPhone,
        birthDate: updatedPatient.birthDate,
        gender: updatedPatient.gender,
        maritalStatus: updatedPatient.maritalStatus,
        nationality: updatedPatient.nationality,
        address: updatedPatient.address,
        acceptedTerms: updatedPatient.acceptedTerms,
      );

      if (updatedPatient.id != null) {
        await updatePatientData(ObjectId.parse(updatedPatient.id!), patientWithHashedPassword);
        _currentUser.value = patientWithHashedPassword;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Patient?> getPatientById(String patientId) async {
    try {
      final patient = await _databaseService.getPatientById(ObjectId.parse(patientId));
      return patient;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePatientData(ObjectId patientId, Patient updatedPatient) async {
    try {
      await _databaseService.updatePatient(
        patientId,
        updatedPatient,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verifica se o e-mail existe no sistema
  Future<Patient?> checkEmailExists(String email) async {
    try {
      return await _databaseService.getPatientByEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Envia código de redefinição de senha
  Future<void> sendPasswordResetCode(String email) async {
    try {
      final patient = await _databaseService.getPatientByEmail(email);
      if (patient == null) {
        throw 'E-mail não encontrado';
      }

      // Gerar código de redefinição
      final code = _generate2FACode();
      final expires = DateTime.now().add(const Duration(minutes: 10));
      
      // Salvar código no banco
      await _databaseService.setPasswordResetCode(patient.id!, code, expires);
      
      // Enviar e-mail
      await sendPasswordResetEmail(email, code);
    } catch (e) {
      rethrow;
    }
  }

  // Redefine a senha do usuário
  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      final patient = await _databaseService.getPatientByEmail(email);
      if (patient == null) {
        throw 'E-mail não encontrado';
      }

      // Validar código de redefinição
      final isValid = await _databaseService.validatePasswordResetCode(patient.id!, code);
      if (!isValid) {
        throw 'Código de redefinição inválido ou expirado';
      }

      // Criptografar nova senha
      final hashedPassword = await _encryptionService.hashPassword(newPassword);
      
      // Atualizar senha no banco
      await _databaseService.updatePatientPassword(patient.id!, hashedPassword);
    } catch (e) {
      rethrow;
    }
  }

  // Envia e-mail de redefinição de senha
  Future<void> sendPasswordResetEmail(String email, String code) async {
    try {
      final user = AppConfig.emailUser;
      final pass = AppConfig.emailPass;
      
      if (user.isEmpty || pass.isEmpty) {
        return;
      }

      final smtpServer = gmail(user, pass);
      final message = Message()
        ..from = Address(user, 'PulseFlow Saúde')
        ..recipients.add(email)
        ..subject = 'Redefinição de Senha - PulseFlow Saúde'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #f8f9fa; padding: 20px;">
            <div style="background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
              <div style="text-align: center; margin-bottom: 30px;">
                <div style="background-color: #1CB5E0; width: 60px; height: 60px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 20px;">
                  <span style="color: white; font-size: 24px;">🔐</span>
                </div>
                <h1 style="color: #222B45; margin: 0; font-size: 24px;">Redefinição de Senha</h1>
              </div>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 20px;">
                Olá! Você solicitou a redefinição da sua senha no PulseFlow Saúde.
              </p>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 30px;">
                Use o código abaixo para redefinir sua senha:
              </p>
              
              <div style="background-color: #1CB5E0; color: white; padding: 20px; border-radius: 10px; text-align: center; margin-bottom: 30px;">
                <h2 style="margin: 0; font-size: 32px; letter-spacing: 8px; font-family: monospace;">$code</h2>
              </div>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 20px;">
                <strong>Este código expira em 10 minutos.</strong>
              </p>
              
              <p style="color: #666; line-height: 1.6; margin-bottom: 20px;">
                Se você não solicitou esta redefinição, ignore este e-mail.
              </p>
              
              <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
              <p style="color: #999; font-size: 12px; text-align: center; margin: 0;">
                PulseFlow Saúde - Cuidando da sua saúde com tecnologia
              </p>
            </div>
          </div>
        ''';
      
      await send(message, smtpServer);
    } catch (e) {
      // Silenciosamente falha
    }
  }

  // Método para testar configuração de e-mail
  Future<void> testEmailConfiguration() async {
    try {
      final user = AppConfig.emailUser;
      final pass = AppConfig.emailPass;
      
      if (user.isEmpty || pass.isEmpty) {
        return;
      }
      
      final smtpServer = gmail(user, pass);
      final message = Message()
        ..from = Address(user, 'PulseFlow Saúde - Teste')
        ..recipients.add(user)
        ..subject = 'Teste de Configuração - PulseFlow'
        ..text = 'Este é um e-mail de teste para verificar se a configuração do Gmail está funcionando corretamente.';
      
      await send(message, smtpServer);
    } catch (e) {
      // Silenciosamente falha
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Inicialização do serviço, se necessário
  }

  @override
  void onClose() {
    // Limpeza de recursos, se necessário
    super.onClose();
  }
} 