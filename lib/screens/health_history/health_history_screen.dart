import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../home/home_controller.dart';

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({super.key});

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  final DatabaseService _db = Get.find<DatabaseService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final _isLoading = false.obs;
  final _selectedDataType = 'heartRate'.obs;
  final _selectedPeriod = 56.obs; // 8 semanas
  
  List<Map<String, dynamic>> _healthData = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    try {
      _isLoading.value = true;
      _healthData.clear(); // Limpa dados anteriores
      
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return;
      }
      
      
      // Busca dados das coleções específicas
      await _loadCollectionData('batimentos', 'heartRate');
      await _loadCollectionData('passos', 'steps');
      await _loadCollectionData('insonias', 'sleep');
      
      
      // Se não há dados, cria dados de teste
      if (_healthData.isEmpty) {
        _createTestData();
      }
      
      _healthData.forEach((data) {
      });
      
      // Calcula estatísticas
      _calculateStats();
      
      // Força atualização da UI
      _isLoading.value = false;
      _isLoading.value = true;
      _isLoading.value = false;
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados de saúde: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadCollectionData(String collectionName, String dataType) async {
    try {
      
      final collection = await _db.getCollection(collectionName);
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: _selectedPeriod.value));
      
      
      final data = await collection.find({
        'pacienteId': _authService.currentUser!.id!,
        'data': {
          '\$gte': startDate,
          '\$lte': endDate,
        }
      }).toList();
      
      
      // Agrupa dados por semana
      final weeklyData = _groupDataByWeek(data);
      
      for (final weekData in weeklyData) {
        _healthData.add({
          'dataType': dataType,
          'value': weekData['average'],
          'date': weekData['weekStart'],
          'source': weekData['hasData'] ? 'Média Semanal' : 'Sem Dados',
          'weekNumber': weekData['weekNumber'],
          'hasData': weekData['hasData'],
          'count': weekData['count'],
        });
      }
      
    } catch (e) {
    }
  }

  List<Map<String, dynamic>> _groupDataByWeek(List<Map<String, dynamic>> data) {
    // Sempre retorna 8 semanas, mesmo sem dados
    final List<Map<String, dynamic>> weeklyAverages = [];
    final now = DateTime.now();
    
    for (int weekIndex = 0; weekIndex < 8; weekIndex++) {
      // Calcula o início da semana (8 semanas atrás até agora)
      final weekStart = now.subtract(Duration(days: (7 - weekIndex) * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      // Filtra dados desta semana específica
      final weekData = data.where((item) {
        final itemDate = item['data'] as DateTime;
        return itemDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
               itemDate.isBefore(weekEnd.add(const Duration(days: 1)));
      }).toList();
      
      if (weekData.isNotEmpty) {
        // Calcula média dos dados da semana
        final values = weekData.map((item) => (item['valor'] as num).toDouble()).toList();
        final average = values.reduce((a, b) => a + b) / values.length;
        
        weeklyAverages.add({
          'weekNumber': weekIndex,
          'average': average,
          'weekStart': weekStart,
          'count': values.length,
          'hasData': true,
        });
      } else {
        // Semana sem dados
        weeklyAverages.add({
          'weekNumber': weekIndex,
          'average': 0.0,
          'weekStart': weekStart,
          'count': 0,
          'hasData': false,
        });
      }
    }
    
    return weeklyAverages;
  }

  int _getWeekNumber(DateTime date) {
    final now = DateTime.now();
    final daysDiff = now.difference(date).inDays;
    return (daysDiff / 7).floor();
  }

  void _createTestData() {
    
    final now = DateTime.now();
    
    // Dados de teste para frequência cardíaca
    for (int i = 0; i < 6; i++) {
      final weekStart = now.subtract(Duration(days: (5 - i) * 7));
      _healthData.add({
        'dataType': 'heartRate',
        'value': 65.0 + (i * 2.0) + (i % 2 == 0 ? 5.0 : -3.0),
        'date': weekStart,
        'source': 'Dados de Teste',
        'weekNumber': i,
        'hasData': true,
        'count': 7,
      });
    }
    
    // Dados de teste para passos
    for (int i = 0; i < 6; i++) {
      final weekStart = now.subtract(Duration(days: (5 - i) * 7));
      _healthData.add({
        'dataType': 'steps',
        'value': 8000.0 + (i * 500.0) + (i % 2 == 0 ? 1000.0 : -500.0),
        'date': weekStart,
        'source': 'Dados de Teste',
        'weekNumber': i,
        'hasData': true,
        'count': 7,
      });
    }
    
    // Dados de teste para sono
    for (int i = 0; i < 6; i++) {
      final weekStart = now.subtract(Duration(days: (5 - i) * 7));
      _healthData.add({
        'dataType': 'sleep',
        'value': 7.5 + (i * 0.2) + (i % 2 == 0 ? 0.5 : -0.3),
        'date': weekStart,
        'source': 'Dados de Teste',
        'weekNumber': i,
        'hasData': true,
        'count': 7,
      });
    }
    
  }

  void _calculateStats() {
    if (_healthData.isEmpty) return;
    
    // Agrupa dados por tipo
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (final data in _healthData) {
      groupedData.putIfAbsent(data['dataType'], () => []).add(data);
    }
    
    _stats = {};
    groupedData.forEach((type, dataList) {
      // Apenas dados que têm hasData = true
      final validData = dataList.where((d) => d['hasData'] == true).toList();
      
      if (validData.isNotEmpty) {
        final values = validData.map((d) => d['value'] as double).toList();
        // Filtra valores que não são 0 ou nulos
        final nonZeroValues = values.where((v) => v > 0).toList();
        
        if (nonZeroValues.isNotEmpty) {
          _stats[type] = {
            'count': nonZeroValues.length,
            'avg': nonZeroValues.reduce((a, b) => a + b) / nonZeroValues.length,
            'min': nonZeroValues.reduce((a, b) => a < b ? a : b),
            'max': nonZeroValues.reduce((a, b) => a > b ? a : b),
          };
          
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00324A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00324A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Histórico de Saúde',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            final homeController = Get.find<HomeController>();
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  if (homeController.unreadNotificationsCount.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          homeController.unreadNotificationsCount.value > 9 
                              ? '9+' 
                              : homeController.unreadNotificationsCount.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () async {
                await Get.toNamed(Routes.NOTIFICATIONS);
                try {
                  final homeController = Get.find<HomeController>();
                  await homeController.loadNotificationsCount();
                } catch (e) {
                }
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHealthData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Obx(() {
          if (_isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00324A)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando dados...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 12),
                
                // Filtros
                _buildFilters(),
                const SizedBox(height: 12),
                
                // Estatísticas
                _buildStats(),
                const SizedBox(height: 12),
                
                // Gráfico
                _buildChart(),
                const SizedBox(height: 12),
                
                // Lista de dados
                _buildDataList(),
                const SizedBox(height: 12),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00324A),
            const Color(0xFF00324A).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00324A).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Análise de 8 Semanas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Acompanhe sua evolução com médias semanais',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip('Frequência Cardíaca', 'heartRate', Icons.favorite),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Passos', 'steps', Icons.directions_walk),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Sono', 'sleep', Icons.bedtime),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    return Obx(() => GestureDetector(
      onTap: () {
        _selectedDataType.value = value;
        _loadHealthData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _selectedDataType.value == value 
              ? const Color(0xFF00324A) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: _selectedDataType.value == value 
                  ? Colors.white 
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: _selectedDataType.value == value 
                      ? Colors.white 
                      : const Color(0xFF64748B),
                  fontWeight: _selectedDataType.value == value 
                      ? FontWeight.w600 
                      : FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStats() {
    if (_stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Nenhum dado encontrado',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final currentStats = _stats[_selectedDataType.value];
    if (currentStats == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Nenhum dado encontrado para este tipo',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDataTypeIcon(_selectedDataType.value),
                color: _getDataTypeColor(_selectedDataType.value),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Resumo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStatItem(
                  'Média',
                  '${currentStats['avg'].round()}',
                  Colors.blue,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Mínimo',
                  '${currentStats['min'].round()}',
                  Colors.green,
                  Icons.keyboard_arrow_down,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Máximo',
                  '${currentStats['max'].round()}',
                  Colors.red,
                  Icons.keyboard_arrow_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final filteredData = _healthData
        .where((data) => data['dataType'] == _selectedDataType.value)
        .toList();
    
    // Apenas dados válidos (hasData = true)
    final validData = filteredData.where((data) => data['hasData'] == true).toList();
    
    validData.forEach((data) {
    });

    if (validData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Nenhum dado para exibir no gráfico',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: _getDataTypeColor(_selectedDataType.value),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Evolução Semanal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (validData.length - 1).toDouble(),
                minY: 0,
                maxY: validData.isNotEmpty 
                    ? validData.map((d) => d['value'] as double).reduce((a, b) => a > b ? a : b) * 1.1
                    : 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < validData.length) {
                          return Text(
                            'Sem ${value.toInt() + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: validData.asMap().entries.map((entry) {
                        final data = entry.value;
                        final value = (data['value'] as num).toDouble();
                        return FlSpot(entry.key.toDouble(), value);
                      }).toList(),
                      isCurved: true,
                      color: _getDataTypeColor(_selectedDataType.value),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _getDataTypeColor(_selectedDataType.value),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getDataTypeColor(_selectedDataType.value).withOpacity(0.1),
                      ),
                    ),
                  ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    final filteredData = _healthData
        .where((data) => data['dataType'] == _selectedDataType.value)
        .toList();

    // Apenas dados válidos (hasData = true)
    final validData = filteredData.where((data) => data['hasData'] == true).toList();

    if (validData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Nenhum dado válido encontrado',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: _getDataTypeColor(_selectedDataType.value),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Médias Semanais',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...validData.take(6).map((data) => _buildDataItem(data)),
        ],
      ),
    );
  }

  Widget _buildDataItem(Map<String, dynamic> data) {
    final weekNumber = data['weekNumber'] ?? 0;
    final hasData = data['hasData'] ?? false;
    final value = data['value'] ?? 0.0;
    final weekStart = data['date'] as DateTime;
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasData 
            ? _getDataTypeColor(_selectedDataType.value).withOpacity(0.05)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasData 
              ? _getDataTypeColor(_selectedDataType.value).withOpacity(0.2)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hasData 
                  ? _getDataTypeColor(_selectedDataType.value).withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${weekNumber + 1}',
                style: TextStyle(
                  color: hasData 
                      ? _getDataTypeColor(_selectedDataType.value)
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Semana ${weekNumber + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${weekStart.day}/${weekStart.month} até ${weekEnd.day}/${weekEnd.month}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hasData 
                      ? '${value.toStringAsFixed(1)} ${_getDataTypeUnit(_selectedDataType.value)}'
                      : 'Sem dados',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: hasData 
                        ? _getDataTypeColor(_selectedDataType.value)
                        : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  hasData ? 'Média semanal' : 'Nenhum registro',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            hasData 
                ? _getDataTypeIcon(_selectedDataType.value)
                : Icons.remove_circle_outline,
            color: hasData 
                ? _getDataTypeColor(_selectedDataType.value).withOpacity(0.6)
                : Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }

  String _getDataTypeName(String type) {
    switch (type) {
      case 'heartRate': return 'Frequência Cardíaca';
      case 'steps': return 'Passos';
      case 'sleep': return 'Sono';
      default: return type;
    }
  }

  Color _getDataTypeColor(String type) {
    switch (type) {
      case 'heartRate': return Colors.red;
      case 'steps': return Colors.green;
      case 'sleep': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getDataTypeIcon(String type) {
    switch (type) {
      case 'heartRate': return Icons.favorite;
      case 'steps': return Icons.directions_walk;
      case 'sleep': return Icons.bedtime;
      default: return Icons.health_and_safety;
    }
  }

  String _getDataTypeUnit(String type) {
    switch (type) {
      case 'heartRate': return 'bpm';
      case 'steps': return 'passos';
      case 'sleep': return 'horas';
      default: return '';
    }
  }
}