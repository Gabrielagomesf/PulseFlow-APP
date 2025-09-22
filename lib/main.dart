import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/migration_service.dart';
import 'screens/login/paciente_controller.dart';
import 'screens/login/login_controller.dart';
import 'services/enxaqueca_service.dart';
import 'services/diabetes_service.dart';
import 'services/notification_service.dart';
import 'services/biometric_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Usar configurações padrão se .env não estiver disponível
  }
  
  Get.put(DatabaseService());
  //await dbService.connect();
  //final dbService = Get.put(DatabaseService());
//await dbService.connect();

  Get.put(MigrationService());

  final authService = Get.put(AuthService());
  await authService.init();
  
  Get.put(PacienteController());
  Get.put(LoginController());
  Get.put(EnxaquecaService());
  Get.put(DiabetesService());
  
  Get.put(NotificationService());
  Get.put(BiometricService());

  // Verifica se precisa migrar senhas antigas
  try {
    final migrationService = Get.find<MigrationService>();
    final status = await migrationService.checkMigrationStatus();
    
    if (status['needsMigration']) {
      // Executa migração automaticamente
      await migrationService.migrateAllPasswords();
    }
  } catch (e) {
    // Silenciosamente falha se não conseguir verificar migração
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PulseFlow',
      theme: ThemeData(
        primaryColor: AppTheme.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryBlue,
          primary: AppTheme.primaryBlue,
          secondary: AppTheme.secondaryBlue,
        ),
        textTheme: TextTheme(
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
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppTheme.secondaryBlue),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppTheme.secondaryBlue),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppTheme.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppTheme.error, width: 2),
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