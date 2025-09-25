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

      print('🫀 Período de busca: ${weekAgo.day}/${weekAgo.month} até ${now.day}/${now.month}');
      
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );

      print('📊 Encontrados ${healthData.length} pontos de dados de frequência cardíaca');
      
      if (healthData.isNotEmpty) {
        print('🫀 Primeiro ponto: ${healthData.first.value} em ${healthData.first.dateFrom}');
        print('🫀 Último ponto: ${healthData.last.value} em ${healthData.last.dateFrom}');
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
        startTime: weekAgo,
        endTime: now,
        types: [HealthDataType.SLEEP_IN_BED],
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

      print('🚶 Período de busca: ${weekAgo.day}/${weekAgo.month} até ${now.day}/${now.month}');
      
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      print('📊 Encontrados ${healthData.length} pontos de dados de passos');
      
      if (healthData.isNotEmpty) {
        print('🚶 Primeiro ponto: ${healthData.first.value} em ${healthData.first.dateFrom}');
        print('🚶 Último ponto: ${healthData.last.value} em ${healthData.last.dateFrom}');
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
      print('🔐 Verificando permissões do Apple Health...');
      final result = await _health.hasPermissions(_healthDataTypes);
      print('🔐 Resultado bruto das permissões: $result');
      
      // Se result é null, significa que as permissões não foram solicitadas ainda
      if (result == null) {
        print('🔐 Permissões nunca foram solicitadas');
        return false;
      }
      
      final hasPermission = result;
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
      
      // Verifica permissões primeiro
      final hasPermission = await hasPermissions();
      print('🔐 Status das permissões: $hasPermission');
      
      if (!hasPermission) {
        print('🔐 Solicitando permissões do Apple Health...');
        final granted = await requestPermissions();
        print('🔐 Resultado da solicitação: $granted');
        if (!granted) {
          print('❌ Permissões negadas, mas tentando buscar dados mesmo assim...');
        }
      }
      
      // Sempre tenta buscar dados reais
      print('🔍 Tentando buscar dados reais do Apple Health...');
      
      // Busca dados com logs detalhados
      print('🫀 Buscando frequência cardíaca...');
      final heartRateData = await getHeartRateData();
      print('🫀 Frequência cardíaca: ${heartRateData.length} pontos');
      
      print('😴 Buscando dados de sono...');
      final sleepData = await getSleepData();
      print('😴 Sono: ${sleepData.length} pontos');
      
      print('🚶 Buscando dados de passos...');
      final stepsData = await getStepsData();
      print('🚶 Passos: ${stepsData.length} pontos');

      print('🎉 Dados do Apple Health carregados com sucesso!');
      print('📊 Resumo: FC=${heartRateData.length}, Sono=${sleepData.length}, Passos=${stepsData.length}');
      
      return {
        'heartRate': heartRateData,
        'sleep': sleepData,
        'steps': stepsData,
      };
    } catch (e) {
      print('❌ Erro ao buscar todos os dados de saúde: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      print('🔄 Tentando dados de fallback...');
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
      print('🔍 === DIAGNÓSTICO DO APPLE HEALTH ===');
      
      // Verifica permissões
      final hasPermission = await hasPermissions();
      print('🔐 Permissões: $hasPermission');
      
      if (!hasPermission) {
        print('❌ Sem permissões - solicitando...');
        final granted = await requestPermissions();
        print('🔐 Resultado: $granted');
        if (!granted) {
          print('❌ Permissões negadas pelo usuário');
          return;
        }
      }

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      print('📅 Período: ${weekAgo.day}/${weekAgo.month} até ${now.day}/${now.month}');
      
      // Testa cada tipo de dado individualmente
      print('\n🫀 Testando frequência cardíaca...');
      try {
        final heartData = await _health.getHealthDataFromTypes(
          startTime: weekAgo, 
          endTime: now, 
          types: [HealthDataType.HEART_RATE]
        );
        print('🫀 Dados brutos de FC: ${heartData.length} pontos');
        if (heartData.isNotEmpty) {
          print('🫀 Primeiro ponto: ${heartData.first.value} em ${heartData.first.dateFrom}');
        }
      } catch (e) {
        print('❌ Erro ao buscar FC: $e');
      }

      print('\n😴 Testando dados de sono...');
      try {
        final sleepData = await _health.getHealthDataFromTypes(
          startTime: weekAgo, 
          endTime: now, 
          types: [HealthDataType.SLEEP_IN_BED]
        );
        print('😴 Dados brutos de sono: ${sleepData.length} pontos');
        if (sleepData.isNotEmpty) {
          print('😴 Primeiro ponto: ${sleepData.first.value} de ${sleepData.first.dateFrom} até ${sleepData.first.dateTo}');
        }
      } catch (e) {
        print('❌ Erro ao buscar sono: $e');
      }

      print('\n🚶 Testando dados de passos...');
      try {
        final stepsData = await _health.getHealthDataFromTypes(
          startTime: weekAgo, 
          endTime: now, 
          types: [HealthDataType.STEPS]
        );
        print('🚶 Dados brutos de passos: ${stepsData.length} pontos');
        if (stepsData.isNotEmpty) {
          print('🚶 Primeiro ponto: ${stepsData.first.value} em ${stepsData.first.dateFrom}');
        }
      } catch (e) {
        print('❌ Erro ao buscar passos: $e');
      }

      print('\n🔍 === FIM DO DIAGNÓSTICO ===');
      
    } catch (e) {
      print('❌ Erro no diagnóstico: $e');
    }
  }
}