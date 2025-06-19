import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../models/patient.dart';
import '../../services/database_service.dart';
import '../../data/convenios_list.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/controller_mixin.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'dart:convert';

class RegistrationController extends GetxController with SafeControllerMixin {
  // Máscaras de formatação
  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final rgMask = MaskTextInputFormatter(
    mask: '##.###.###-#',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // 1. Conta
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 2. Pessoais
  final cpfController = TextEditingController();
  final rgController = TextEditingController();
  final birthDateController = TextEditingController();
  final gender = RxnString();
  final maritalStatus = RxnString();
  final motherNameController = TextEditingController();
  final nationalityController = TextEditingController();

  // 3. Contato e Endereço
  final phoneController = TextEditingController();
  final secondaryPhoneController = TextEditingController();
  final cepController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final cityController = TextEditingController();
  final state = RxnString();

  // 4. Médicas
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final selectedBloodType = RxnString();
  final RxList<String> selectedAllergies = <String>[].obs;
  final allergiesController = TextEditingController();
  final RxList<String> selectedChronicDiseases = <String>[].obs;
  final chronicDiseasesController = TextEditingController();

  /// Opções: 'sim' ou 'não'
  final medicationOption = 'Não'.obs; // Padronizado para 'Não'/'Sim'
  final medicationsController = TextEditingController();

  /// Opções: 'sim' ou 'não'
  final surgeryOption = 'Não'.obs; // Padronizado para 'Não'/'Sim'
  final surgeriesController = TextEditingController();
  final familyHistoryController = TextEditingController();

  // 5. Convênio
  final insuranceProvider = RxnString();
  final insuranceNumberController = TextEditingController();
  final insuranceValidityController = TextEditingController();
  final selectedInsuranceValidity = Rxn<DateTime>();
  final selectedInsurancePlan = RxnString();

  // 6. Consentimentos e Notificações
  final acceptTerms = false.obs;
  final acceptPrivacyPolicy = false.obs;
  final acceptDataUsage = false.obs;
  final acceptNotifications = false.obs;
  final acceptSensitiveData = false.obs;

  final isLoading = false.obs;
  final selectedDate = Rxn<DateTime>();
  final formKey = GlobalKey<FormState>();

  // Listas para dropdowns
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> genders = [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro não informar'
  ];
  final List<String> maritalStatuses = [
    'Solteiro(a)',
    'Casado(a)',
    'Divorciado(a)',
    'Viúvo(a)',
    'União estável'
  ];
  final List<String> statesList = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO'
  ];

  // Sugestões para alergias e doenças crônicas
  final List<String> commonAllergies = [
    'Pólen',
    'Poeira',
    'Lactose',
    'Glúten',
    'Frutos do mar',
    'Amendoim',
    'Ovos',
    'Leite',
    'Medicamentos',
    'Picada de inseto'
  ];
  final List<String> commonChronicDiseases = [
    'Diabetes',
    'Hipertensão',
    'Asma',
    'Epilepsia',
    'Doença cardíaca',
    'Doença renal',
    'Doença pulmonar',
    'Câncer',
    'Obesidade'
  ];

  // Conditional fields
  final showMedicationsField = false.obs;
  final showSurgeriesField = false.obs;

  final authService = Get.put(AuthService());

