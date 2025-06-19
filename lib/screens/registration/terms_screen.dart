import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Termos de Uso e Privacidade',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppTheme.lightBlue,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Termos de Uso',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              SizedBox(height: 12),
              Text(
                'Aqui você pode colocar o texto completo dos Termos de Uso do seu aplicativo. Explique as regras, responsabilidades, direitos e deveres do usuário, etc.',
                style: TextStyle(fontSize: 15, color: AppTheme.textPrimary),
              ),
              SizedBox(height: 24),
              Text(
                'Política de Privacidade',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              SizedBox(height: 12),
              Text(
                'Aqui você pode colocar a Política de Privacidade, explicando como os dados são coletados, usados, armazenados e protegidos, além dos direitos do usuário conforme a LGPD.',
                style: TextStyle(fontSize: 15, color: AppTheme.textPrimary),
              ),
              SizedBox(height: 24),
              Text(
                'Se desejar, adicione mais seções, tópicos e detalhes conforme necessário para o seu app.',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 