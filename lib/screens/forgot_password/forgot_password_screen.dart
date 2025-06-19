import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      init: ForgotPasswordController(),
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
                            Icons.lock_reset,
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
                            'Esqueceu sua senha?',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF222B45),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtítulo
                          Text(
                            'Digite seu e-mail para receber um código de redefinição',
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
                                // Campo de e-mail
                                TextFormField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail',
                                    hintText: 'Digite seu e-mail cadastrado',
                                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1CB5E0)),
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
                                      return 'Por favor, digite seu e-mail';
                                    }
                                    if (!GetUtils.isEmail(value)) {
                                      return 'Por favor, digite um e-mail válido';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Botão de enviar código
                                Obx(() => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value ? null : controller.sendResetCode,
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
                                            'Enviar Código',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
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
                                      'Voltar para o login',
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