  // Validators
  final nameValidator = MultiValidator([
    RequiredValidator(errorText: 'Nome é obrigatório'),
    MinLengthValidator(3, errorText: 'Nome deve ter pelo menos 3 caracteres'),
    PatternValidator(r'^[a-zA-ZÀ-ÿ\s]+$',
        errorText: 'Nome deve conter apenas letras'),
  ]);

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: 'Email é obrigatório'),
    EmailValidator(errorText: 'Email inválido'),
  ]);

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Senha é obrigatória'),
    MinLengthValidator(8, errorText: 'Senha deve ter pelo menos 8 caracteres'),
    PatternValidator(r'[A-Z]',
        errorText: 'Senha deve conter pelo menos uma letra maiúscula'),
    PatternValidator(r'[a-z]',
        errorText: 'Senha deve conter pelo menos uma letra minúscula'),
    PatternValidator(r'[0-9]',
        errorText: 'Senha deve conter pelo menos um número'),
    PatternValidator(r'[!@#$%^&*(),.?":{}|<>]',
        errorText: 'Senha deve conter pelo menos um caractere especial'),
  ]);

  final cpfValidator = MultiValidator([
    RequiredValidator(errorText: 'CPF é obrigatório'),
    PatternValidator(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$', errorText: 'CPF inválido'),
  ]);

  final rgValidator = MultiValidator([
    RequiredValidator(errorText: 'RG é obrigatório'),
    PatternValidator(r'^\d{2}\.\d{3}\.\d{3}-\d{1}$', errorText: 'RG inválido'),
  ]);

  final phoneValidator = MultiValidator([
    RequiredValidator(errorText: 'Telefone é obrigatório'),
    PatternValidator(r'^\(\d{2}\)\s\d{5}-\d{4}$',
        errorText: 'Telefone inválido'),
  ]);

  final cepValidator = MultiValidator([
    RequiredValidator(errorText: 'CEP é obrigatório'),
    PatternValidator(r'^\d{5}-\d{3}$', errorText: 'CEP inválido'),
  ]);

  // Formatadores para altura e peso
  final heightMask = MaskTextInputFormatter(
    mask: '###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final weightMask = MaskTextInputFormatter(
    mask: '###,##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
      return 'Nome deve conter apenas letras';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Senha deve conter pelo menos um número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    // Remove máscara para validação
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    return null;
  }

  String? validateRG(String? value) {
    if (value == null || value.isEmpty) {
      return 'RG é obrigatório';
    }
    // Remove máscara para validação
    final rg = value.replaceAll(RegExp(r'[^\d]'), '');
    if (rg.length < 8) {
      return 'RG deve ter pelo menos 8 dígitos';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    // Remove máscara para validação
    final phone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (phone.length < 10) {
      return 'Telefone deve ter pelo menos 10 dígitos';
    }
    return null;
  }

  String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'CEP é obrigatório';
    }
    // Remove máscara para validação
    final cep = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cep.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  String? validateHeight(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove a máscara para validação
    final height = double.tryParse(value.replaceAll(',', '.'));
    if (height == null) {
      return 'Altura inválida';
    }

    // Converte para metros para validação
    final heightInMeters = height / 100;
    if (heightInMeters < 0.5 || heightInMeters > 2.5) {
      return 'Altura deve estar entre 50cm e 250cm';
    }

    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove a máscara para validação
    final weight = double.tryParse(value.replaceAll(',', '.'));
    if (weight == null) {
      return 'Peso inválido';
    }

    if (weight < 0.5 || weight > 300) {
      return 'Peso deve estar entre 0,5kg e 300kg';
    }

    return null;
  }

  // Método para converter altura de cm para metros
  double? getHeightInMeters() {
    if (heightController.text.isEmpty) return null;
    final height = double.tryParse(heightController.text.replaceAll(',', '.'));
    return height != null ? height / 100 : null;
  }

  // Método para obter peso em kg
  double? getWeightInKg() {
    if (weightController.text.isEmpty) return null;
    return double.tryParse(weightController.text.replaceAll(',', '.'));
  }

  Future<void> selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(
            const Duration(days: 365 * 18)), // Começa com 18 anos atrás
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        locale: const Locale('pt', 'BR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryBlue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        selectedDate.value = picked;
        birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        // Força a validação do campo
        formKey.currentState?.validate();
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao selecionar data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> selectInsuranceValidity(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now()
            .add(const Duration(days: 365)), // Começa com 1 ano à frente
        firstDate: DateTime.now(), // Não permite datas passadas
        lastDate: DateTime.now()
            .add(const Duration(days: 365 * 10)), // Máximo 10 anos
        locale: const Locale('pt', 'BR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryBlue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        selectedInsuranceValidity.value = picked;
        insuranceValidityController.text =
            DateFormat('dd/MM/yyyy').format(picked);
        // Força a validação do formulário após selecionar a data
        formKey.currentState?.validate();
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao selecionar data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Erro',
        'Por favor, preencha todos os campos obrigatórios corretamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Validar termos e autorizações
      if (!acceptTerms.value ||
          !acceptPrivacyPolicy.value ||
          !acceptDataUsage.value) {
        Get.snackbar(
          'Erro',
          'É necessário aceitar todos os termos e autorizações',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Construir endereço completo
      final address = {
        'cep': cepController.text,
        'street': streetController.text,
        'number': numberController.text,
        'complement': complementController.text,
        'neighborhood': neighborhoodController.text,
        'city': cityController.text,
        'state': state.value,
      };

      // Converter altura e peso
      double? height;
      if (heightController.text.isNotEmpty) {
        final heightCm =
            double.tryParse(heightController.text.replaceAll(',', '.'));
        if (heightCm != null) {
          height = heightCm / 100; // Converter para metros
        }
      }

      double? weight;
      if (weightController.text.isNotEmpty) {
        weight = double.tryParse(weightController.text.replaceAll(',', '.'));
      }

      // Criar objeto Patient com todos os campos
      final patient = Patient(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        cpf: cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
        rg: rgController.text.trim(),
        phone: phoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
        secondaryPhone: secondaryPhoneController.text.isNotEmpty
            ? secondaryPhoneController.text.replaceAll(RegExp(r'[^\d]'), '')
            : null,
        birthDate: selectedDate.value!,
        gender: gender.value!,
        maritalStatus: maritalStatus.value!,
        nationality: nationalityController.text.trim(),
        address: jsonEncode(address),
        height: height,
        weight: weight,
        bloodType: selectedBloodType.value,
        allergies:
            selectedAllergies.isEmpty ? null : selectedAllergies.toList(),
        chronicDiseases: selectedChronicDiseases.isEmpty
            ? null
            : selectedChronicDiseases.toList(),
        usesMedications: medicationOption.value == 'Sim',
        medications: medicationOption.value == 'Sim'
            ? medicationsController.text.trim()
            : null,
        hadSurgeries: surgeryOption.value == 'Sim',
        surgeries: surgeryOption.value == 'Sim'
            ? surgeriesController.text.trim()
            : null,
        insuranceProvider: selectedInsurancePlan.value?.isNotEmpty == true
            ? selectedInsurancePlan.value
            : null,
        insuranceNumber: selectedInsurancePlan.value?.isNotEmpty == true &&
                insuranceNumberController.text.isNotEmpty
            ? insuranceNumberController.text.trim()
            : null,
        insuranceValidity: selectedInsurancePlan.value?.isNotEmpty == true
            ? selectedInsuranceValidity.value
            : null,
        acceptedTerms: acceptTerms.value,
        acceptedPrivacyPolicy: acceptPrivacyPolicy.value,
        acceptedDataUsage: acceptDataUsage.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Registrar o paciente usando o serviço de autenticação
      final createdPatient = await authService.register(patient);

      if (createdPatient != null) {
        // Mostrar mensagem de sucesso
        Get.snackbar(
          'Sucesso',
          'Cadastro realizado com sucesso! Bem-vindo(a), ${createdPatient.name}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Aguardar a mensagem ser exibida
        await Future.delayed(const Duration(seconds: 2));

        // Fazer logout para garantir que o usuário precise fazer login
        await authService.logout();

        // Redirecionar para a tela de login
        Get.offAllNamed('/login');
      } else {
        throw 'Erro ao criar conta: Não foi possível criar o usuário';
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Adicionar todos os controllers ao gerenciamento seguro
    addControllers([
      nameController,
      emailController,
      passwordController,
      confirmPasswordController,
      cpfController,
      rgController,
      birthDateController,
      motherNameController,
      nationalityController,
      phoneController,
      secondaryPhoneController,
      cepController,
      streetController,
      numberController,
      complementController,
      neighborhoodController,
      cityController,
      heightController,
      weightController,
      allergiesController,
      chronicDiseasesController,
      medicationsController,
      surgeriesController,
      familyHistoryController,
      insuranceNumberController,
      insuranceValidityController,
    ]);
    // Limpar controllers de forma segura
    clearControllers();
  }
}
