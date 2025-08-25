import 'package:get/get.dart';
import '../../models/diabetes.dart';
import '../../services/diabetes_service.dart';

class DiabetesController extends GetxController {
  final DiabetesService _service = Get.put(DiabetesService());

  var registros = <Diabetes>[].obs;

  Future<void> carregarRegistros(String pacienteId) async {
    print('Carregando registros de diabetes para paciente: $pacienteId');
    registros.value = await _service.getByPacienteId(pacienteId);
    print('Registros carregados: ${registros.length}');
    for (final registro in registros) {
      print('Registro: ${registro.data.day}/${registro.data.month}/${registro.data.year} - Glicemia: ${registro.glicemia}');
    }
  }

  Future<void> adicionarRegistro({
    required String pacienteId,
    required double glicemia,
    required String unidade,
    required DateTime data,
  }) async {
    final registro = Diabetes(
      pacienteId: pacienteId,
      data: data,
      glicemia: glicemia,
      unidade: unidade,
    );

    final criado = await _service.create(registro);
    registros.add(criado);
  }
}

