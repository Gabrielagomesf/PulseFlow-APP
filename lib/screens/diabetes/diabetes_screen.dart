import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'diabetes_controller.dart';
import '../../models/diabetes.dart';

class DiabetesScreen extends StatelessWidget {
  final String pacienteId;
  final DiabetesController controller = Get.put(DiabetesController());

  DiabetesScreen({super.key, required this.pacienteId});

  final TextEditingController glicemiaController = TextEditingController();
  final Rx<DateTime?> dataSelecionada = Rx<DateTime?>(null);
  final RxBool mostrarGrafico = false.obs;
  final Rx<DateTime> mesSelecionado = DateTime(DateTime.now().year, DateTime.now().month).obs;

  @override
  Widget build(BuildContext context) {
    controller.carregarRegistros(pacienteId);

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2541),
        elevation: 0,
        title: const Text('Registro de Diabetes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF1F4068),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Novo registro',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: glicemiaController,
                      decoration: const InputDecoration(
                        labelText: 'Glicemia (mg/dL)',
                        hintText: 'Ex: 95',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final dataText = dataSelecionada.value == null
                          ? 'Selecione a data'
                          : _formatarData(dataSelecionada.value!);
                      return InkWell(
                        onTap: () async {
                          final hoje = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dataSelecionada.value ?? hoje,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(hoje.year, hoje.month, hoje.day),
                            helpText: 'Selecione a data da medição',
                            cancelText: 'Cancelar',
                            confirmText: 'Confirmar',
                          );
                          if (picked != null) {
                            dataSelecionada.value = DateTime(picked.year, picked.month, picked.day);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF3A506B)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event, color: Color(0xFF1F4068)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  dataText,
                                  style: const TextStyle(color: Color(0xFF1F4068)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C3B7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () async {
                              if (dataSelecionada.value == null) {
                                Get.snackbar('Data obrigatória', 'Selecione a data da medição');
                                return;
                              }
                              final glicemia = double.tryParse(glicemiaController.text.replaceAll(',', '.'));
                              if (glicemia == null) {
                                Get.snackbar('Glicemia inválida', 'Digite um valor numérico');
                                return;
                              }

                              await controller.adicionarRegistro(
                                pacienteId: pacienteId,
                                glicemia: glicemia,
                                unidade: 'mg/dL',
                                data: dataSelecionada.value!,
                              );

                              glicemiaController.clear();
                              dataSelecionada.value = null;
                            },
                            child: const Text('Registrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00C3B7), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              mostrarGrafico.value = true;
                            },
                            child: const Text('Visualizar dados', style: TextStyle(color: Color(0xFF00C3B7), fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Lista de registros / Gráfico
            Expanded(
              child: Obx(() {
                if (mostrarGrafico.value) {
                  final todos = controller.registros.toList();
                  
                  final filtrados = todos.where((e) {
                    final match = e.data.year == mesSelecionado.value.year && e.data.month == mesSelecionado.value.month;
                    return match;
                  }).toList();
                  
                  return _GraficoDiabetes(
                    registros: filtrados,
                    mesSelecionado: mesSelecionado.value,
                    onPrevMonth: () {
                      final d = mesSelecionado.value;
                      mesSelecionado.value = DateTime(d.year, d.month - 1);
                    },
                    onNextMonth: () {
                      final d = mesSelecionado.value;
                      mesSelecionado.value = DateTime(d.year, d.month + 1);
                    },
                    onClose: () {
                      mostrarGrafico.value = false;
                    },
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: controller.registros.length,
                  itemBuilder: (context, index) {
                    final item = controller.registros[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2541),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF3A506B)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          'Glicemia: ${item.glicemia.toStringAsFixed(1)} ${item.unidade}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Data: ${_formatarData(item.data)}',
                          style: const TextStyle(color: Color(0xFFB0C4DE)),
                        ),
                        leading: const Icon(Icons.opacity, color: Color(0xFF00C3B7)),
                      ),
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return "$dd/$mm/$yyyy";
  }
}

class _GraficoDiabetes extends StatelessWidget {
  final List<Diabetes> registros;
  final DateTime mesSelecionado;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onClose;
  const _GraficoDiabetes({Key? key, required this.registros, required this.mesSelecionado, required this.onPrevMonth, required this.onNextMonth, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = registros.toList()
      ..sort((a, b) => a.data.compareTo(b.data));

    final mes = _formatarMesAno(mesSelecionado);

    return Card(
      color: const Color(0xFF1F4068),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Evolução da Glicemia',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mes,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Conteúdo principal
            if (data.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sem dados para $mes',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Adicione registros para visualizar o gráfico',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Column(
                  children: [
                    // Estatísticas rápidas
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2541),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  '${data.length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Média',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  '${_calcularMediaGlicemia(data)}',
                                  style: const TextStyle(color: Color(0xFF00C3B7), fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Maior',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  '${_calcularMaiorGlicemia(data)}',
                                  style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Lista de dados
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2541),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF3A506B), width: 1),
                            ),
                            child: Row(
                              children: [
                                // Data
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C3B7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${item.data.day}',
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          _formatarMes(item.data.month),
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Informações
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.opacity, color: Color(0xFF00C3B7), size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${item.glicemia.toStringAsFixed(1)} mg/dL',
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.event, color: Colors.white70, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${item.data.day}/${item.data.month}/${item.data.year}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Status da glicemia
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getCorGlicemia(item.glicemia),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getStatusGlicemia(item.glicemia),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Gráfico de linha interativo
                    if (data.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2541),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gráfico de Glicemia',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: (data.length * 80.0).clamp(MediaQuery.of(context).size.width - 64, double.infinity),
                                  height: 200,
                                  child: Stack(
                                    children: [
                                      CustomPaint(
                                        painter: _LineChartPainter(data),
                                        size: Size.infinite,
                                      ),
                                      // Labels dos eixos
                                      Positioned(
                                        left: 10,
                                        top: 10,
                                        child: Text(
                                          'Glicemia (mg/dL)',
                                          style: TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        bottom: 10,
                                        child: Text(
                                          'Dias',
                                          style: TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            // Botões de navegação (na parte inferior)
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onPrevMonth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C2541),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 16),
                  label: const Text('Anterior', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                ElevatedButton.icon(
                  onPressed: onNextMonth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C2541),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 16),
                  label: const Text('Próximo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatarMesAno(DateTime d) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${meses[d.month - 1]} de ${d.year}';
  }

  String _formatarMes(int mes) {
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses[mes - 1];
  }

  String _calcularMediaGlicemia(List<Diabetes> data) {
    if (data.isEmpty) return '0';
    final soma = data.fold<double>(0, (sum, item) => sum + item.glicemia);
    return (soma / data.length).toStringAsFixed(0);
  }

  String _calcularMaiorGlicemia(List<Diabetes> data) {
    if (data.isEmpty) return '0';
    final maior = data.map((e) => e.glicemia).reduce((a, b) => a > b ? a : b);
    return maior.toStringAsFixed(0);
  }

  Color _getCorGlicemia(double glicemia) {
    if (glicemia < 70) {
      return Colors.blue; // Hipoglicemia
    }
    if (glicemia <= 100) {
      return Colors.green; // Normal
    }
    if (glicemia <= 125) {
      return Colors.orange; // Pré-diabetes
    }
    return Colors.red; // Diabetes
  }

  String _getStatusGlicemia(double glicemia) {
    if (glicemia < 70) {
      return 'Baixa';
    }
    if (glicemia <= 100) {
      return 'Normal';
    }
    if (glicemia <= 125) {
      return 'Elevada';
    }
    return 'Alta';
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Diabetes> data;

  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final minGlicemia = data.map((e) => e.glicemia).reduce((a, b) => a < b ? a : b);
    final maxGlicemia = data.map((e) => e.glicemia).reduce((a, b) => a > b ? a : b);
    final glicemiaRange = maxGlicemia - minGlicemia;

    final yAxisWidth = 50.0; // Largura do eixo Y
    final xAxisHeight = 50.0; // Altura do eixo X

    final padding = 40.0; // Padding para o gráfico
    final graphWidth = size.width - yAxisWidth - padding * 2;
    final graphHeight = size.height - xAxisHeight - padding * 2;

    final xAxisStart = padding + yAxisWidth;
    final yAxisStart = size.height - padding - xAxisHeight;

    // Desenha o eixo X
    canvas.drawLine(
      Offset(xAxisStart, yAxisStart),
      Offset(size.width - padding, yAxisStart),
      paint,
    );

    // Desenha o eixo Y
    canvas.drawLine(
      Offset(xAxisStart, yAxisStart),
      Offset(xAxisStart, padding),
      paint,
    );

    // Desenha os pontos
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final x = xAxisStart + (i * 80.0) + 40.0; // Posição X do ponto
      final y = yAxisStart - ((item.glicemia - minGlicemia) / glicemiaRange) * graphHeight;

      canvas.drawCircle(Offset(x, y), 8.0, Paint()..color = _getCorGlicemia(item.glicemia));
    }

    // Desenha a linha conectando os pontos
    if (data.length > 1) {
      for (int i = 0; i < data.length - 1; i++) {
        final startX = xAxisStart + (i * 80.0) + 40.0;
        final startY = yAxisStart - ((data[i].glicemia - minGlicemia) / glicemiaRange) * graphHeight;

        final endX = xAxisStart + ((i + 1) * 80.0) + 40.0;
        final endY = yAxisStart - ((data[i + 1].glicemia - minGlicemia) / glicemiaRange) * graphHeight;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }
    }
  }

  Color _getCorGlicemia(double glicemia) {
    if (glicemia < 70) return Colors.blue; // Hipoglicemia
    if (glicemia <= 100) return Colors.green; // Normal
    if (glicemia <= 125) return Colors.orange; // Pré-diabetes
    return Colors.red; // Diabetes
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


