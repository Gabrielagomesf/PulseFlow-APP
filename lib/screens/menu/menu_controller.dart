import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class MenuController extends GetxController {
  void goToEnxaqueca() {
    Get.toNamed(Routes.ENXAQUECA);
  }

  void goToHistorico() {
    Get.toNamed(Routes.MEDICAL_RECORDS); // Tela de histórico
  }
}
