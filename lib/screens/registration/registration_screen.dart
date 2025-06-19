import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'registration_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/background_wave.dart';
import '../../widgets/multiselect_dropdown.dart';
import 'terms_screen.dart';
import '../../data/convenios_list.dart';

class ProfessionalRegistrationScreen extends StatelessWidget {
  ProfessionalRegistrationScreen({super.key});

  final controller = Get.put(RegistrationController());
  final RxBool isCepLoading = false.obs;
  final RxString cepError = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe3f2fd),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth > 400 ? 400 : constraints.maxWidth;
            return Center(
              child: Container(
                width: width,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Header azul com topo arredondado
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                      ),
                    ),
                    // Círculo branco com ícone médico
                    Positioned(
                      top: 140,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.local_hospital_rounded,
                            color: Color(0xFF2196F3),
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    // Card branco centralizado
                    Positioned(
                      top: 180,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 40),
                                // Título e subtítulo
                                Text(
                                  'Cadastro de Paciente',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF222B45),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Complete seus dados para acessar nossos serviços médicos',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // Seção: Conta
                                _SectionTitle(icon: Icons.person_outline, title: 'Informações de Conta'),
                                _buildTextField(context, controller: controller.nameController, label: 'Nome completo', icon: Icons.person_outline, validator: controller.validateName),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: controller.validateEmail),
                                const SizedBox(height: 16),
                                _buildPasswordField(context, controller: controller.passwordController, label: 'Senha', validator: controller.validatePassword),
                                const SizedBox(height: 16),
                                _buildPasswordField(context, controller: controller.confirmPasswordController, label: 'Confirmar Senha', validator: controller.validateConfirmPassword),
                                const SizedBox(height: 28),

                                // Seção: Pessoais
                                _SectionTitle(icon: Icons.assignment_ind_outlined, title: 'Informações Pessoais'),
                                _buildTextField(context, controller: controller.cpfController, label: 'CPF', icon: Icons.badge_outlined, keyboardType: TextInputType.number, inputFormatters: [controller.cpfMask], validator: controller.validateCPF),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.rgController, label: 'RG', icon: Icons.credit_card_outlined, keyboardType: TextInputType.text, inputFormatters: [controller.rgMask], validator: controller.validateRG),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.phoneController, label: 'Telefone', icon: Icons.phone_iphone_outlined, keyboardType: TextInputType.phone, inputFormatters: [controller.phoneMask], validator: controller.validatePhone),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.nationalityController, label: 'Nacionalidade', icon: Icons.flag_outlined, validator: (value) => controller.validateRequired(value, 'Nacionalidade')),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.birthDateController, label: 'Data de Nascimento', icon: Icons.cake_outlined, readOnly: true, onTap: () => controller.selectDate(context), validator: (value) => controller.validateRequired(value, 'Data de Nascimento')),
                                const SizedBox(height: 16),
                                Obx(() => _buildDropdownField(context, value: controller.gender.value, label: 'Sexo / Gênero', icon: Icons.transgender, items: controller.genders, onChanged: (String? newValue) { controller.gender.value = newValue; }, validator: (v) => controller.validateRequired(v, 'Sexo / Gênero'))),
                                const SizedBox(height: 16),
                                Obx(() => _buildDropdownField(context, value: controller.maritalStatus.value, label: 'Estado Civil', icon: Icons.family_restroom_outlined, items: controller.maritalStatuses, onChanged: (String? newValue) { controller.maritalStatus.value = newValue; }, validator: (v) => controller.validateRequired(v, 'Estado Civil'))),
                                const SizedBox(height: 28),

                                // Seção: Endereço
                                _SectionTitle(icon: Icons.home_outlined, title: 'Endereço'),
                                _buildTextField(
                                  context, 
                                  controller: controller.cepController, 
                                  label: 'CEP', 
                                  icon: Icons.location_on_outlined, 
                                  keyboardType: TextInputType.number, 
                                  inputFormatters: [controller.cepMask], 
                                  validator: controller.validateCEP, 
                                  onChanged: (value) { 
                                    if (value.length == 9) { 
                                      _buscarEnderecoPorCep(value); 
                                    } else { 
                                      cepError.value = ''; 
                                    } 
                                  }, 
                                  suffixIcon: Obx(() => isCepLoading.value 
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0), 
                                        child: CircularProgressIndicator(strokeWidth: 2)
                                      ) 
                                    : const SizedBox.shrink()
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.streetController, label: 'Rua', icon: Icons.alt_route, validator: (value) => controller.validateRequired(value, 'Rua')),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.numberController, label: 'Número', icon: Icons.numbers_outlined, keyboardType: TextInputType.number, validator: (value) => controller.validateRequired(value, 'Número')),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.complementController, label: 'Complemento', icon: Icons.add_location_alt_outlined),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.neighborhoodController, label: 'Bairro', icon: Icons.location_city_outlined, validator: (value) => controller.validateRequired(value, 'Bairro')),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.cityController, label: 'Cidade', icon: Icons.apartment_outlined, validator: (value) => controller.validateRequired(value, 'Cidade')),
                                const SizedBox(height: 16),
                                Obx(() => _buildDropdownField(context, value: controller.state.value, label: 'UF', icon: Icons.map_outlined, items: controller.statesList, onChanged: (String? newValue) { controller.state.value = newValue; }, validator: (v) => controller.validateRequired(v, 'UF'))),
                                const SizedBox(height: 28),

                                // Seção: Médicas
                                _SectionTitle(icon: Icons.medical_services_outlined, title: 'Informações Médicas'),
                                _buildTextField(context, controller: controller.heightController, label: 'Altura', icon: Icons.height, keyboardType: TextInputType.number, inputFormatters: [controller.heightMask], suffixText: 'cm', validator: controller.validateHeight),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.weightController, label: 'Peso', icon: Icons.monitor_weight_outlined, keyboardType: TextInputType.number, inputFormatters: [controller.weightMask], suffixText: 'kg', validator: controller.validateWeight),
                                const SizedBox(height: 16),
                                Obx(() => _buildDropdownField(context, value: controller.medicationOption.value, label: 'Faz uso de medicamentos contínuos?', icon: Icons.medication_outlined, items: const ['Sim', 'Não'], onChanged: (String? newValue) { if (newValue != null) { controller.medicationOption.value = newValue; controller.showMedicationsField.value = newValue == 'Sim'; } }, validator: (v) => controller.validateRequired(v, 'Opção de medicamentos'))),
                                const SizedBox(height: 16),
                                Obx(() => controller.showMedicationsField.value ? _buildTextField(context, controller: controller.medicationsController, label: 'Quais medicamentos?', icon: Icons.medication_liquid_outlined, validator: (value) => controller.validateRequired(value, 'Medicamentos')) : const SizedBox.shrink()),
                                Obx(() => controller.showMedicationsField.value ? const SizedBox(height: 16) : const SizedBox.shrink()),
                                Obx(() => _buildDropdownField(context, value: controller.surgeryOption.value, label: 'Já fez cirurgia?', icon: Icons.medical_information_outlined, items: const ['Sim', 'Não'], onChanged: (String? newValue) { if (newValue != null) { controller.surgeryOption.value = newValue; controller.showSurgeriesField.value = newValue == 'Sim'; } }, validator: (v) => controller.validateRequired(v, 'Opção de cirurgias'))),
                                const SizedBox(height: 16),
                                Obx(() => controller.showSurgeriesField.value ? _buildTextField(context, controller: controller.surgeriesController, label: 'Quais cirurgias?', icon: Icons.medical_services_outlined, validator: (value) => controller.validateRequired(value, 'Cirurgias')) : const SizedBox.shrink()),
                                const SizedBox(height: 16),
                                MultiSelectDropdown(label: 'Alergias', options: controller.commonAllergies, selectedValues: controller.selectedAllergies, onChanged: (values) => controller.selectedAllergies.assignAll(values)),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.allergiesController, label: 'Outras alergias', icon: Icons.add_circle_outline),
                                const SizedBox(height: 16),
                                MultiSelectDropdown(label: 'Doenças Crônicas', options: controller.commonChronicDiseases, selectedValues: controller.selectedChronicDiseases, onChanged: (values) => controller.selectedChronicDiseases.assignAll(values)),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.chronicDiseasesController, label: 'Outras doenças crônicas', icon: Icons.add_circle_outline),
                                const SizedBox(height: 28),

                                // Seção: Convênio
                                _SectionTitle(icon: Icons.local_hospital_outlined, title: 'Convênio Médico'),
                                Obx(() => _buildDropdownField(context, value: controller.selectedInsurancePlan.value, label: 'Convênio', icon: Icons.local_hospital_outlined, items: conveniosList, onChanged: (String? newValue) { controller.selectedInsurancePlan.value = newValue; })),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.insuranceNumberController, label: 'Número do convênio', icon: Icons.confirmation_number_outlined),
                                const SizedBox(height: 16),
                                _buildTextField(context, controller: controller.insuranceValidityController, label: 'Validade do convênio', icon: Icons.date_range_outlined, readOnly: true, onTap: () => controller.selectInsuranceValidity(context)),
                                const SizedBox(height: 28),

                                // Seção: Termos
                                _SectionTitle(icon: Icons.gavel_outlined, title: 'Termos e Condições'),
                                _buildCheckboxTile(value: controller.acceptTerms, title: 'Aceito os ', linkText: 'Termos de Uso', onLinkTap: () => Get.to(() => const TermsScreen())),
                                _buildCheckboxTile(value: controller.acceptPrivacyPolicy, title: 'Aceito a ', linkText: 'Política de Privacidade', onLinkTap: () => Get.to(() => const TermsScreen())),
                                _buildCheckboxTile(value: controller.acceptDataUsage, title: 'Autorizo o uso dos meus dados para fins de atendimento e cadastro'),
                                _buildCheckboxTile(value: controller.acceptSensitiveData, title: 'Autorizo o uso dos meus dados sensíveis para fins médicos'),
                                const SizedBox(height: 32),

                                // Botão de Cadastro Melhorado
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Obx(() => ElevatedButton(
                                    onPressed: controller.isLoading.value ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
                                      minimumSize: const Size(double.infinity, 56),
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.person_add, size: 24),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'CRIAR MINHA CONTA',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  )),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? helperText,
    String? suffixText,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    bool readOnly = false,
    Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey[600]) : null,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        helperText: helperText,
        helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    final obscure = true.obs;
    
    return Obx(() => TextFormField(
      controller: controller,
      obscureText: obscure.value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.lock_outline, size: 20, color: Colors.grey[600]),
        suffixIcon: IconButton(
          icon: Icon(
            obscure.value ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[500],
          ),
          onPressed: () => obscure.value = !obscure.value,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
    ));
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        overflow: TextOverflow.ellipsis,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
      menuMaxHeight: 300,
    );
  }

  Widget _buildCheckboxTile({
    required RxBool value,
    required String title,
    String? linkText,
    Function()? onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: value.value,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                value.value = newValue;
              }
            },
            activeColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            visualDensity: VisualDensity.compact,
          ),
        )),
        const SizedBox(width: 8),
        Expanded(
          child: linkText != null
              ? RichText(
                  text: TextSpan(
                    text: title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: linkText,
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                      ),
                    ],
                  ),
                )
              : Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    final cleanedCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedCep.length != 8) return;

    isCepLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cleanedCep/json/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == true) {
          cepError.value = 'CEP não encontrado';
        } else {
          controller.streetController.text = data['logradouro'] ?? '';
          controller.neighborhoodController.text = data['bairro'] ?? '';
          controller.cityController.text = data['localidade'] ?? '';
          controller.state.value = data['uf'] ?? '';
          cepError.value = '';
        }
      }
    } catch (e) {
      cepError.value = 'Erro ao buscar CEP';
    } finally {
      isCepLoading.value = false;
    }
  }

  void _submitForm() async {
    // Verifica se o formulário é válido
    if (controller.formKey.currentState?.validate() ?? false) {
      // Verifica se todos os termos foram aceitos
      if (!controller.acceptTerms.value || 
          !controller.acceptPrivacyPolicy.value || 
          !controller.acceptDataUsage.value || 
          !controller.acceptSensitiveData.value) {
        Get.snackbar(
          'Termos não aceitos',
          'Você deve aceitar todos os termos para continuar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Chama o método register do controller
      await controller.register();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[50]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 20);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 20);
    path.quadraticBezierTo(size.width * 0.75, 40, size.width, 20);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
