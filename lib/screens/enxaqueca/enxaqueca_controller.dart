import 'package:get/get.dart';
import '../../models/enxaqueca.dart';
import '../../services/enxaqueca_service.dart';

class EnxaquecaController extends GetxController {
  final EnxaquecaService _service = Get.put(EnxaquecaService());

  var registros = <Enxaqueca>[].obs;

  Future<void> carregarRegistros(String pacienteId) async {
    print('Carregando registros de enxaqueca para paciente: $pacienteId');
    registros.value = await _service.getByPacienteId(pacienteId);
    print('Registros carregados: ${registros.length}');
    for (final registro in registros) {
      print('Registro: ${registro.data.day}/${registro.data.month}/${registro.data.year} - Intensidade: ${registro.intensidade}');
    }
  }

  Future<void> adicionarRegistro({
    required String pacienteId,
    required String intensidade,
    required int duracao,
    required DateTime data,
  }) async {
    final enxaqueca = Enxaqueca(
      pacienteId: pacienteId,
      data: data,
      intensidade: intensidade,
      duracao: duracao,
    );

    final criado = await _service.create(enxaqueca);
    registros.add(criado);
  }
}
