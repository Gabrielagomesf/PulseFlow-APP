import 'package:get/get.dart';
import '../screens/login/login_screen.dart';
import '../screens/registration/registration_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/verify_2fa_screen.dart';
import '../screens/success/success_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/reset_password/reset_password_screen.dart';
import '../screens/medical_records/medical_records_screen.dart';

part 'app_routes.dart';

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
      name: '/verify-2fa',
      page: () => const Verify2FAScreen(),
      transition: Transition.fadeIn,
    ),
  ];
} 