import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResetPasswordController>(
      init: ResetPasswordController(),
      builder: (controller) {
        final size = MediaQuery.of(context).size;
        final isSmallScreen = size.width < 480;
        final isMediumScreen = size.width >= 480 && size.width < 768;
        final isLargeScreen = size.width >= 768 && size.width < 1024;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00324A),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header section
                  Expanded(
                    flex: isSmallScreen ? 2 : 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 6 : 10),
                        // Logo
                        Image.asset(
                          'assets/images/pulseflow2.png',
                          width: isSmallScreen ? 80 : isMediumScreen ? 100 : isLargeScreen ? 120 : 140,
                          height: isSmallScreen ? 80 : isMediumScreen ? 100 : isLargeScreen ? 120 : 140,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Text(
                          'Redefinir Senha',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : isMediumScreen ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 2 : 4),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 30),
                          child: Text(
                            'Digite o código recebido e sua nova senha',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.3,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 10),
                      ],
                    ),
                  ),
                  
                  // Content section
                  Expanded(
                    flex: isSmallScreen ? 6 : 7,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: isSmallScreen ? 20 : isMediumScreen ? 30 : isLargeScreen ? 35 : 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header do container
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 20 : 24,
                              horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Get.back(),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: const Color(0xFF00324A),
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Nova Senha',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : isMediumScreen ? 20 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00324A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48), // Espaço para balancear o layout
                              ],
                            ),
                          ),
                          // Conteúdo do formulário
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                                0,
                                isSmallScreen ? 8 : isMediumScreen ? 12 : isLargeScreen ? 16 : 20,
                                isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                              ),
                              child: Form(
                                key: controller.formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Campo de código
                                    _buildTextField(
                                      controller: controller.codeController,
                                      label: 'Código de Verificação',
                                      hint: 'Digite o código de 6 dígitos',
                                      icon: Icons.security,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, digite o código';
                                        }
                                        if (value.length != 6) {
                                          return 'O código deve ter 6 dígitos';
                                        }
                                        return null;
                                      },
                                      isSmallScreen: isSmallScreen,
                                      isMediumScreen: isMediumScreen,
                                      isLargeScreen: isLargeScreen,
                                    ),
                                    
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    
                                    // Campo de nova senha
                                    Obx(() => _buildPasswordField(
                                      controller: controller.newPasswordController,
                                      label: 'Nova Senha',
                                      hint: 'Digite sua nova senha',
                                      icon: Icons.lock_outline,
                                      obscureText: controller.obscurePassword.value,
                                      onToggleVisibility: controller.togglePasswordVisibility,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, digite a nova senha';
                                        }
                                        if (value.length < 6) {
                                          return 'A senha deve ter pelo menos 6 caracteres';
                                        }
                                        return null;
                                      },
                                      isSmallScreen: isSmallScreen,
                                      isMediumScreen: isMediumScreen,
                                      isLargeScreen: isLargeScreen,
                                    )),
                                    
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    
                                    // Campo de confirmar senha
                                    Obx(() => _buildPasswordField(
                                      controller: controller.confirmPasswordController,
                                      label: 'Confirmar Nova Senha',
                                      hint: 'Confirme sua nova senha',
                                      icon: Icons.lock_outline,
                                      obscureText: controller.obscureConfirmPassword.value,
                                      onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, confirme a nova senha';
                                        }
                                        if (value != controller.newPasswordController.text) {
                                          return 'As senhas não coincidem';
                                        }
                                        return null;
                                      },
                                      isSmallScreen: isSmallScreen,
                                      isMediumScreen: isMediumScreen,
                                      isLargeScreen: isLargeScreen,
                                    )),
                                    
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    
                                    // Botão de redefinir senha
                                    Obx(() => Container(
                                      width: double.infinity,
                                      height: isSmallScreen ? 48 : isMediumScreen ? 52 : isLargeScreen ? 56 : 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00324A),
                                        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00324A).withValues(alpha: 0.3),
                                            blurRadius: isSmallScreen ? 10 : isMediumScreen ? 12 : isLargeScreen ? 15 : 18,
                                            offset: Offset(0, isSmallScreen ? 5 : isMediumScreen ? 6 : isLargeScreen ? 8 : 10),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: controller.isLoading.value ? null : controller.resetPassword,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                                            vertical: isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
                                          ),
                                        ),
                                        child: controller.isLoading.value
                                            ? SizedBox(
                                                width: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22,
                                                height: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22,
                                                child: const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lock_reset,
                                                    color: Colors.white,
                                                    size: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22,
                                                  ),
                                                  SizedBox(width: isSmallScreen ? 8 : isMediumScreen ? 10 : isLargeScreen ? 12 : 14),
                                                  Text(
                                                    'Redefinir Senha',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: isSmallScreen ? 15 : isMediumScreen ? 16 : isLargeScreen ? 17 : 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    )),
                                    
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    
                                    // Botão reenviar código
                                    Obx(() => Container(
                                      width: double.infinity,
                                      height: isSmallScreen ? 44 : isMediumScreen ? 48 : isLargeScreen ? 52 : 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
                                        border: Border.all(
                                          color: const Color(0xFF00324A).withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: TextButton.icon(
                                        onPressed: controller.isResending.value ? null : controller.resendCode,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                                            vertical: isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
                                          ),
                                        ),
                                        icon: controller.isResending.value
                                            ? SizedBox(
                                                width: isSmallScreen ? 16 : isMediumScreen ? 18 : isLargeScreen ? 19 : 20,
                                                height: isSmallScreen ? 16 : isMediumScreen ? 18 : isLargeScreen ? 19 : 20,
                                                child: const CircularProgressIndicator(
                                                  color: Color(0xFF00324A),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Icon(
                                                Icons.refresh,
                                                color: const Color(0xFF00324A),
                                                size: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22,
                                              ),
                                        label: Text(
                                          controller.isResending.value ? 'Reenviando...' : 'Reenviar código',
                                          style: TextStyle(
                                            color: const Color(0xFF00324A),
                                            fontWeight: FontWeight.w600,
                                            fontSize: isSmallScreen ? 15 : isMediumScreen ? 16 : isLargeScreen ? 17 : 18,
                                          ),
                                        ),
                                      ),
                                    )),
                                    
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    
                                    // Botão voltar
                                    Container(
                                      width: double.infinity,
                                      height: isSmallScreen ? 44 : isMediumScreen ? 48 : isLargeScreen ? 52 : 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
                                        border: Border.all(
                                          color: const Color(0xFF00324A).withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed: () => Get.back(),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                                            vertical: isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_back,
                                              color: const Color(0xFF00324A),
                                              size: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22,
                                            ),
                                            SizedBox(width: isSmallScreen ? 8 : isMediumScreen ? 10 : isLargeScreen ? 12 : 14),
                                            Text(
                                              'Voltar',
                                              style: TextStyle(
                                                color: const Color(0xFF00324A),
                                                fontWeight: FontWeight.w600,
                                                fontSize: isSmallScreen ? 15 : isMediumScreen ? 16 : isLargeScreen ? 17 : 18,
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isLargeScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : isMediumScreen ? 17 : isLargeScreen ? 17 : 18,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF00324A),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00324A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00324A), size: isSmallScreen ? 18 : isMediumScreen ? 19 : isLargeScreen ? 19 : 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00324A), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : isMediumScreen ? 22 : isLargeScreen ? 23 : 24, 
            vertical: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22
          ),
          counterText: maxLength != null ? '' : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isLargeScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : isMediumScreen ? 17 : isLargeScreen ? 17 : 18,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF00324A),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00324A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00324A), size: isSmallScreen ? 18 : isMediumScreen ? 19 : isLargeScreen ? 19 : 20),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00324A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF00324A),
                size: isSmallScreen ? 18 : isMediumScreen ? 19 : isLargeScreen ? 19 : 20,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00324A), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : isMediumScreen ? 22 : isLargeScreen ? 23 : 24, 
            vertical: isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 17 : 18
          ),
        ),
        validator: validator,
      ),
    );
  }
}