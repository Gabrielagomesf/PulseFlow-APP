import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final HealthFactory _health = HealthFactory();

  // Tipos de dados de saúde que queremos acessar
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.STEPS,
  ];

  // Solicita permissões para acessar dados de saúde
  Future<bool> requestPermissions() async {
    try {
      print('🔐 Solicitando permissões do Apple Health...');
      print('📱 Tipos de dados solicitados: $_healthDataTypes');
      
      // Verifica se o HealthKit está disponível (método não disponível na versão 9.0.1)
      // bool isAvailable = await _health.isHealthDataAvailable();
      print('🏥 Tentando acessar HealthKit...');
      
      bool requested = await _health.requestAuthorization(_healthDataTypes);
      print('🔑 Resultado da solicitação de permissão: $requested');
      
      if (requested) {
        print('✅ Permissões do Apple Health concedidas!');
        return true;
      } else {
        print('❌ Permissões do Apple Health negadas');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao solicitar permissões do Health: $e');
      return false;
    }
  }

  // Busca dados de frequência cardíaca dos últimos 7 dias
  Future<List<FlSpot>> getHeartRateData() async {
    try {
      print('🫀 Buscando dados reais de frequência cardíaca do Apple Health...');
      
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        weekAgo,
        now,
        [HealthDataType.HEART_RATE],
      );

      print('📊 Encontrados ${healthData.length} pontos de dados de frequência cardíaca');

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
          print('📈 Dia ${i}: ${average.toStringAsFixed(1)} bpm (${dailyData[day]!.length} medições)');
        } else {
          // Se não há dados, usa valor padrão
          spots.add(FlSpot(i.toDouble(), 70.0));
          print('📈 Dia ${i}: Sem dados (usando 70 bpm)');
        }
      }

      return spots;
    } catch (e) {
      print('❌ Erro ao buscar dados de frequência cardíaca: $e');
      return _generateFallbackHeartRateData();
    }
  }

  // Busca dados de sono dos últimos 7 dias
  Future<List<FlSpot>> getSleepData() async {
    try {
      print('😴 Buscando dados reais de sono do Apple Health...');
      
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        weekAgo,
        now,
        [HealthDataType.SLEEP_IN_BED],
      );

      print('📊 Encontrados ${healthData.length} pontos de dados de sono');

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
          print('📈 Dia ${i}: ${dailySleep[day]!.toStringAsFixed(1)} horas de sono');
        } else {
          // Se não há dados, usa valor padrão
          spots.add(FlSpot(i.toDouble(), 7.5));
          print('📈 Dia ${i}: Sem dados (usando 7.5 horas)');
        }
      }

      return spots;
    } catch (e) {
      print('❌ Erro ao buscar dados de sono: $e');
      return _generateFallbackSleepData();
    }
  }

  // Busca dados de passos dos últimos 7 dias
  Future<List<FlSpot>> getStepsData() async {
    try {
      print('🚶 Buscando dados reais de passos do Apple Health...');
      
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        weekAgo,
        now,
        [HealthDataType.STEPS],
      );

      print('📊 Encontrados ${healthData.length} pontos de dados de passos');

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
          print('📈 Dia ${i}: ${dailySteps[day]!.toStringAsFixed(0)} passos');
        } else {
          // Se não há dados, usa valor padrão
          spots.add(FlSpot(i.toDouble(), 8000.0));
          print('📈 Dia ${i}: Sem dados (usando 8000 passos)');
        }
      }

      return spots;
    } catch (e) {
      print('❌ Erro ao buscar dados de passos: $e');
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
        print('⚠️ Erro ao converter HealthValue: $e');
        return 0.0;
      }
    }
  }

  // Métodos de fallback com dados simulados
  List<FlSpot> _generateFallbackHeartRateData() {
    print('🔄 Usando dados simulados de frequência cardíaca');
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
    print('🔄 Usando dados simulados de sono');
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
    print('🔄 Usando dados simulados de passos');
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
      final hasPermission = result ?? false;
      print('🔐 Permissões do Apple Health: ${hasPermission ? "✅ Concedidas" : "❌ Negadas"}');
      return hasPermission;
    } catch (e) {
      print('❌ Erro ao verificar permissões: $e');
      return false;
    }
  }

  // Busca todos os dados de saúde de uma vez
  Future<Map<String, List<FlSpot>>> getAllHealthData() async {
    try {
      print('🏥 Iniciando busca de dados do Apple Health...');
      
      // Verifica permissões
      final hasPermission = await hasPermissions();
      if (!hasPermission) {
        print('🔐 Solicitando permissões do Apple Health...');
        final granted = await requestPermissions();
        if (!granted) {
          print('❌ Permissões negadas, usando dados simulados');
          return _getFallbackData();
        }
      }

      print('✅ Permissões OK, buscando dados reais...');
      
      final heartRateData = await getHeartRateData();
      final sleepData = await getSleepData();
      final stepsData = await getStepsData();

      print('🎉 Dados do Apple Health carregados com sucesso!');
      return {
        'heartRate': heartRateData,
        'sleep': sleepData,
        'steps': stepsData,
      };
    } catch (e) {
      print('❌ Erro ao buscar todos os dados de saúde: $e');
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
}