import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResetPasswordController>(
      init: ResetPasswordController(),
      builder: (controller) {
        final size = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: const Color(0xFF1CB5E0),
          body: SafeArea(
            child: Column(
              children: [
                // Header curvo azul
                SizedBox(
                  height: size.height * 0.25,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(size.width, size.height * 0.25),
                        painter: _CurvedHeaderPainter(),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.5),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_open,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Conteúdo principal
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Título
                          Text(
                            'Redefinir Senha',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF222B45),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtítulo
                          Text(
                            'Digite o código recebido e sua nova senha',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Formulário
                          Form(
                            key: controller.formKey,
                            child: Column(
                              children: [
                                // Campo de código
                                TextFormField(
                                  controller: controller.codeController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    labelText: 'Código de Verificação',
                                    hintText: 'Digite o código de 6 dígitos',
                                    prefixIcon: const Icon(Icons.security, color: Color(0xFF1CB5E0)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
                                    ),
                                    fillColor: Colors.grey[50],
                                    filled: true,
                                    counterText: '',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite o código';
                                    }
                                    if (value.length != 6) {
                                      return 'O código deve ter 6 dígitos';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Campo de nova senha
                                Obx(() => TextFormField(
                                  controller: controller.newPasswordController,
                                  obscureText: controller.obscurePassword.value,
                                  decoration: InputDecoration(
                                    labelText: 'Nova Senha',
                                    hintText: 'Digite sua nova senha',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1CB5E0)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.obscurePassword.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: controller.togglePasswordVisibility,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
                                    ),
                                    fillColor: Colors.grey[50],
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite a nova senha';
                                    }
                                    if (value.length < 6) {
                                      return 'A senha deve ter pelo menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                )),
                                
                                const SizedBox(height: 16),
                                
                                // Campo de confirmar senha
                                Obx(() => TextFormField(
                                  controller: controller.confirmPasswordController,
                                  obscureText: controller.obscureConfirmPassword.value,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar Nova Senha',
                                    hintText: 'Confirme sua nova senha',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1CB5E0)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.obscureConfirmPassword.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: controller.toggleConfirmPasswordVisibility,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
                                    ),
                                    fillColor: Colors.grey[50],
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, confirme a nova senha';
                                    }
                                    if (value != controller.newPasswordController.text) {
                                      return 'As senhas não coincidem';
                                    }
                                    return null;
                                  },
                                )),
                                
                                const SizedBox(height: 24),
                                
                                // Botão de redefinir senha
                                Obx(() => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value ? null : controller.resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1CB5E0),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Redefinir Senha',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                )),
                                
                                const SizedBox(height: 16),
                                
                                // Botão reenviar código
                                Obx(() => SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: controller.isResending.value ? null : controller.resendCode,
                                    icon: controller.isResending.value
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF1CB5E0),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.refresh, color: Color(0xFF1CB5E0)),
                                    label: Text(
                                      controller.isResending.value ? 'Reenviando...' : 'Reenviar código',
                                      style: const TextStyle(
                                        color: Color(0xFF1CB5E0),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )),
                                
                                const SizedBox(height: 16),
                                
                                // Botão voltar
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text(
                                      'Voltar',
                                      style: TextStyle(
                                        color: Color(0xFF1CB5E0),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }
}

// Custom painter para o header curvo
class _CurvedHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1CB5E0)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 