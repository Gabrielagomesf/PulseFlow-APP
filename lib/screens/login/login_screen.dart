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
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00324A),
            ),
            child: SafeArea(
              child: _buildMobileLayout(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMobileLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        final isLandscape = width > height;
        final isSmallHeight = height < 700;
        
        final logoSize = isLandscape 
          ? (width * 0.18).clamp(100.0, 160.0)
          : (width * 0.45).clamp(180.0, 280.0);
          
        final verticalPadding = isLandscape 
          ? (height * 0.02).clamp(8.0, 16.0)
          : (height * 0.025).clamp(12.0, 24.0);
          
        final horizontalPadding = (width * 0.06).clamp(20.0, 32.0);
        
        return Column(
          children: [
            Expanded(
              flex: isLandscape ? 2 : (isSmallHeight ? 2 : 2),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Image.asset(
                    'assets/images/pulseflow2.png',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            Expanded(
              flex: isLandscape ? 5 : (isSmallHeight ? 5 : 5),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
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
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: verticalPadding * (isLandscape ? 0.5 : 0.8),
                            horizontal: horizontalPadding,
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
                              Container(
                                width: 50,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00324A).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(height: verticalPadding * 0.6),
                              Text(
                                'Bem-vindo de volta',
                                style: TextStyle(
                                  fontSize: (width * 0.06).clamp(20.0, 28.0),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00324A),
                                ),
                              ),
                              SizedBox(height: verticalPadding * 0.4),
                              Text(
                                'Entre com suas credenciais para acessar sua conta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (width * 0.035).clamp(13.0, 16.0),
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildLoginForm(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isLandscape = size.width > size.height;
        final isSmallHeight = height < 600;
        
        final horizontalPadding = (width * 0.06).clamp(16.0, 28.0);
        final spacing = isLandscape || isSmallHeight 
          ? (height * 0.012).clamp(4.0, 8.0)
          : (height * 0.018).clamp(8.0, 14.0);
        
        return Form(
          key: Get.find<LoginController>().formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: spacing * 1.2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      SizedBox(height: spacing),
                      
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
                    ],
                  ),
                  
                  SizedBox(height: spacing),
                  
                  Row(
                    children: [
                      Obx(() => Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          value: Get.find<LoginController>().rememberMe.value,
                          onChanged: (v) async {
                            Get.find<LoginController>().rememberMe.value = v ?? false;
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
                          fontSize: (width * 0.035).clamp(12.0, 15.0),
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
                            color: const Color(0xFF00324A),
                            fontSize: (width * 0.035).clamp(12.0, 15.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: spacing * 1.5),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(() => Container(
                        height: (height * 0.075).clamp(46.0, 56.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00324A),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00324A).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: Get.find<LoginController>().isLoading.value ? null : Get.find<LoginController>().login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Get.find<LoginController>().isLoading.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login, color: Colors.white, size: (width * 0.048).clamp(18.0, 20.0)),
                                    SizedBox(width: (width * 0.02).clamp(8.0, 10.0)),
                                    Text(
                                      'Entrar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: (width * 0.04).clamp(15.0, 17.0),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )),
                      SizedBox(height: spacing * 0.8),
                      
                      BiometricLoginButton(
                        onSuccess: () {
                          Get.offAllNamed('/home');
                        },
                        onError: () {
                        },
                      ),
                      
                      SizedBox(height: spacing * 0.6),
                      
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (width * 0.03).clamp(10.0, 14.0)),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: (width * 0.03).clamp(11.0, 13.0),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                        ],
                      ),
                      
                      SizedBox(height: spacing * 0.6),
                      
                      Container(
                        height: (height * 0.065).clamp(44.0, 52.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF00324A),
                            width: 2,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Get.toNamed('/registration'),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Criar nova conta',
                            style: TextStyle(
                              color: const Color(0xFF00324A),
                              fontWeight: FontWeight.bold,
                              fontSize: (width * 0.038).clamp(14.0, 16.0),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
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
              fontSize: (width * 0.042).clamp(15.0, 18.0),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: (width * 0.038).clamp(14.0, 16.0),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00324A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF00324A), size: (width * 0.05).clamp(18.0, 20.0)),
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
                horizontal: (width * 0.05).clamp(16.0, 24.0), 
                vertical: (width * 0.04).clamp(14.0, 20.0)
              ),
            ),
            validator: validator,
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
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
              fontSize: (width * 0.042).clamp(15.0, 18.0),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: (width * 0.038).clamp(14.0, 16.0),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00324A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.lock_outline, color: const Color(0xFF00324A), size: (width * 0.05).clamp(18.0, 20.0)),
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[500],
                    size: (width * 0.05).clamp(18.0, 20.0),
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
                horizontal: (width * 0.05).clamp(16.0, 24.0), 
                vertical: (width * 0.04).clamp(14.0, 20.0)
              ),
            ),
            validator: validator,
          ),
        );
      },
    );
  }
}