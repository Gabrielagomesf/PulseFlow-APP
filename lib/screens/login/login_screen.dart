import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usar GetX para gerenciar o controller de forma mais segura
    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) {
        final size = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: const Color(0xFF1CB5E0),
          body: SafeArea(
            child: Column(
              children: [
                // Header curvo azul com Lottie animado
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
                        alignment: Alignment(0, 0.5),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mensagem acolhedora animada
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Bem-vindo de volta!',
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                    speed: const Duration(milliseconds: 60),
                                  ),
                                ],
                                totalRepeatCount: 1,
                                pause: const Duration(milliseconds: 500),
                                displayFullTextOnTap: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                FadeAnimatedText('Acesse sua área do paciente'),
                              ],
                              totalRepeatCount: 1,
                              pause: const Duration(milliseconds: 200),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Card do formulário
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: controller.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Email
                                  Text(
                                    'E-MAIL',
                                    style: TextStyle(
                                      color: const Color(0xFF1CB5E0),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: controller.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'Digite seu e-mail',
                                      hintStyle: TextStyle(color: Colors.grey[500]),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1CB5E0)),
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
                                  const SizedBox(height: 16),
                                  // Senha
                                  Text(
                                    'SENHA',
                                    style: TextStyle(
                                      color: const Color(0xFF1CB5E0),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Obx(() => TextFormField(
                                    controller: controller.passwordController,
                                    obscureText: controller.obscurePassword.value,
                                    decoration: InputDecoration(
                                      hintText: 'Digite sua senha',
                                      hintStyle: TextStyle(color: Colors.grey[500]),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
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
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, digite sua senha';
                                      }
                                      if (value.length < 6) {
                                        return 'A senha deve ter pelo menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  )),
                                  const SizedBox(height: 8),
                                  // Lembrar-me e Esqueceu a senha
                                  Row(
                                    children: [
                                      Obx(() => Checkbox(
                                            value: controller.rememberMe.value,
                                            onChanged: (v) => controller.rememberMe.value = v ?? false,
                                            activeColor: const Color(0xFF1CB5E0),
                                          )),
                                      const SizedBox(width: 6),
                                      Text('Lembrar-me', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => Get.toNamed('/forgot-password'),
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                        child: const Text(
                                          'Esqueceu a senha?',
                                          style: TextStyle(color: Color(0xFF1CB5E0), fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Botão Entrar com animação
                                  AnimatedBuilder(
                                    animation: _fadeController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 0.95 + 0.05 * _fadeAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: Obx(() => ElevatedButton.icon(
                                        onPressed: controller.isLoading.value ? null : controller.login,
                                        icon: controller.isLoading.value 
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Icon(Icons.login, color: Colors.white, size: 20),
                                        label: Text(
                                          controller.isLoading.value ? 'Entrando...' : 'Entrar',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1CB5E0),
                                          shadowColor: const Color(0xFF1CB5E0).withOpacity(0.3),
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Botão de cadastro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Não tem uma conta? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed('/registration'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Cadastre-se',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
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

class _CurvedHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.55, size.width * 0.35, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.7, size.width * 0.8, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.95, 0, size.width, size.height * 0.2);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 8, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
} 