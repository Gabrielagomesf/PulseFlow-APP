import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../utils/controller_mixin.dart';

class LoginController extends GetxController with SafeControllerMixin {
  final AuthService _authService = Get.find<AuthService>();
  final formKey = GlobalKey<FormState>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Adicionar controllers ao gerenciamento seguro
    addControllers([emailController, passwordController]);
    // Limpar controllers de forma segura
    clearControllers();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      // Novo fluxo: login inicial, gera e envia código 2FA
      final patientId = await _authService.loginWith2FA(
        emailController.text.trim(),
        passwordController.text,
      );
      // Redireciona para tela de verificação 2FA
      Get.toNamed('/verify-2fa', arguments: {'patientId': patientId});
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 