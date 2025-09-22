import 'package:get/get.dart';
import '../../models/enxaqueca.dart';
import '../../services/enxaqueca_service.dart';

class EnxaquecaController extends GetxController {
  final EnxaquecaService _service = Get.put(EnxaquecaService());

  var registros = <Enxaqueca>[].obs;
  var mesSelecionado = DateTime(DateTime.now().year, DateTime.now().month).obs;
  RxList<Enxaqueca> registrosFiltrados = <Enxaqueca>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(registros, (_) => _filtrarRegistros());
    ever(mesSelecionado, (_) => _filtrarRegistros());
  }

  void _filtrarRegistros() {
    registrosFiltrados.value = registros.where((e) {
      return e.data.year == mesSelecionado.value.year &&
          e.data.month == mesSelecionado.value.month;
    }).toList();
  }

  Future<void> carregarRegistros(String pacienteId) async {
    print('Carregando registros de enxaqueca para paciente: $pacienteId');
    registros.value = await _service.getByPacienteId(pacienteId);
    print('Registros carregados: ${registros.length}');
    for (final registro in registros) {
      print('Registro: ${registro.data.day}/${registro.data.month}/${registro.data.year} - Intensidade: ${registro.intensidade}');
    }
    _filtrarRegistros(); // Initial filtering after loading
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
