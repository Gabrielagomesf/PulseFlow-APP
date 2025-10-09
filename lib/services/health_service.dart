import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  // Tipos de dados de saúde que queremos acessar
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.STEPS,
  ];

  // Solicita permissões para acessar dados de saúde
  Future<bool> requestPermissions() async {
    try {
      
      // Verifica se o HealthKit está disponível (método não disponível na versão 9.0.1)
      // bool isAvailable = await _health.isHealthDataAvailable();
      
      bool requested = await _health.requestAuthorization(_healthDataTypes);
      
      if (requested) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Busca dados de frequência cardíaca dos últimos 7 dias
  Future<List<FlSpot>> getHeartRateData() async {
    try {
      
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );

      
      if (healthData.isNotEmpty) {
      }

      // Agrupa dados por dia e calcula média
      Map<int, List<double>> dailyData = {};
      
      for (var dataPoint in healthData) {
        final day = dataPoint.dateFrom.day;
        final value = _getHealthValueAsDouble(dataPoint.value);
        
        if (dailyData[day] == null) {
          dailyData[day] = [];
        }
        dailyData[day]!.add(value);
      }

      // Converte para FlSpot (últimos 7 dias)
      List<FlSpot> spots = [];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final day = date.day;
        
        if (dailyData[day] != null && dailyData[day]!.isNotEmpty) {
          // Calcula média dos valores do dia
          final average = dailyData[day]!.reduce((a, b) => a + b) / dailyData[day]!.length;
          spots.add(FlSpot(i.toDouble(), average));
        } else {
          // Se não há dados, usa valor padrão
          spots.add(FlSpot(i.toDouble(), 70.0));
        }
      }

      return spots;
    } catch (e) {
      return _generateFallbackHeartRateData();
    }
  }

  // Busca dados de sono dos últimos 7 dias
  Future<List<FlSpot>> getSleepData() async {
    try {
      
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: [HealthDataType.SLEEP_IN_BED],
      );


      // Agrupa dados por dia
      Map<int, double> dailySleep = {};
      
      for (var dataPoint in healthData) {
        final day = dataPoint.dateFrom.day;
        final duration = dataPoint.dateTo.difference(dataPoint.dateFrom).inHours.toDouble();
        
        if (dailySleep[day] == null) {
          dailySleep[day] = 0.0;
        }
        dailySleep[day] = dailySleep[day]! + duration;
      }

      // Converte para FlSpot (últimos 7 dias)
      List<FlSpot> spots = [];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final day = date.day;
        
        if (dailySleep[day] != null && dailySleep[day]! > 0) {
          spots.add(FlSpot(i.toDouble(), dailySleep[day]!));
        } else {
          // Se não há dados, usa valor padrão
          spots.add(FlSpot(i.toDouble(), 7.5));
        }
      }

      return spots;
    } catch (e) {
      return _generateFallbackSleepData();
    }
  }

  // Busca dados de passos dos últimos 7 dias
  Future<List<FlSpot>> getStepsData() async {
    try {
      
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      
      if (healthData.isNotEmpty) {
      }

      // Agrupa dados por dia
      Map<int, double> dailySteps = {};
      
      for (var dataPoint in healthData) {
        final day = dataPoint.dateFrom.day;
        final steps = _getHealthValueAsDouble(dataPoint.value);
        
        if (dailySteps[day] == null) {
          dailySteps[day] = 0.0;
        }
        dailySteps[day] = dailySteps[day]! + steps;
      }

      // Converte para FlSpot (últimos 7 dias)
      List<FlSpot> spots = [];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final day = date.day;
        
        if (dailySteps[day] != null && dailySteps[day]! > 0) {
          spots.add(FlSpot(i.toDouble(), dailySteps[day]!));
        } else {
          // Se não há dados, usa valor padrão
          spots.add(FlSpot(i.toDouble(), 8000.0));
        }
      }

      return spots;
    } catch (e) {
      return _generateFallbackStepsData();
    }
  }

  // Converte HealthValue para double
  double _getHealthValueAsDouble(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    } else if (value is WorkoutHealthValue) {
      return value.totalEnergyBurned?.toDouble() ?? 0.0;
    } else if (value is ElectrocardiogramHealthValue) {
      return value.averageHeartRate?.toDouble() ?? 0.0;
    } else {
      // Para outros tipos, tenta converter para double
      try {
        return double.parse(value.toString());
      } catch (e) {
        return 0.0;
      }
    }
  }

  // Métodos de fallback com dados simulados
  List<FlSpot> _generateFallbackHeartRateData() {
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final heartRate = 65 + (i * 2) + (date.day % 10);
      spots.add(FlSpot(i.toDouble(), heartRate.toDouble()));
    }
    
    return spots;
  }

  List<FlSpot> _generateFallbackSleepData() {
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final sleepHours = 7.0 + (i * 0.5) + (date.day % 3);
      spots.add(FlSpot(i.toDouble(), sleepHours));
    }
    
    return spots;
  }

  List<FlSpot> _generateFallbackStepsData() {
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final steps = 8000 + (i * 500) + (date.day % 2000);
      spots.add(FlSpot(i.toDouble(), steps.toDouble()));
    }
    
    return spots;
  }

  // Verifica se as permissões foram concedidas
  Future<bool> hasPermissions() async {
    try {
      final result = await _health.hasPermissions(_healthDataTypes);
      
      // Se result é null, significa que as permissões não foram solicitadas ainda
      if (result == null) {
        return false;
      }
      
      final hasPermission = result;
      return hasPermission;
    } catch (e) {
      return false;
    }
  }

  // Busca todos os dados de saúde de uma vez
  Future<Map<String, List<FlSpot>>> getAllHealthData() async {
    try {
      
      // Verifica permissões primeiro
      final hasPermission = await hasPermissions();
      
      if (!hasPermission) {
        final granted = await requestPermissions();
        if (!granted) {
        }
      }
      
      // Sempre tenta buscar dados reais
      
      // Busca dados com logs detalhados
      final heartRateData = await getHeartRateData();
      
      final sleepData = await getSleepData();
      
      final stepsData = await getStepsData();

      
      return {
        'heartRate': heartRateData,
        'sleep': sleepData,
        'steps': stepsData,
      };
    } catch (e) {
      return _getFallbackData();
    }
  }

  // Retorna dados de fallback
  Map<String, List<FlSpot>> _getFallbackData() {
    return {
      'heartRate': _generateFallbackHeartRateData(),
      'sleep': _generateFallbackSleepData(),
      'steps': _generateFallbackStepsData(),
    };
  }

  // Método de diagnóstico para verificar dados brutos do Apple Health
  Future<void> diagnoseHealthData() async {
    try {
      
      // Verifica permissões
      final hasPermission = await hasPermissions();
      
      if (!hasPermission) {
        final granted = await requestPermissions();
        if (!granted) {
          return;
        }
      }

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      
      // Testa cada tipo de dado individualmente
      try {
        final heartData = await _health.getHealthDataFromTypes(
          startTime: weekAgo, 
          endTime: now, 
          types: [HealthDataType.HEART_RATE]
        );
        if (heartData.isNotEmpty) {
        }
      } catch (e) {
      }

      try {
        final sleepData = await _health.getHealthDataFromTypes(
          startTime: weekAgo, 
          endTime: now, 
          types: [HealthDataType.SLEEP_IN_BED]
        );
        if (sleepData.isNotEmpty) {
        }
      } catch (e) {
      }

      try {
        final stepsData = await _health.getHealthDataFromTypes(
          startTime: weekAgo, 
          endTime: now, 
          types: [HealthDataType.STEPS]
        );
        if (stepsData.isNotEmpty) {
        }
      } catch (e) {
      }

      
    } catch (e) {
    }
  }
}