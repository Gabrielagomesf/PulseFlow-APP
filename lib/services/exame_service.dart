import 'package:get/get.dart';
import '../models/exame.dart';
import 'database_service.dart';

class ExameService {
  final DatabaseService _db = Get.find<DatabaseService>();

  Future<Exame> create(Exame exame) async {
    return _db.createExame(exame);
  }

  Future<List<Exame>> getByPaciente(String pacienteId) async {
    return _db.getExamesByPaciente(pacienteId);
  }

  Future<void> delete(String exameId) async {
    await _db.deleteExame(exameId);
  }

  Future<void> deleteByObject(Exame exame) async {
    await _db.deleteExameByObject(exame);
  }
}


