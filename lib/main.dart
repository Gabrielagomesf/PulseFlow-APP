import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/migration_service.dart';
import 'services/sms_service.dart';
import 'screens/login/paciente_controller.dart';
import 'services/enxaqueca_service.dart';
import 'services/diabetes_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  Get.put(SMSService());
  Get.put(AuthService());
  Get.put(PacienteController());
  Get.put(EnxaquecaService());
  Get.put(DiabetesService());

  // Verifica se precisa migrar senhas antigas
  try {
    final migrationService = Get.find<MigrationService>();
    final status = await migrationService.checkMigrationStatus();
    
    if (status['needsMigration']) {
      print('⚠️  Migração de senhas necessária detectada');
      print('   - Senhas antigas: ${status['oldPasswordCount']}');
      print('   - Senhas novas: ${status['newPasswordCount']}');
      print('   - Total de pacientes: ${status['totalPatients']}');
      
      // Executa migração automaticamente
      await migrationService.migrateAllPasswords();
      print('✅ Migração de senhas concluída automaticamente');
    } else {
      print('✅ Todas as senhas estão no formato correto');
    }
  } catch (e) {
    print('⚠️  Erro ao verificar migração: $e');
    print('   O sistema continuará funcionando, mas pode haver problemas de login');
  }

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