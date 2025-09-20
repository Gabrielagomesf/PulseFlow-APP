import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFF00324A), // Cor de fundo azul para ocupar toda a tela
      body: Column(
        children: [
          // Header com perfil - sem SafeArea para ocupar toda a área superior
          _buildHeader(controller),
          
          // Conteúdo principal
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00324A)), // Nova cor azul
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: controller.refreshPatientData,
                  color: const Color(0xFF00324A), // Nova cor azul
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seção Favorito
                        _buildFavoriteSection(),
                        const SizedBox(height: 24),
                        
                        // Seção Atalhos
                        _buildShortcutsSection(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(HomeController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16, // Adiciona padding da status bar
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF00324A), // Nova cor azul
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Top row com logo centralizado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo do PulseFlow
              _buildPulseFlowLogo(),
            ],
          ),
          const SizedBox(height: 20),
          
          // Perfil do usuário
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: controller.getProfilePhoto() != null
                    ? ClipOval(
                        child: Image.network(
                          controller.getProfilePhoto()!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
              
              // Informações do usuário - Corrigido overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.getGreeting(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.getPatientName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Reduzi o tamanho da fonte
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Adicionei ellipsis para overflow
                      maxLines: 1, // Limitei a uma linha
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Row(
          children: [
            const Icon(
              Icons.lightbulb,
              color: Color(0xFFFFA726),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Favorito',
              style: AppTheme.titleSmall.copyWith(
                color: const Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Card do gráfico
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF00324A), // Nova cor azul
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: _buildHeartRateChart(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Frequência Cardíaca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeartRateChart() {
    // Simulando dados vazios - você pode implementar lógica real aqui
    bool hasData = true; // Mude para false para testar o estado "sem dados"
    
    if (!hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              color: Colors.white54,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'Sem dados',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Nenhum registro de frequência cardíaca encontrado',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('A', style: style);
                    break;
                  case 1:
                    text = const Text('B', style: style);
                    break;
                  case 2:
                    text = const Text('C', style: style);
                    break;
                  case 3:
                    text = const Text('D', style: style);
                    break;
                  case 4:
                    text = const Text('E', style: style);
                    break;
                  case 5:
                    text = const Text('F', style: style);
                    break;
                  case 6:
                    text = const Text('G', style: style);
                    break;
                  case 7:
                    text = const Text('H', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: text,
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1000,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 7,
        minY: 0,
        maxY: 8000,
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 2000),
              const FlSpot(1, 3000),
              const FlSpot(2, 2500),
              const FlSpot(3, 4000),
              const FlSpot(4, 3500),
              const FlSpot(5, 5000),
              const FlSpot(6, 4500),
              const FlSpot(7, 6000),
            ],
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF64B5F6).withOpacity(0.3),
                  const Color(0xFF64B5F6).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: [
              const FlSpot(0, 1500),
              const FlSpot(1, 2500),
              const FlSpot(2, 2000),
              const FlSpot(3, 3000),
              const FlSpot(4, 2800),
              const FlSpot(5, 3500),
              const FlSpot(6, 3200),
              const FlSpot(7, 4000),
            ],
            isCurved: true,
            color: const Color(0xFFFFA726),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [
              const FlSpot(0, 1000),
              const FlSpot(1, 1800),
              const FlSpot(2, 1500),
              const FlSpot(3, 2200),
              const FlSpot(4, 2000),
              const FlSpot(5, 2500),
              const FlSpot(6, 2300),
              const FlSpot(7, 2800),
            ],
            isCurved: true,
            color: const Color(0xFF1976D2),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsSection() {
    // Simulando dados vazios - você pode implementar lógica real aqui
    bool hasShortcuts = true; // Mude para false para testar o estado "sem dados"
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Row(
          children: [
            const Icon(
              Icons.push_pin,
              color: Color(0xFFE53935),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Atalhos',
              style: AppTheme.titleSmall.copyWith(
                color: const Color(0xFF00324A), // Nova cor azul
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Cards de atalhos ou estado "sem dados"
        if (!hasShortcuts)
          _buildNoShortcutsState()
        else ...[
          _buildShortcutCard(
            'Cabeça (Ressonância)',
            'Categoria: Neurologia',
            'Data: 30/10/2000',
          ),
          const SizedBox(height: 12),
          _buildShortcutCard(
            'Cabeça (Ressonância)',
            'Categoria: Neurologia',
            'Data: 30/10/2000',
          ),
          const SizedBox(height: 12),
          _buildShortcutCard(
            'Cabeça (Ressonância)',
            'Categoria: Neurologia',
            'Data: 30/10/2000',
          ),
        ],
      ],
    );
  }
  
  Widget _buildNoShortcutsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.folder_open,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'Sem atalhos',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Nenhum exame recente encontrado',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard(String title, String category, String date) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Exame Selecionado',
          'Visualizando detalhes do exame: $title',
          backgroundColor: const Color(0xFF00324A), // Nova cor azul
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: AppTheme.bodyMedium.copyWith(
                      color: const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: AppTheme.bodyMedium.copyWith(
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Download',
                  'Iniciando download do exame: $title',
                  backgroundColor: const Color(0xFF4CAF50),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00324A), // Nova cor azul
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Baixar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF00324A), // Nova cor azul
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Início', true, () {}),
          _buildNavItem(Icons.grid_view, 'Relatórios', false, () {
            Get.toNamed('/medical-records');
          }),
          _buildNavItem(Icons.add, 'Registro', false, () {
            Get.toNamed('/menu');
          }),
          _buildNavItem(Icons.vpn_key, 'Pulse Key', false, () {
            // TODO: Implementar tela Pulse Key
            Get.snackbar(
              'Em Breve',
              'Funcionalidade Pulse Key será implementada em breve!',
              backgroundColor: const Color(0xFF00324A), // Nova cor azul
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }),
          _buildNavItem(Icons.person, 'Perfil', false, () {
            // TODO: Implementar tela de perfil
            Get.snackbar(
              'Em Breve',
              'Tela de perfil será implementada em breve!',
              backgroundColor: const Color(0xFF00324A), // Nova cor azul
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget personalizado para a logo do PulseFlow
  Widget _buildPulseFlowLogo() {
    return Container(
      width: 140,
      height: 45,
      child: Image.asset(
        'assets/images/PulseNegativo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback caso a imagem não seja encontrada
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Center(
              child: Text(
                'PulseFlow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 