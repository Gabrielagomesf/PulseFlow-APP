import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../services/auth_service.dart';

class Verify2FAScreen extends StatefulWidget {
  const Verify2FAScreen({super.key});

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> 
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isResending = false;
  String? _error;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
      _error = null;
    });
    
    try {
      final patientId = Get.arguments['patientId'] as String?;
      if (patientId != null) {
        await AuthService.instance.resend2FACode(patientId);
        Get.snackbar(
          'Código reenviado!',
          'Verifique seu e-mail para o novo código.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao reenviar código: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientId = Get.arguments['patientId'] as String?;
    final size = MediaQuery.of(context).size;
    
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
                      child: Form(
                        key: _formKey,
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
                                Icons.verified_user_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Título
                            Text(
                              'Verificação em duas etapas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF1CB5E0),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Subtítulo
                            Text(
                              'Enviamos um código de 6 dígitos para seu e-mail. Insira abaixo para continuar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Campo de código
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 8,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Código de verificação',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_clock_rounded,
                                    color: const Color(0xFF1CB5E0),
                                    size: 24,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1CB5E0),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.length != 6) {
                                    return 'Digite o código de 6 dígitos';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Botão de verificar
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
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate()) return;
                                        setState(() {
                                          _isLoading = true;
                                          _error = null;
                                        });
                                        try {
                                          final patient = await AuthService.instance.verify2FACode(
                                            patientId!,
                                            _codeController.text.trim(),
                                          );
                                          // O redirecionamento é feito automaticamente pelo AuthService
                                          // Não precisa fazer Get.offAllNamed('/home') aqui
                                        } catch (e) {
                                          setState(() {
                                            _error = e.toString();
                                          });
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                icon: _isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.verified_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                label: Text(
                                  _isLoading ? 'Verificando...' : 'Verificar código',
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
                            
                            const SizedBox(height: 24),
                            
                            // Botão de reenviar código
                            TextButton.icon(
                              onPressed: _isResending ? null : _resendCode,
                              icon: _isResending
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: const Color(0xFF1CB5E0),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh_rounded,
                                      color: const Color(0xFF1CB5E0),
                                      size: 20,
                                    ),
                              label: Text(
                                _isResending ? 'Reenviando...' : 'Reenviar código',
                                style: const TextStyle(
                                  color: Color(0xFF1CB5E0),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
      ),
    );
  }
} 