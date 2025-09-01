import 'package:get/get.dart';
import '../screens/login/login_screen.dart';
import '../screens/registration/registration_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/verify_2fa_screen.dart';

import '../screens/success/success_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/reset_password/reset_password_screen.dart';
import '../screens/medical_records/medical_records_screen.dart';
import '../screens/menu/menu_screen.dart';
import '../screens/enxaqueca/enxaqueca_screen.dart';
import '../screens/diabetes/diabetes_screen.dart';
import '../screens/login/paciente_controller.dart'; // Ajuste o caminho
import '../screens/medical_records/medical_record_details_screen.dart';
import '../screens/evento_clinico/evento_clinico_form_screen.dart';
import '../screens/evento_clinico/evento_clinico_history_screen.dart';


import  'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: Routes.REGISTRATION,
      page: () => ProfessionalRegistrationScreen(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: Routes.SUCCESS,
      page: () => const SuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.MEDICAL_RECORDS,
      page: () => const MedicalRecordsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.VERIFY_2FA,
      page: () => const Verify2FAScreen(
        patientId: '',
        method: 'email',
      ),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.MENU,
      page: () => const MenuScreen(),
    ),
    GetPage(
      name: Routes.ENXAQUECA,
      page: () {
        final pacienteController = Get.find<PacienteController>();
        return EnxaquecaScreen(pacienteId: pacienteController.pacienteId.value);
      },
    ),
    GetPage(
      name: Routes.DIABETES,
      page: () {
        final pacienteController = Get.find<PacienteController>();
        return DiabetesScreen(pacienteId: pacienteController.pacienteId.value);
      },
    ),
    GetPage(
      name: Routes.MEDICAL_RECORD_DETAILS,
      page: () => const MedicalRecordDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.EVENTO_CLINICO_FORM,
      page: () => const EventoClinicoFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.EVENTO_CLINICO_HISTORY,
      page: () => const EventoClinicoHistoryScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
} 