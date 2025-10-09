import 'package:get/get.dart';
import '../../models/exame.dart';
import '../../services/exame_service.dart';

class ExameController extends GetxController {
  final ExameService _service = Get.put(ExameService());

  var exames = <Exame>[].obs;
  var mesSelecionado = DateTime(DateTime.now().year, DateTime.now().month).obs;
  RxList<Exame> examesFiltrados = <Exame>[].obs;

  // Filtros
  var filtroNome = ''.obs;
  var filtroCategoria = ''.obs;
  var filtroInicio = Rxn<DateTime>();
  var filtroFim = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    ever(exames, (_) => _filtrar());
    everAll([mesSelecionado, filtroNome, filtroCategoria, filtroInicio, filtroFim], (_) => _filtrar());
  }

  void _filtrar() {
    final start = filtroInicio.value;
    final end = filtroFim.value;
    final nome = filtroNome.value.trim().toLowerCase();
    final cat = filtroCategoria.value.trim().toLowerCase();

    examesFiltrados.value = exames.where((e) {
      final byMonth = e.data.year == mesSelecionado.value.year && e.data.month == mesSelecionado.value.month;
      if (!byMonth) return false;

      final byName = nome.isEmpty || e.nome.toLowerCase().contains(nome);
      final byCat = cat.isEmpty || e.categoria.toLowerCase().contains(cat);
      final byStart = start == null || !e.data.isBefore(DateTime(start.year, start.month, start.day));
      final byEnd = end == null || !e.data.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59));
      return byName && byCat && byStart && byEnd;
    }).toList();
  }

  Future<void> carregarExames(String pacienteId) async {
    exames.value = await _service.getByPaciente(pacienteId);
    _filtrar();
  }

  Future<void> adicionarExame(Exame exame) async {
    final created = await _service.create(exame);
    exames.add(created);
  }

  Future<void> removerExame(String exameId) async {
    await _service.delete(exameId);
    exames.removeWhere((e) => e.id == exameId);
    _filtrar();
  }

  Future<void> removerExameByObject(Exame exame) async {
    await _service.deleteByObject(exame);
    exames.removeWhere((e) =>
        (e.id != null && e.id == exame.id) ||
        (e.id == null && e.filePath == exame.filePath && e.nome == exame.nome));
    _filtrar();
  }
}


