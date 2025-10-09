import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  
  const BiometricLoginButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<BiometricService>(
      builder: (biometricService) {
        if (!biometricService.isAvailable) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                'Entre com sua biometria',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _handleBiometricLogin,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toque no ícone',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final biometricService = Get.find<BiometricService>();
      
      // Autenticar com a biometria do celular
      final authenticated = await biometricService.authenticateWithBiometrics(
        localizedReason: 'Use sua biometria para acessar o PulseFlow',
      );
      
      if (authenticated) {
        // Se autenticou com a biometria do celular, fazer login automático
        // Aqui você pode implementar um usuário padrão ou buscar o usuário logado anteriormente
        Get.snackbar(
          'Sucesso',
          'Login realizado com biometria!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        onSuccess?.call();
      } else {
        Get.snackbar(
          'Cancelado',
          'Autenticação biométrica cancelada',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha na autenticação biométrica',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      onError?.call();
    }
  }
  

}

class BiometricSettingsButton extends StatelessWidget {
  const BiometricSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<BiometricService>(
      builder: (biometricService) {
        if (!biometricService.isAvailable) {
          return const SizedBox.shrink();
        }

        return ListTile(
          leading: Icon(
            Icons.fingerprint,
            color: AppTheme.primaryBlue,
          ),
          title: Text(
            'Login com ${biometricService.getBiometricTypeName()}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            biometricService.isEnabled 
              ? 'Habilitado - Toque para desabilitar'
              : 'Desabilitado - Toque para habilitar',
            style: TextStyle(
              color: biometricService.isEnabled ? Colors.green : Colors.grey,
            ),
          ),
          trailing: Switch(
            value: biometricService.isEnabled,
            onChanged: (value) {
              if (value) {
                _showEnableDialog();
              } else {
                _showDisableDialog();
              }
            },
            activeColor: AppTheme.primaryBlue,
          ),
          onTap: () {
            if (biometricService.isEnabled) {
              _showDisableDialog();
            } else {
              _showEnableDialog();
            }
          },
        );
      },
    );
  }

  void _showEnableDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Habilitar Login Biométrico'),
        content: const Text(
          'Para habilitar o login biométrico, você precisa estar logado e ter feito login recentemente com email e senha.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Info',
                'Faça login com email e senha para habilitar a biometria',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _showDisableDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Desabilitar Login Biométrico'),
        content: const Text(
          'Tem certeza que deseja desabilitar o login biométrico? Você precisará fazer login com email e senha.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final authService = Get.find<AuthService>();
              await authService.disableBiometricLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desabilitar'),
          ),
        ],
      ),
    );
  }
}
