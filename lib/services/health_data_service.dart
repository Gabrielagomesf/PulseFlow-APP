import 'package:get/get.dart';
import '../models/health_data.dart';
import 'database_service.dart';
import 'health_service.dart';

class HealthDataService {
  final DatabaseService _db = Get.find<DatabaseService>();
  final HealthService _healthService = HealthService();

  // Salva dados de saúde do HealthKit no banco de dados
  Future<void> saveHealthDataFromHealthKit(String patientId) async {
    try {
      
      // Verifica se tem permissões
      final hasPermissions = await _healthService.hasPermissions();
      
      if (!hasPermissions) {
        final granted = await _healthService.requestPermissions();
        if (!granted) {
          return;
        }
      }

      // Busca dados do HealthKit
      final healthData = await _healthService.getAllHealthData();
      
      // Log detalhado de cada tipo de dado
      healthData.forEach((key, value) {
        if (value.isNotEmpty) {
        }
      });
      
      // Salva dados nas coleções específicas
      
      await _saveHeartRateData(patientId, healthData);
      await _saveStepsData(patientId, healthData);
      await _saveSleepData(patientId, healthData);
      
      
    } catch (e) {
      rethrow;
    }
  }

  // Salva dados de frequência cardíaca na coleção 'batimentos'
  Future<void> _saveHeartRateData(String patientId, Map<String, List<dynamic>> healthData) async {
    try {
      if (healthData['heartRate'] == null || healthData['heartRate']!.isEmpty) {
        return;
      }

      final collection = await _db.getCollection('batimentos');
      final now = DateTime.now();
      
      for (int i = 0; i < healthData['heartRate']!.length; i++) {
        final spot = healthData['heartRate']![i];
        final date = now.subtract(Duration(days: (6 - i)));
        
        final data = {
          'pacienteId': patientId,
          'valor': spot.y,
          'data': date,
          'fonte': 'HealthKit',
          'unidade': 'bpm',
          'descricao': 'Frequência cardíaca',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };
        
        await collection.insert(data);
      }
      
      
    } catch (e) {
    }
  }

  // Salva dados de passos na coleção 'passos'
  Future<void> _saveStepsData(String patientId, Map<String, List<dynamic>> healthData) async {
    try {
      if (healthData['steps'] == null || healthData['steps']!.isEmpty) {
        return;
      }

      final collection = await _db.getCollection('passos');
      final now = DateTime.now();
      
      for (int i = 0; i < healthData['steps']!.length; i++) {
        final spot = healthData['steps']![i];
        final date = now.subtract(Duration(days: (6 - i)));
        
        final data = {
          'pacienteId': patientId,
          'valor': spot.y,
          'data': date,
          'fonte': 'HealthKit',
          'unidade': 'passos',
          'descricao': 'Passos diários',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };
        
        await collection.insert(data);
      }
      
      
    } catch (e) {
    }
  }

  // Salva dados de sono na coleção 'insonia'
  Future<void> _saveSleepData(String patientId, Map<String, List<dynamic>> healthData) async {
    try {
      
      if (healthData['sleep'] == null || healthData['sleep']!.isEmpty) {
        
        // Dados simulados para teste
        final collection = await _db.getCollection('insonias');
        final now = DateTime.now();
        
        final testData = {
          'pacienteId': patientId,
          'valor': 7.5,
          'data': now,
          'fonte': 'Teste',
          'unidade': 'horas',
          'descricao': 'Dados de teste - sono',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };
        
        final result = await collection.insert(testData);
        return;
      }

      final collection = await _db.getCollection('insonias');
      final now = DateTime.now();
      
      
      for (int i = 0; i < healthData['sleep']!.length; i++) {
        final spot = healthData['sleep']![i];
        final date = now.subtract(Duration(days: (6 - i)));
        
        
        final data = {
          'pacienteId': patientId,
          'valor': spot.y,
          'data': date,
          'fonte': 'HealthKit',
          'unidade': 'horas',
          'descricao': 'Horas de sono',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };
        
        final result = await collection.insert(data);
      }
      
      
    } catch (e) {
    }
  }

  // Busca dados de saúde do banco de dados
  Future<List<HealthData>> getHealthDataByPatient(String patientId) async {
    try {
      return await _db.getHealthDataByPatientId(patientId);
    } catch (e) {
      rethrow;
    }
  }

  // Busca dados de saúde por tipo
  Future<List<HealthData>> getHealthDataByType(String patientId, String dataType) async {
    try {
      return await _db.getHealthDataByType(patientId, dataType);
    } catch (e) {
      rethrow;
    }
  }

