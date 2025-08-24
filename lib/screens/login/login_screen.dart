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
        final isSmallScreen = size.width < 600;
        final isMediumScreen = size.width >= 600 && size.width < 900;
        final isLargeScreen = size.width >= 900;
        
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
                  // Background animated circles - Responsive positioning
                  Positioned(
                    top: isSmallScreen ? -30 : -50,
                    right: isSmallScreen ? -30 : -50,
                    child: Container(
                      width: isSmallScreen ? 100 : 150,
                      height: isSmallScreen ? 100 : 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: isSmallScreen ? -20 : -30,
                    left: isSmallScreen ? -20 : -30,
                    child: Container(
                      width: isSmallScreen ? 70 : 100,
                      height: isSmallScreen ? 70 : 100,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : isMediumScreen ? 24 : 32,
                      ),
                      child: isLargeScreen 
                        ? _buildLargeScreenLayout()
                        : Column(
                            children: [
                              // Header section
                              Expanded(
                                flex: isSmallScreen ? 1 : 2,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Logo container - Responsive size
                                      Container(
                                        width: isSmallScreen ? 80 : isMediumScreen ? 100 : 120,
                                        height: isSmallScreen ? 80 : isMediumScreen ? 100 : 120,
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
                                              blurRadius: isSmallScreen ? 15 : 20,
                                              offset: Offset(0, isSmallScreen ? 8 : 10),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          color: const Color(0xFF1CB5E0),
                                          size: isSmallScreen ? 40 : isMediumScreen ? 50 : 60,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 16 : 24),
                                      
                                      // App name with animation - Responsive font size
                                      AnimatedTextKit(
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            'PulseFlow Saúde',
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: isSmallScreen ? 20 : isMediumScreen ? 24 : 28,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                            speed: const Duration(milliseconds: 100),
                                          ),
                                        ],
                                        totalRepeatCount: 1,
                                        pause: const Duration(milliseconds: 500),
                                      ),
                                      
                                      SizedBox(height: isSmallScreen ? 6 : 8),
                                      
                                      // Subtitle - Responsive font size
                                      DefaultTextStyle(
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 14 : 16,
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
                                flex: isSmallScreen ? 2 : 3,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(isSmallScreen ? 16 : isMediumScreen ? 20 : 24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: isSmallScreen ? 15 : 20,
                                            offset: Offset(0, isSmallScreen ? 8 : 10),
                                          ),
                                        ],
                                      ),
                                  child: Form(
                                    key: controller.formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Welcome text
                                        Text(
                                          'Bem-vindo de volta!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 20 : isMediumScreen ? 22 : 24,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF222B45),
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 6 : 8),
                                        Text(
                                          'Acesse sua área do paciente',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 12 : 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 24 : 32),
                                        
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
                                        SizedBox(height: isSmallScreen ? 16 : 20),
                                        
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
                                        SizedBox(height: isSmallScreen ? 12 : 16),
                                        
                                        // Remember me and forgot password
                                        Row(
                                          children: [
                                            Obx(() => Transform.scale(
                                              scale: isSmallScreen ? 0.8 : 0.9,
                                              child: Checkbox(
                                                value: controller.rememberMe.value,
                                                onChanged: (v) async {
                                                  controller.rememberMe.value = v ?? false;
                                                  // Salvar/remover credenciais imediatamente
                                                  if (v == true) {
                                                    await controller.saveCredentials();
                                                    Get.snackbar(
                                                      'Sucesso',
                                                      'Credenciais salvas para próximo login',
                                                      backgroundColor: Colors.green,
                                                      colorText: Colors.white,
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      duration: const Duration(seconds: 2),
                                                    );
                                                  } else {
                                                    await controller.clearSavedCredentials();
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
                                                activeColor: const Color(0xFF1CB5E0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            )),
                                            Text(
                                              'Lembrar-me',
                                              style: TextStyle(
                                                fontSize: isSmallScreen ? 12 : 14,
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
                                              child: Text(
                                                'Esqueceu a senha?',
                                                style: TextStyle(
                                                  color: const Color(0xFF1CB5E0),
                                                  fontSize: isSmallScreen ? 12 : 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: isSmallScreen ? 24 : 32),
                                        
                                        // Login button
                                        Obx(() => Container(
                                          height: isSmallScreen ? 48 : 56,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF1CB5E0).withOpacity(0.3),
                                                blurRadius: isSmallScreen ? 10 : 12,
                                                offset: Offset(0, isSmallScreen ? 5 : 6),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: controller.isLoading.value ? null : controller.login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                                              ),
                                            ),
                                            child: controller.isLoading.value
                                                ? SizedBox(
                                                    width: isSmallScreen ? 20 : 24,
                                                    height: isSmallScreen ? 20 : 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.login, color: Colors.white, size: isSmallScreen ? 18 : 20),
                                                      SizedBox(width: isSmallScreen ? 8 : 12),
                                                      Text(
                                                        'Entrar',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: isSmallScreen ? 14 : 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        )),
                                        SizedBox(height: isSmallScreen ? 20 : 24),
                                        
                                        // Divider
                                        Row(
                                          children: [
                                            Expanded(child: Divider(color: Colors.grey[300])),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                                              child: Text(
                                                'ou',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: isSmallScreen ? 12 : 14,
                                                ),
                                              ),
                                            ),
                                            Expanded(child: Divider(color: Colors.grey[300])),
                                          ],
                                        ),
                                        SizedBox(height: isSmallScreen ? 20 : 24),
                                        
                                        // Register button
                                        Container(
                                          height: isSmallScreen ? 44 : 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                            border: Border.all(
                                              color: const Color(0xFF1CB5E0),
                                              width: 2,
                                            ),
                                          ),
                                          child: TextButton(
                                            onPressed: () => Get.toNamed('/registration'),
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                              ),
                                            ),
                                            child: Text(
                                              'Criar nova conta',
                                              style: TextStyle(
                                                color: const Color(0xFF1CB5E0),
                                                fontWeight: FontWeight.bold,
                                                fontSize: isSmallScreen ? 14 : 16,
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

  // Layout para telas grandes (desktop/tablet)
  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        // Lado esquerdo - Logo e título
        Expanded(
          flex: 1,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo container
                Container(
                  width: 140,
                  height: 140,
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
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFF1CB5E0),
                    size: 70,
                  ),
                ),
                const SizedBox(height: 32),
                
                // App name with animation
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'PulseFlow Saúde',
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 500),
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
                      color: Colors.black.withOpacity(0.15),
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
    final isSmallScreen = size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          // Welcome text
          Text(
            'Bem-vindo de volta!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF222B45),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 10),
          Text(
            'Acesse sua área do paciente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isSmallScreen ? 24 : 36),
          
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
          SizedBox(height: isSmallScreen ? 16 : 24),
          
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
          SizedBox(height: isSmallScreen ? 12 : 20),
          
          // Remember me and forgot password
          Row(
            children: [
              Obx(() => Transform.scale(
                scale: isSmallScreen ? 0.8 : 0.9,
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
                  activeColor: const Color(0xFF1CB5E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )),
              Text(
                'Lembrar-me',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 15,
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
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    color: const Color(0xFF1CB5E0),
                    fontSize: isSmallScreen ? 12 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 24 : 36),
          
          // Login button
          Obx(() => Container(
            height: isSmallScreen ? 48 : 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1CB5E0).withOpacity(0.3),
                  blurRadius: isSmallScreen ? 10 : 15,
                  offset: Offset(0, isSmallScreen ? 5 : 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: Get.find<LoginController>().isLoading.value ? null : Get.find<LoginController>().login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 18),
                ),
              ),
              child: Get.find<LoginController>().isLoading.value
                  ? SizedBox(
                      width: isSmallScreen ? 20 : 28,
                      height: isSmallScreen ? 20 : 28,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white, size: isSmallScreen ? 18 : 22),
                        SizedBox(width: isSmallScreen ? 8 : 14),
                        Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 18,
                          ),
                        ),
                      ],
                    ),
            ),
          )),
          SizedBox(height: isSmallScreen ? 20 : 28),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 18),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 12 : 15,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          SizedBox(height: isSmallScreen ? 20 : 28),
          
          // Register button
          Container(
            height: isSmallScreen ? 44 : 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14),
              border: Border.all(
                color: const Color(0xFF1CB5E0),
                width: 2,
              ),
            ),
            child: TextButton(
              onPressed: () => Get.toNamed('/registration'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14),
                ),
              ),
              child: Text(
                'Criar nova conta',
                style: TextStyle(
                  color: const Color(0xFF1CB5E0),
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
        ],
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
    final isSmallScreen = size.width < 600;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF1CB5E0), size: isSmallScreen ? 18 : 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 14 : 16, 
          vertical: isSmallScreen ? 14 : 16
        ),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        prefixIcon: Icon(Icons.lock_outline, color: const Color(0xFF1CB5E0), size: isSmallScreen ? 18 : 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[500],
            size: isSmallScreen ? 18 : 20,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 14 : 16, 
          vertical: isSmallScreen ? 14 : 16
        ),
      ),
      validator: validator,
    );
  }
} 