import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível fazer logout. Tente novamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 