  // Busca dados de saúde por período
  Future<List<HealthData>> getHealthDataByPeriod(
    String patientId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      return await _db.getHealthDataByPeriod(patientId, startDate, endDate);
    } catch (e) {
      rethrow;
    }
  }

  // Busca dados de saúde dos últimos N dias
  Future<List<HealthData>> getHealthDataLastDays(String patientId, int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      return await getHealthDataByPeriod(patientId, startDate, endDate);
    } catch (e) {
      rethrow;
    }
  }

  // Busca dados de saúde do dia atual
  Future<List<HealthData>> getTodayHealthData(String patientId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      return await getHealthDataByPeriod(patientId, startOfDay, endOfDay);
    } catch (e) {
      rethrow;
    }
  }

  // Busca dados de saúde da semana atual
  Future<List<HealthData>> getThisWeekHealthData(String patientId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeek = startOfDay.add(Duration(days: 7));
      
      return await getHealthDataByPeriod(patientId, startOfDay, endOfWeek);
    } catch (e) {
      rethrow;
    }
  }

  // Busca dados de saúde do mês atual
  Future<List<HealthData>> getThisMonthHealthData(String patientId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);
      
      return await getHealthDataByPeriod(patientId, startOfMonth, endOfMonth);
    } catch (e) {
      rethrow;
    }
  }

  // Calcula estatísticas dos dados de saúde
  Future<Map<String, dynamic>> getHealthDataStats(String patientId, String dataType) async {
    try {
      final data = await getHealthDataByType(patientId, dataType);
      
      if (data.isEmpty) {
        return {
          'count': 0,
          'average': 0.0,
          'min': 0.0,
          'max': 0.0,
          'latest': null,
        };
      }
      
      final values = data.map((d) => d.value).toList();
      final sum = values.reduce((a, b) => a + b);
      
      return {
        'count': data.length,
        'average': sum / data.length,
        'min': values.reduce((a, b) => a < b ? a : b),
        'max': values.reduce((a, b) => a > b ? a : b),
        'latest': data.first.value,
        'latestDate': data.first.date,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Sincroniza dados do HealthKit com o banco de dados
  Future<void> syncHealthData(String patientId) async {
    try {
      
      // Verifica se tem permissões
      final hasPermissions = await _healthService.hasPermissions();
      if (!hasPermissions) {
        return;
      }

      // Busca dados existentes do banco
      final existingData = await getHealthDataLastDays(patientId, 7);
      
      // Busca dados do HealthKit
      final healthData = await _healthService.getAllHealthData();
      
      // Verifica quais dados são novos
      final newDataList = <HealthData>[];
      final now = DateTime.now();
      
      // Processa frequência cardíaca
      if (healthData['heartRate'] != null && healthData['heartRate']!.isNotEmpty) {
        for (int i = 0; i < healthData['heartRate']!.length; i++) {
          final spot = healthData['heartRate']![i];
          final date = now.subtract(Duration(days: (6 - i)));
          
          // Verifica se já existe
          final exists = existingData.any((data) => 
            data.dataType == 'heartRate' && 
            data.date.day == date.day &&
            data.date.month == date.month &&
            data.date.year == date.year
          );
          
          if (!exists) {
            newDataList.add(HealthData(
              patientId: patientId,
              dataType: 'heartRate',
              value: spot.y,
              date: date,
              source: 'HealthKit',
              metadata: {
                'unit': 'bpm',
                'description': 'Frequência cardíaca'
              },
            ));
          }
        }
      }
      
      // Processa dados de sono
      if (healthData['sleep'] != null && healthData['sleep']!.isNotEmpty) {
        for (int i = 0; i < healthData['sleep']!.length; i++) {
          final spot = healthData['sleep']![i];
          final date = now.subtract(Duration(days: (6 - i)));
          
          // Verifica se já existe
          final exists = existingData.any((data) => 
            data.dataType == 'sleep' && 
            data.date.day == date.day &&
            data.date.month == date.month &&
            data.date.year == date.year
          );
          
          if (!exists) {
            newDataList.add(HealthData(
              patientId: patientId,
              dataType: 'sleep',
              value: spot.y,
              date: date,
              source: 'HealthKit',
              metadata: {
                'unit': 'hours',
                'description': 'Horas de sono'
              },
            ));
          }
        }
      }
      
      // Processa dados de passos
      if (healthData['steps'] != null && healthData['steps']!.isNotEmpty) {
        for (int i = 0; i < healthData['steps']!.length; i++) {
          final spot = healthData['steps']![i];
          final date = now.subtract(Duration(days: (6 - i)));
          
          // Verifica se já existe
          final exists = existingData.any((data) => 
            data.dataType == 'steps' && 
            data.date.day == date.day &&
            data.date.month == date.month &&
            data.date.year == date.year
          );
          
          if (!exists) {
            newDataList.add(HealthData(
              patientId: patientId,
              dataType: 'steps',
              value: spot.y,
              date: date,
              source: 'HealthKit',
              metadata: {
                'unit': 'steps',
                'description': 'Passos diários'
              },
            ));
          }
        }
      }
      
      if (newDataList.isNotEmpty) {
        // Salva apenas dados novos
        await _db.createMultipleHealthData(newDataList);
      } else {
      }
      
    } catch (e) {
      rethrow;
    }
  }

  // Deleta dados de saúde
  Future<void> deleteHealthData(String healthDataId) async {
    try {
      await _db.deleteHealthData(healthDataId);
    } catch (e) {
      rethrow;
    }
  }
}
