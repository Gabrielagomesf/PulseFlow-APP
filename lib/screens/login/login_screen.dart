import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) {
        final size = MediaQuery.of(context).size;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1CB5E0),
                  Color(0xFF000046),
                  Color(0xFF1CB5E0),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Background animated circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  
                  // Main content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      height: size.height,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Header section
                          Expanded(
                            flex: 2,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo container
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.white, Color(0xFFE3F2FD)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Color(0xFF1CB5E0),
                                      size: 60,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // App name with animation
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        'PulseFlow Saúde',
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                        speed: const Duration(milliseconds: 100),
                                      ),
                                    ],
                                    totalRepeatCount: 1,
                                    pause: const Duration(milliseconds: 500),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Subtitle
                                  DefaultTextStyle(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        FadeAnimatedText('Cuidando da sua saúde com tecnologia'),
                                      ],
                                      totalRepeatCount: 1,
                                      pause: const Duration(milliseconds: 200),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Login form section
                          Expanded(
                            flex: 3,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: controller.formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Welcome text
                                        const Text(
                                          'Bem-vindo de volta!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF222B45),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Acesse sua área do paciente',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        
                                        // Email field
                                        _buildTextField(
                                          controller: controller.emailController,
                                          label: 'E-mail',
                                          icon: Icons.email_outlined,
                                          keyboardType: TextInputType.emailAddress,
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
                                        const SizedBox(height: 20),
                                        
                                        // Password field
                                        Obx(() => _buildPasswordField(
                                          controller: controller.passwordController,
                                          label: 'Senha',
                                          obscureText: controller.obscurePassword.value,
                                          onToggleVisibility: controller.togglePasswordVisibility,
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
                                        const SizedBox(height: 16),
                                        
                                        // Remember me and forgot password
                                        Row(
                                          children: [
                                            Obx(() => Transform.scale(
                                              scale: 0.9,
                                              child: Checkbox(
                                                value: controller.rememberMe.value,
                                                onChanged: (v) => controller.rememberMe.value = v ?? false,
                                                activeColor: const Color(0xFF1CB5E0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            )),
                                            Text(
                                              'Lembrar-me',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            TextButton(
                                              onPressed: () => Get.toNamed('/forgot-password'),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: const Text(
                                                'Esqueceu a senha?',
                                                style: TextStyle(
                                                  color: Color(0xFF1CB5E0),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 32),
                                        
                                        // Login button
                                        Obx(() => Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF1CB5E0).withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: controller.isLoading.value ? null : controller.login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: controller.isLoading.value
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.login, color: Colors.white, size: 20),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'Entrar',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        )),
                                        const SizedBox(height: 24),
                                        
                                        // Divider
                                        Row(
                                          children: [
                                            Expanded(child: Divider(color: Colors.grey[300])),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                'ou',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Expanded(child: Divider(color: Colors.grey[300])),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // Register button
                                        Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFF1CB5E0),
                                              width: 2,
                                            ),
                                          ),
                                          child: TextButton(
                                            onPressed: () => Get.toNamed('/registration'),
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Criar nova conta',
                                              style: TextStyle(
                                                color: Color(0xFF1CB5E0),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF1CB5E0), size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1CB5E0), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[500],
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
} 