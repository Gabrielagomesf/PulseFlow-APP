import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../../widgets/biometric_login_button.dart';

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
      builder: (controller) {
        final size = MediaQuery.of(context).size;
        final isSmallScreen = size.width < 480;  // Mobile
        final isMediumScreen = size.width >= 480 && size.width < 768;  // Tablet portrait
        final isLargeScreen = size.width >= 768 && size.width < 1024;  // Tablet landscape
        final isXLargeScreen = size.width >= 1024;  // Desktop
        final isVerySmallScreen = size.height < 700; // Para telas muito baixas
        
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00324A),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Main content
                  isXLargeScreen 
                    ? _buildLargeScreenLayout()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 20 : isMediumScreen ? 32 : isLargeScreen ? 40 : 48,
                        ),
                        child: Column(
                          children: [
                            // Header section
                            Expanded(
                              flex: isVerySmallScreen ? 2 : isSmallScreen ? 2 : isMediumScreen ? 3 : 3,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/pulseflow2.png',
                                    width: isVerySmallScreen ? 120 : isSmallScreen ? 150 : isMediumScreen ? 200 : isLargeScreen ? 240 : 280,
                                    height: isVerySmallScreen ? 120 : isSmallScreen ? 150 : isMediumScreen ? 200 : isLargeScreen ? 240 : 280,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Login form section - Container branco vai até o final
                            Expanded(
                              flex: isVerySmallScreen ? 5 : isSmallScreen ? 4 : isMediumScreen ? 4 : 4,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
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
                                        // Header do container com linha decorativa
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            vertical: isVerySmallScreen ? 12 : isSmallScreen ? 16 : isMediumScreen ? 20 : 24,
                                            horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(32),
                                              topRight: Radius.circular(32),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              // Linha decorativa
                                              Container(
                                                width: 50,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00324A).withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              SizedBox(height: isSmallScreen ? 12 : isMediumScreen ? 16 : 20),
                                              // Título de boas-vindas
                                              Text(
                                                'Bem-vindo de volta',
                                                style: TextStyle(
                                                  fontSize: isVerySmallScreen ? 20 : isSmallScreen ? 24 : isMediumScreen ? 26 : 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF00324A),
                                                ),
                                              ),
                                              SizedBox(height: isSmallScreen ? 4 : isMediumScreen ? 6 : 8),
                                              Text(
                                                'Entre com suas credenciais para acessar sua conta',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
                                                  color: Colors.grey[600],
                                                  height: 1.4,
                                                ),
                                              ),
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
                                              isVerySmallScreen ? 8 : isSmallScreen ? 12 : isMediumScreen ? 16 : isLargeScreen ? 20 : 24,
                                              isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                                            ),
                                            child: _buildLoginForm(),
                                          ),
                                        ),
                                      ],
                                    ),
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
        );
      },
    );
  }

  // Layout para telas grandes (desktop/tablet)
  Widget _buildLargeScreenLayout() {
    final size = MediaQuery.of(context).size;
    final isXLargeScreen = size.width >= 1024;
    
    return Row(
      children: [
        // Lado esquerdo - Logo
        Expanded(
          flex: 1,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/pulseflow2.png',
                  width: isXLargeScreen ? 360 : 320,
                  height: isXLargeScreen ? 360 : 320,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
        
        // Lado direito - Formulário
        Expanded(
          flex: 1,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Formulário de login reutilizável
  Widget _buildLoginForm() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    final isXLargeScreen = size.width >= 1024;
    final isVerySmallScreen = size.height < 700;
    
    return Form(
      key: Get.find<LoginController>().formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Email field
          _buildTextField(
            controller: Get.find<LoginController>().emailController,
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
          SizedBox(height: isVerySmallScreen ? 6 : isSmallScreen ? 8 : isMediumScreen ? 12 : isLargeScreen ? 14 : 16),
          
          // Password field
          Obx(() => _buildPasswordField(
            controller: Get.find<LoginController>().passwordController,
            label: 'Senha',
            obscureText: Get.find<LoginController>().obscurePassword.value,
            onToggleVisibility: Get.find<LoginController>().togglePasswordVisibility,
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
          SizedBox(height: isVerySmallScreen ? 4 : isSmallScreen ? 6 : isMediumScreen ? 8 : isLargeScreen ? 10 : 12),
          
          // Remember me and forgot password
          Row(
            children: [
              Obx(() => Transform.scale(
                scale: isSmallScreen ? 0.8 : isMediumScreen ? 0.85 : isLargeScreen ? 0.9 : 0.95,
                child: Checkbox(
                  value: Get.find<LoginController>().rememberMe.value,
                  onChanged: (v) async {
                    Get.find<LoginController>().rememberMe.value = v ?? false;
                    // Salvar/remover credenciais imediatamente
                    if (v == true) {
                      await Get.find<LoginController>().saveCredentials();
                      Get.snackbar(
                        'Sucesso',
                        'Credenciais salvas para próximo login',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    } else {
                      await Get.find<LoginController>().clearSavedCredentials();
                      Get.snackbar(
                        'Info',
                        'Credenciais removidas',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  activeColor: const Color(0xFF00324A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )),
              Text(
                'Lembrar-me',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : isMediumScreen ? 13 : isLargeScreen ? 14 : 15,
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
                child:                   Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: const Color(0xFF00324A),
                      fontSize: isSmallScreen ? 12 : isMediumScreen ? 13 : isLargeScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ),
            ],
          ),
          SizedBox(height: isVerySmallScreen ? 8 : isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18),
          
          // Login button
          Obx(() => Container(
            height: isVerySmallScreen ? 44 : isSmallScreen ? 48 : isMediumScreen ? 52 : isLargeScreen ? 56 : 60,
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
              onPressed: Get.find<LoginController>().isLoading.value ? null : Get.find<LoginController>().login,
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
              child: Get.find<LoginController>().isLoading.value
                  ? SizedBox(
                      width: isSmallScreen ? 20 : isMediumScreen ? 24 : isLargeScreen ? 26 : 28,
                      height: isSmallScreen ? 20 : isMediumScreen ? 24 : isLargeScreen ? 26 : 28,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white, size: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22),
                        SizedBox(width: isSmallScreen ? 8 : isMediumScreen ? 10 : isLargeScreen ? 12 : 14),
                        Text(
                          'Entrar',
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
          SizedBox(height: isVerySmallScreen ? 8 : isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18),
          
          // Biometric Login Button
          BiometricLoginButton(
            onSuccess: () {
              Get.offAllNamed('/home');
            },
            onError: () {
              // Tratar erro se necessário
            },
          ),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 12 : isMediumScreen ? 13 : isLargeScreen ? 14 : 15,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          SizedBox(height: isVerySmallScreen ? 8 : isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18),
          
          // Register button
          Container(
            height: isVerySmallScreen ? 40 : isSmallScreen ? 44 : isMediumScreen ? 48 : isLargeScreen ? 52 : 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : isMediumScreen ? 12 : isLargeScreen ? 13 : 14),
              border: Border.all(
                color: const Color(0xFF00324A),
                width: 2,
              ),
            ),
            child: TextButton(
              onPressed: () => Get.toNamed('/registration'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                  vertical: isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : isMediumScreen ? 12 : isLargeScreen ? 13 : 14),
                ),
              ),
              child: Text(
                'Criar nova conta',
                style: TextStyle(
                  color: const Color(0xFF00324A),
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 15 : isMediumScreen ? 15 : isLargeScreen ? 16 : 16,
                ),
              ),
            ),
          ),
          ],
        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    final isXLargeScreen = size.width >= 1024;
    
    return Container(
      decoration: BoxDecoration(
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
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : isMediumScreen ? 17 : isLargeScreen ? 17 : 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
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
            horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 22 : 24, 
            vertical: isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    final isXLargeScreen = size.width >= 1024;
    
    return Container(
      decoration: BoxDecoration(
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
        ),
        decoration: InputDecoration(
          labelText: label,
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
            child: Icon(Icons.lock_outline, color: const Color(0xFF00324A), size: isSmallScreen ? 18 : 20),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[500],
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
            horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 22 : 24, 
            vertical: isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20
          ),
        ),
        validator: validator,
      ),
    );
  }
}