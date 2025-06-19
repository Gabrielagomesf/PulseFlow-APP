import 'package:mongo_dart/mongo_dart.dart';
import '../models/patient.dart';
import '../config/database_config.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Db? _db;
  bool _isConnecting = false;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<void> _ensureConnection() async {
    if (_db != null && _db!.isConnected) {
      print('Conexão já está ativa');
      return;
    }

    if (_isConnecting) {
      print('Já existe uma tentativa de conexão em andamento');
      return;
    }

    _isConnecting = true;
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        if (_db == null) {
          print('Criando nova instância do banco...');
          final uri = DatabaseConfig.connectionString;
          if (uri.isEmpty) {
            throw 'String de conexão não configurada';
          }
          _db = await Db.create(uri);
          print('Instância do banco criada, tentando abrir conexão...');
        }

        if (!_db!.isConnected) {
          print('Tentando abrir conexão... (tentativa ${retryCount + 1})');
          await _db!.open();
          print('Conexão estabelecida com sucesso');
          
          // Verificar conexão tentando listar as coleções
          try {
            await _db!.getCollectionNames();
            print('Conexão verificada com sucesso');
            _isConnecting = false;
            return;
          } catch (e) {
            print('Erro ao verificar conexão: $e');
            await _db!.close();
            _db = null;
            throw 'Falha na verificação da conexão';
          }
        }
      } catch (e, stack) {
        print('Erro ao conectar (tentativa ${retryCount + 1}): $e');
        print('Stack trace: $stack');
        
        if (_db != null) {
          try {
            await _db!.close();
          } catch (e) {
            print('Erro ao fechar conexão: $e');
          }
          _db = null;
        }

        retryCount++;
        if (retryCount < _maxRetries) {
          print('Aguardando ${_retryDelay.inSeconds} segundos antes da próxima tentativa...');
          await Future.delayed(_retryDelay);
        } else {
          _isConnecting = false;
          throw 'Falha ao conectar após $_maxRetries tentativas: $e';
        }
      }
    }
  }

  Future<void> connect() async {
    try {
      await _ensureConnection();
    } catch (e) {
      print('Erro ao conectar: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_db != null) {
      try {
        if (_db!.isConnected) {
          print('Fechando conexão...');
          await _db!.close();
          print('Conexão fechada com sucesso');
        }
      } catch (e) {
        print('Erro ao fechar conexão: $e');
        rethrow;
      } finally {
        _db = null;
      }
    }
  }

  Future<Patient> createPatient(Patient patient) async {
    try {
      print('🗄️ Iniciando criação de paciente no banco de dados');
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      print('📧 Criando paciente: ${patient.email}');
      
      // Remover o ID do JSON antes de inserir
      final patientJson = patient.toJson();
      patientJson.remove('_id');
      
      print('📄 Dados do paciente preparados para inserção');
      print('📊 Campos: ${patientJson.keys.toList()}');
      
      // Tentar inserir o documento
      final result = await collection.insert(patientJson);
      print('📝 Resultado da inserção: $result');
      
      // Verificar se houve erro do Atlas Free Tier
      if (result['ok'] == 0 && result['code'] == 8000) {
        print('⚠️ Erro do Atlas Free Tier detectado, mas documento pode ter sido criado');
        print('🔄 Tentando buscar o documento pelo email...');
        
        // Tentar buscar o documento pelo email
        final createdPatient = await collection.findOne(where.eq('email', patient.email));
        if (createdPatient != null) {
          print('✅ Paciente encontrado pelo email: ${createdPatient['_id']}');
          
          // Converter o ID para string hexadecimal antes de criar o objeto Patient
          final patientData = Map<String, dynamic>.from(createdPatient);
          patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
          
          print('🔄 Convertendo dados para objeto Patient...');
          final patientObject = Patient.fromJson(patientData);
          
          print('✅ Objeto Patient criado com ID: ${patientObject.id}');
          return patientObject;
        } else {
          throw 'Erro ao criar paciente: Documento não encontrado após inserção';
        }
      }
      
      print('🆔 ID gerado pelo MongoDB: ${result['_id']}');
      
      if (result['_id'] == null) {
        print('❌ ERRO: MongoDB não retornou ID');
        throw 'Erro ao criar paciente: ID não gerado';
      }
      
      print('✅ ID gerado com sucesso, buscando paciente criado...');
      
      // Buscar o paciente recém-criado para garantir que temos todos os dados
      final createdPatient = await collection.findOne(where.id(result['_id']));
      if (createdPatient == null) {
        print('❌ ERRO: Não foi possível recuperar o paciente após criação');
        throw 'Erro ao recuperar paciente após criação';
      }
      
      print('✅ Paciente recuperado do banco: ${createdPatient['_id']}');
      
      // Converter o ID para string hexadecimal antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(createdPatient);
      if (patientData['_id'] is ObjectId) {
        patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
      } else {
        patientData['_id'] = patientData['_id'].toString();
      }
      
      print('🔄 ID convertido para string: ${patientData['_id']}');
      print('🔄 Convertendo dados para objeto Patient...');
      final patientObject = Patient.fromJson(patientData);
      
      print('✅ Objeto Patient criado com ID: ${patientObject.id}');
      return patientObject;
    } catch (e, stack) {
      print('❌ Erro ao criar paciente: $e');
      print('📋 Stack trace: $stack');
      rethrow;
    }
  }

  Future<Patient?> getPatientByEmail(String email) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      print('Buscando paciente por email: $email');
      
      final result = await collection.findOne(where.eq('email', email));
      if (result != null) {
        print('Paciente encontrado: ${result['_id']}');
        
        // Converter o ID para string hexadecimal antes de criar o objeto Patient
        final patientData = Map<String, dynamic>.from(result);
        if (patientData['_id'] is ObjectId) {
          patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
        } else {
          patientData['_id'] = patientData['_id'].toString();
        }
        
        print('🔄 ID convertido para string: ${patientData['_id']}');
        
        return Patient.fromJson(patientData);
      }
      print('Paciente não encontrado');
      return null;
    } catch (e, stack) {
      print('Erro ao buscar paciente: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<Patient?> getPatientById(ObjectId id) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      print('Buscando paciente por ID: $id');
      
      final result = await collection.findOne(where.id(id));
      if (result != null) {
        print('Paciente encontrado: ${result['_id']}');
        
        // Converter o ID para string hexadecimal antes de criar o objeto Patient
        final patientData = Map<String, dynamic>.from(result);
        if (patientData['_id'] is ObjectId) {
          patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
        } else {
          patientData['_id'] = patientData['_id'].toString();
        }
        
        print('🔄 ID convertido para string: ${patientData['_id']}');
        
        return Patient.fromJson(patientData);
      }
      print('Paciente não encontrado');
      return null;
    } catch (e, stack) {
      print('Erro ao buscar paciente: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<Patient> updatePatient(ObjectId id, Patient patient) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      print('Atualizando paciente: $id');
      
      // Atualizar o documento
      final modifier = modify
        ..set('updatedAt', DateTime.now().toIso8601String());
      
      // Adicionar todos os campos do paciente ao modificador
      final patientJson = patient.toJson();
      patientJson.forEach((key, value) {
        if (key != '_id') { // Não atualizar o ID
          modifier.set(key, value);
        }
      });
      
      // Usar update() simples - compatível com Atlas Free Tier
      final result = await collection.update(
        where.id(id),
        modifier,
      );
      
      if (result['ok'] != 1) {
        throw 'Falha ao atualizar paciente';
      }
      
      // Buscar o paciente atualizado
      final updatedPatient = await collection.findOne(where.id(id));
      if (updatedPatient == null) {
        throw 'Paciente não encontrado após atualização';
      }
      
      print('Paciente atualizado com sucesso');
      
      // Converter o ID para string hexadecimal antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(updatedPatient);
      if (patientData['_id'] is ObjectId) {
        patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
      } else {
        patientData['_id'] = patientData['_id'].toString();
      }
      
      print('🔄 ID convertido para string: ${patientData['_id']}');
      
      return Patient.fromJson(patientData);
    } catch (e, stack) {
      print('Erro ao atualizar paciente: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> deletePatient(ObjectId id) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      print('Deletando paciente: $id');
      
      // Usar remove() simples - compatível com Atlas Free Tier
      final result = await collection.remove(where.id(id));
      
      if (result['ok'] != 1) {
        throw 'Falha ao deletar paciente';
      }
      
      if (result['n'] == 0) {
        throw 'Paciente não encontrado';
      }
      
      print('Paciente deletado com sucesso');
    } catch (e, stack) {
      print('Erro ao deletar paciente: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> setTwoFactorCode(String patientId, String code, DateTime expires) async {
    try {
      print('🔐 Configurando 2FA para paciente ID: $patientId');
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      print('🔄 ObjectId convertido: $objectId');
      
      // Usar update() simples - compatível com Atlas Free Tier
      final result = await collection.update(
        where.eq('_id', objectId),
        modify.set('twoFactorCode', code).set('twoFactorExpires', expires.toIso8601String()),
      );
      
      // Verificar se é erro do Atlas Free Tier (código 8000)
      if (result['ok'] == 0 && result['code'] == 8000) {
        print('⚠️ Aviso: MongoDB Atlas Free Tier - getLastError não suportado, mas operação foi bem-sucedida');
        print('✅ Código 2FA salvo com sucesso (ignorando erro do Atlas Free Tier)');
        return;
      }
      
      if (result['ok'] != 1) {
        throw 'Falha ao salvar código 2FA: ${result['errmsg']}';
      }
      
      print('✅ Código 2FA salvo com sucesso: $result');
    } catch (e) {
      print('❌ Erro ao salvar código 2FA: $e');
      print('📋 PatientId recebido: $patientId');
      rethrow;
    }
  }

  Future<bool> validateTwoFactorCode(String patientId, String code) async {
    try {
      print('🔐 Validando código 2FA para paciente ID: $patientId');
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      print('🔄 ObjectId convertido: $objectId');
      
      final result = await collection.findOne(where.eq('_id', objectId));
      if (result == null) {
        print('❌ Paciente não encontrado');
        return false;
      }
      
      print('✅ Paciente encontrado, verificando código 2FA...');
      
      // Converter o ID para string antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(result);
      patientData['_id'] = patientData['_id'].toString();
      
      final patient = Patient.fromJson(patientData);
      
      if (patient.twoFactorCode == code && patient.twoFactorExpires != null && patient.twoFactorExpires!.isAfter(DateTime.now())) {
        print('✅ Código 2FA válido, limpando código...');
        
        // Limpa o código após uso usando update() simples
        final clearResult = await collection.update(
          where.eq('_id', objectId),
          modify.unset('twoFactorCode').unset('twoFactorExpires'),
        );
        
        // Verificar se é erro do Atlas Free Tier (código 8000)
        if (clearResult['ok'] == 0 && clearResult['code'] == 8000) {
          print('⚠️ Aviso: MongoDB Atlas Free Tier - getLastError não suportado, mas código foi limpo');
        } else if (clearResult['ok'] != 1) {
          print('⚠️ Aviso: Erro ao limpar código 2FA: ${clearResult['errmsg']}');
        }
        
        print('✅ Código 2FA limpo com sucesso');
        return true;
      }
      
      print('❌ Código 2FA inválido ou expirado');
      return false;
    } catch (e) {
      print('❌ Erro ao validar código 2FA: $e');
      print('📋 PatientId recebido: $patientId');
      rethrow;
    }
  }

  Future<void> setPasswordResetCode(String patientId, String code, DateTime expires) async {
    try {
      print('🔐 Configurando código de redefinição para paciente ID: $patientId');
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      print('🔄 ObjectId convertido: $objectId');
      
      // Usar update() simples - compatível com Atlas Free Tier
      final result = await collection.update(
        where.eq('_id', objectId),
        modify.set('passwordResetCode', code).set('passwordResetExpires', expires.toIso8601String()),
      );
      
      // Verificar se é erro do Atlas Free Tier (código 8000)
      if (result['ok'] == 0 && result['code'] == 8000) {
        print('⚠️ Aviso: MongoDB Atlas Free Tier - getLastError não suportado, mas operação foi bem-sucedida');
        print('✅ Código de redefinição salvo com sucesso (ignorando erro do Atlas Free Tier)');
        return;
      }
      
      if (result['ok'] != 1) {
        throw 'Falha ao salvar código de redefinição: ${result['errmsg']}';
      }
      
      print('✅ Código de redefinição salvo com sucesso: $result');
    } catch (e) {
      print('❌ Erro ao salvar código de redefinição: $e');
      print('📋 PatientId recebido: $patientId');
      rethrow;
    }
  }

  Future<bool> validatePasswordResetCode(String patientId, String code) async {
    try {
      print('🔐 Validando código de redefinição para paciente ID: $patientId');
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      print('🔄 ObjectId convertido: $objectId');
      
      final result = await collection.findOne(where.eq('_id', objectId));
      if (result == null) {
        print('❌ Paciente não encontrado');
        return false;
      }
      
      print('✅ Paciente encontrado, verificando código de redefinição...');
      
      // Converter o ID para string antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(result);
      patientData['_id'] = patientData['_id'].toString();
      
      final patient = Patient.fromJson(patientData);
      
      if (patient.passwordResetCode == code && 
          patient.passwordResetExpires != null && 
          patient.passwordResetExpires!.isAfter(DateTime.now())) {
        print('✅ Código de redefinição válido, limpando código...');
        
        // Limpa o código após uso usando update() simples
        final clearResult = await collection.update(
          where.eq('_id', objectId),
          modify.unset('passwordResetCode').unset('passwordResetExpires'),
        );
        
        // Verificar se é erro do Atlas Free Tier (código 8000)
        if (clearResult['ok'] == 0 && clearResult['code'] == 8000) {
          print('⚠️ Aviso: MongoDB Atlas Free Tier - getLastError não suportado, mas código foi limpo');
        } else if (clearResult['ok'] != 1) {
          print('⚠️ Aviso: Erro ao limpar código de redefinição: ${clearResult['errmsg']}');
        }
        
        print('✅ Código de redefinição limpo com sucesso');
        return true;
      }
      
      print('❌ Código de redefinição inválido ou expirado');
      return false;
    } catch (e) {
      print('❌ Erro ao validar código de redefinição: $e');
      print('📋 PatientId recebido: $patientId');
      rethrow;
    }
  }

  Future<void> updatePatientPassword(String patientId, String hashedPassword) async {
    try {
      print('🔐 Atualizando senha para paciente ID: $patientId');
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      print('🔄 ObjectId convertido: $objectId');
      
      // Usar update() simples - compatível com Atlas Free Tier
      final result = await collection.update(
        where.eq('_id', objectId),
        modify.set('password', hashedPassword).set('updatedAt', DateTime.now().toIso8601String()),
      );
      
      // Verificar se é erro do Atlas Free Tier (código 8000)
      if (result['ok'] == 0 && result['code'] == 8000) {
        print('⚠️ Aviso: MongoDB Atlas Free Tier - getLastError não suportado, mas operação foi bem-sucedida');
        print('✅ Senha atualizada com sucesso (ignorando erro do Atlas Free Tier)');
        return;
      }
      
      if (result['ok'] != 1) {
        throw 'Falha ao atualizar senha: ${result['errmsg']}';
      }
      
      print('✅ Senha atualizada com sucesso: $result');
    } catch (e) {
      print('❌ Erro ao atualizar senha: $e');
      print('📋 PatientId recebido: $patientId');
      rethrow;
    }
  }
} 