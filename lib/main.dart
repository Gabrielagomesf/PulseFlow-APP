import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔧 Carregando arquivo .env...');
    await dotenv.load(fileName: ".env");
    print('✅ Arquivo .env carregado com sucesso');
    
    // Verificar se as configurações foram carregadas
    final mongodbUri = dotenv.env['MONGODB_URI'];
    final emailUser = dotenv.env['EMAIL_USER'];
    final emailPass = dotenv.env['EMAIL_PASS'];
    
    print('📋 Configurações carregadas:');
    print('   MONGODB_URI: ${mongodbUri != null ? 'Configurado' : 'NÃO CONFIGURADO'}');
    print('   EMAIL_USER: $emailUser');
    print('   EMAIL_PASS: ${emailPass != null ? 'Configurado' : 'NÃO CONFIGURADO'}');
    
  } catch (e) {
    print('❌ Erro ao carregar arquivo .env: $e');
    print('⚠️ Usando configurações padrão');
  }
  
  Get.put(DatabaseService());
  Get.put(AuthService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Paciente App',
      theme: ThemeData(
        primaryColor: AppTheme.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryBlue,
          primary: AppTheme.primaryBlue,
          secondary: AppTheme.secondaryBlue,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTheme.titleLarge,
          displayMedium: AppTheme.titleMedium,
          displaySmall: AppTheme.titleSmall,
          bodyLarge: AppTheme.bodyLarge,
          bodyMedium: AppTheme.bodyMedium,
          bodySmall: AppTheme.bodySmall,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButtonStyle,
        ),
        textButtonTheme: TextButtonThemeData(
          style: AppTheme.secondaryButtonStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.secondaryBlue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.secondaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
    );
  }
} 