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
      return;
    }

    if (_isConnecting) {
      return;
    }

    _isConnecting = true;
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        if (_db == null) {
          final uri = DatabaseConfig.connectionString;
          if (uri.isEmpty) {
            throw 'String de conexão não configurada';
          }
          _db = await Db.create(uri);
        }

        if (!_db!.isConnected) {
          await _db!.open();
          
          // Verificar conexão tentando listar as coleções
          try {
            await _db!.getCollectionNames();
            _isConnecting = false;
            return;
          } catch (e) {
            await _db!.close();
            _db = null;
            throw 'Falha na verificação da conexão';
          }
        }
      } catch (e, stack) {
        if (_db != null) {
          try {
            await _db!.close();
          } catch (e) {
            // Ignorar erro ao fechar
          }
          _db = null;
        }

        retryCount++;
        if (retryCount < _maxRetries) {
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
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_db != null) {
      try {
        if (_db!.isConnected) {
          await _db!.close();
        }
      } catch (e) {
        rethrow;
      } finally {
        _db = null;
      }
    }
  }

  Future<Patient> createPatient(Patient patient) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Remover o ID do JSON antes de inserir
      final patientJson = patient.toJson();
      patientJson.remove('_id');
      
      // Tentar inserir o documento
      final result = await collection.insert(patientJson);
      
      // Verificar se houve erro do Atlas Free Tier
      if (result['ok'] == 0 && result['code'] == 8000) {
        
        // Tentar buscar o documento pelo email
        final createdPatient = await collection.findOne(where.eq('email', patient.email));
        if (createdPatient != null) {
          
          // Converter o ID para string hexadecimal antes de criar o objeto Patient
          final patientData = Map<String, dynamic>.from(createdPatient);
          patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
          
          final patientObject = Patient.fromJson(patientData);
          
          return patientObject;
        } else {
          throw 'Erro ao criar paciente: Documento não encontrado após inserção';
        }
      }
      
      if (result['_id'] == null) {
        throw 'Erro ao criar paciente: ID não gerado';
      }
      
      // Buscar o paciente recém-criado para garantir que temos todos os dados
      final createdPatient = await collection.findOne(where.id(result['_id']));
      if (createdPatient == null) {
        throw 'Erro ao recuperar paciente após criação';
      }
      
      // Converter o ID para string hexadecimal antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(createdPatient);
      if (patientData['_id'] is ObjectId) {
        patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
      } else {
        patientData['_id'] = patientData['_id'].toString();
      }
      
      return Patient.fromJson(patientData);
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<Patient?> getPatientByEmail(String email) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      final result = await collection.findOne(where.eq('email', email));
      if (result != null) {
        
        // Converter o ID para string hexadecimal antes de criar o objeto Patient
        final patientData = Map<String, dynamic>.from(result);
        if (patientData['_id'] is ObjectId) {
          patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
        } else {
          patientData['_id'] = patientData['_id'].toString();
        }
        
        return Patient.fromJson(patientData);
      }
      return null;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<Patient?> getPatientById(ObjectId id) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      final result = await collection.findOne(where.id(id));
      if (result != null) {
        
        // Converter o ID para string hexadecimal antes de criar o objeto Patient
        final patientData = Map<String, dynamic>.from(result);
        if (patientData['_id'] is ObjectId) {
          patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
        } else {
          patientData['_id'] = patientData['_id'].toString();
        }
        
        return Patient.fromJson(patientData);
      }
      return null;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<Patient> updatePatient(ObjectId id, Patient patient) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
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
      
      // Converter o ID para string hexadecimal antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(updatedPatient);
      if (patientData['_id'] is ObjectId) {
        patientData['_id'] = (patientData['_id'] as ObjectId).toHexString();
      } else {
        patientData['_id'] = patientData['_id'].toString();
      }
      
      return Patient.fromJson(patientData);
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> deletePatient(ObjectId id) async {
    try {
      await _ensureConnection();
      
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Usar remove() simples - compatível com Atlas Free Tier
      final result = await collection.remove(where.id(id));
      
      if (result['ok'] != 1) {
        throw 'Falha ao deletar paciente';
      }
      
      if (result['n'] == 0) {
        throw 'Paciente não encontrado';
      }
      
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> setTwoFactorCode(String patientId, String code, DateTime expires) async {
    try {
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      
      // Usar update() simples - compatível com Atlas Free Tier
      final result = await collection.update(
        where.eq('_id', objectId),
        modify.set('twoFactorCode', code).set('twoFactorExpires', expires.toIso8601String()),
      );
      
      // Verificar se é erro do Atlas Free Tier (código 8000)
      if (result['ok'] == 0 && result['code'] == 8000) {
        return;
      }
      
      if (result['ok'] != 1) {
        throw 'Falha ao salvar código 2FA: ${result['errmsg']}';
      }
      
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> validateTwoFactorCode(String patientId, String code) async {
    try {
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      
      final result = await collection.findOne(where.eq('_id', objectId));
      if (result == null) {
        return false;
      }
      
      // Converter o ID para string antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(result);
      patientData['_id'] = patientData['_id'].toString();
      
      final patient = Patient.fromJson(patientData);
      
      if (patient.twoFactorCode == code && patient.twoFactorExpires != null && patient.twoFactorExpires!.isAfter(DateTime.now())) {
        
        // Limpa o código após uso usando update() simples
        final clearResult = await collection.update(
          where.eq('_id', objectId),
          modify.unset('twoFactorCode').unset('twoFactorExpires'),
        );
        
        // Verificar se é erro do Atlas Free Tier (código 8000)
        if (clearResult['ok'] == 0 && clearResult['code'] == 8000) {
        } else if (clearResult['ok'] != 1) {
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPasswordResetCode(String patientId, String code, DateTime expires) async {
    try {
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      
      // Usar update() simples - compatível com Atlas Free Tier
      final result = await collection.update(
        where.eq('_id', objectId),
        modify.set('passwordResetCode', code).set('passwordResetExpires', expires.toIso8601String()),
      );
      
      // Verificar se é erro do Atlas Free Tier (código 8000)
      if (result['ok'] == 0 && result['code'] == 8000) {
        return;
      }
      
      if (result['ok'] != 1) {
        throw 'Falha ao salvar código de redefinição: ${result['errmsg']}';
      }
      
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> validatePasswordResetCode(String patientId, String code) async {
    try {
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      
      final result = await collection.findOne(where.eq('_id', objectId));
      if (result == null) {
        return false;
      }
      
      // Converter o ID para string antes de criar o objeto Patient
      final patientData = Map<String, dynamic>.from(result);
      patientData['_id'] = patientData['_id'].toString();
      
      final patient = Patient.fromJson(patientData);
      
      if (patient.passwordResetCode == code && 
          patient.passwordResetExpires != null && 
          patient.passwordResetExpires!.isAfter(DateTime.now())) {
        
        // Limpa o código após uso usando update() simples
        final clearResult = await collection.update(
          where.eq('_id', objectId),
          modify.unset('passwordResetCode').unset('passwordResetExpires'),
        );
        
        // Verificar se é erro do Atlas Free Tier (código 8000)
        if (clearResult['ok'] == 0 && clearResult['code'] == 8000) {
        } else if (clearResult['ok'] != 1) {
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePatientPassword(String patientId, String hashedPassword) async {
    try {
      await _ensureConnection();
      final collection = _db!.collection(DatabaseConfig.patientsCollection);
      
      // Converter string para ObjectId
      final objectId = ObjectId.parse(patientId);
      
      // Usar update() simples - compatível com Atlas Free Tier
      final result = await collection.update(
        where.eq('_id', objectId),
        modify.set('password', hashedPassword).set('updatedAt', DateTime.now().toIso8601String()),
      );
      
      // Verificar se é erro do Atlas Free Tier (código 8000)
      if (result['ok'] == 0 && result['code'] == 8000) {
        return;
      }
      
      if (result['ok'] != 1) {
        throw 'Falha ao atualizar senha: ${result['errmsg']}';
      }
      
    } catch (e) {
      rethrow;
    }
  }
} 