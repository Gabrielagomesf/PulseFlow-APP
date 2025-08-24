import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import 'verify_2fa_screen.dart';

class Choose2FAMethodScreen extends StatefulWidget {
  const Choose2FAMethodScreen({super.key});

  @override
  State<Choose2FAMethodScreen> createState() => _Choose2FAMethodScreenState();
}

class _Choose2FAMethodScreenState extends State<Choose2FAMethodScreen> 
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _patientId;
  String? _selectedMethod;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
    
    // Extrair patientId dos argumentos
    _extractPatientId();
  }

  void _extractPatientId() {
    final arguments = Get.arguments;
    
    if (arguments != null && arguments is Map) {
      _patientId = arguments['patientId'] as String?;
    }
    
    if (_patientId == null || _patientId!.isEmpty) {
      final parameters = Get.parameters;
      _patientId = parameters['patientId'];
    }
  }

  Future<void> _sendCode() async {
    if (_selectedMethod == null) {
      Get.snackbar(
        'Selecione um método',
        'Escolha se quer receber o código por SMS ou email',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_patientId == null || _patientId!.isEmpty) {
      Get.snackbar(
        'Erro',
        'Dados de sessão inválidos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    try {
      await AuthService.instance.resend2FACode(_patientId!, method: _selectedMethod!);
      
      // Navegar para a tela de verificação com o método selecionado
      Get.off(() => Verify2FAScreen(
        patientId: _patientId!,
        method: _selectedMethod!,
      ));
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao enviar código: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Se não tiver patientId válido, redireciona para login
    if (_patientId == null || _patientId!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
        Get.snackbar(
          'Erro',
          'Dados de sessão inválidos. Faça login novamente.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1CB5E0),
              Color(0xFF000046),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: size.width > 400 ? 400 : size.width * 0.9,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ícone animado
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1CB5E0).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.smartphone_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Título
                          const Text(
                            'Como receber o código?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1CB5E0),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Subtítulo
                          const Text(
                            'Escolha onde você quer receber o código de verificação:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Opção SMS
                          _buildMethodOption(
                            icon: Icons.sms_rounded,
                            title: 'SMS (Gratuito)',
                            subtitle: 'Receba no seu telefone via SMS',
                            method: 'sms',
                            color: Colors.green,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Opção Email
                          _buildMethodOption(
                            icon: Icons.email_rounded,
                            title: 'Email',
                            subtitle: 'Receba no seu email',
                            method: 'email',
                            color: Colors.blue,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botão de continuar
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1CB5E0).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isLoading || _selectedMethod == null
                                  ? null
                                  : _sendCode,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                              label: Text(
                                _isLoading ? 'Enviando...' : 'Continuar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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
          ),
        ),
      ),
    );
  }

  Widget _buildMethodOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String method,
    required Color color,
  }) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? color.withOpacity(0.8) : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
