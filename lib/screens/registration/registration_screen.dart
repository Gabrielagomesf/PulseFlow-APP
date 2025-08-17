import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'registration_controller.dart';
import 'terms_screen.dart';

class ProfessionalRegistrationScreen extends StatefulWidget {
  const ProfessionalRegistrationScreen({super.key});

  @override
  State<ProfessionalRegistrationScreen> createState() => _ProfessionalRegistrationScreenState();
}

class _ProfessionalRegistrationScreenState extends State<ProfessionalRegistrationScreen> with TickerProviderStateMixin {
  final controller = Get.put(RegistrationController());
  final RxBool isCepLoading = false.obs;
  final RxString cepError = ''.obs;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1CB5E0),
              Color(0xFF000046),
              Color(0xFF1CB5E0),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative elements
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              
              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Header section
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Logo and title
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Color(0xFFE3F2FD)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_hospital_rounded,
                                  color: Color(0xFF1CB5E0),
                                  size: 50,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              const Text(
                                'Cadastro de Paciente',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Complete seus dados para acessar nossos serviços médicos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Form section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Account section
                                _buildSectionHeader(
                                  icon: Icons.person_outline,
                                  title: 'Informações de Conta',
                                  subtitle: 'Dados básicos para acesso',
                                ),
                                const SizedBox(height: 20),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.nameController,
                                  label: 'Nome completo',
                                  icon: Icons.person_outline,
                                  validator: controller.validateName,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: controller.validateEmail,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildPasswordField(
                                  context,
                                  controller: controller.passwordController,
                                  label: 'Senha',
                                  validator: controller.validatePassword,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildPasswordField(
                                  context,
                                  controller: controller.confirmPasswordController,
                                  label: 'Confirmar Senha',
                                  validator: controller.validateConfirmPassword,
                                ),
                                const SizedBox(height: 32),

                                // Personal section
                                _buildSectionHeader(
                                  icon: Icons.assignment_ind_outlined,
                                  title: 'Informações Pessoais',
                                  subtitle: 'Dados de identificação',
                                ),
                                const SizedBox(height: 20),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.cpfController,
                                  label: 'CPF',
                                  icon: Icons.badge_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [controller.cpfMask],
                                  validator: controller.validateCPF,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.rgController,
                                  label: 'RG',
                                  icon: Icons.credit_card_outlined,
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [controller.rgMask],
                                  validator: controller.validateRG,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.phoneController,
                                  label: 'Telefone',
                                  icon: Icons.phone_iphone_outlined,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [controller.phoneMask],
                                  validator: controller.validatePhone,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.nationalityController,
                                  label: 'Nacionalidade',
                                  icon: Icons.flag_outlined,
                                  validator: (value) => controller.validateRequired(value, 'Nacionalidade'),
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.birthDateController,
                                  label: 'Data de Nascimento',
                                  icon: Icons.cake_outlined,
                                  readOnly: true,
                                  onTap: () => controller.selectDate(context),
                                  validator: controller.validateBirthDate,
                                ),
                                const SizedBox(height: 16),
                                
                                Obx(() => _buildDropdownField(
                                  context,
                                  value: controller.gender.value,
                                  label: 'Sexo / Gênero',
                                  icon: Icons.transgender,
                                  items: controller.genders,
                                  onChanged: (String? newValue) { controller.gender.value = newValue; },
                                  validator: (v) => controller.validateDropdown(v, 'Sexo / Gênero'),
                                )),
                                const SizedBox(height: 16),
                                
                                Obx(() => _buildDropdownField(
                                  context,
                                  value: controller.maritalStatus.value,
                                  label: 'Estado Civil',
                                  icon: Icons.family_restroom_outlined,
                                  items: controller.maritalStatuses,
                                  onChanged: (String? newValue) { controller.maritalStatus.value = newValue; },
                                  validator: (v) => controller.validateDropdown(v, 'Estado Civil'),
                                )),
                                const SizedBox(height: 32),

                                // Address section
                                _buildSectionHeader(
                                  icon: Icons.home_outlined,
                                  title: 'Endereço',
                                  subtitle: 'Localização residencial',
                                ),
                                const SizedBox(height: 20),
                                
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
                                
                                _buildTextField(
                                  context,
                                  controller: controller.streetController,
                                  label: 'Rua',
                                  icon: Icons.alt_route,
                                  validator: (value) => controller.validateRequired(value, 'Rua'),
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.numberController,
                                  label: 'Número',
                                  icon: Icons.numbers_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => controller.validateRequired(value, 'Número'),
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.complementController,
                                  label: 'Complemento',
                                  icon: Icons.add_location_alt_outlined,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.neighborhoodController,
                                  label: 'Bairro',
                                  icon: Icons.location_city_outlined,
                                  validator: (value) => controller.validateRequired(value, 'Bairro'),
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  context,
                                  controller: controller.cityController,
                                  label: 'Cidade',
                                  icon: Icons.apartment_outlined,
                                  validator: (value) => controller.validateRequired(value, 'Cidade'),
                                ),
                                const SizedBox(height: 16),
                                
                                Obx(() => _buildDropdownField(
                                  context,
                                  value: controller.state.value,
                                  label: 'UF',
                                  icon: Icons.map_outlined,
                                  items: controller.states,
                                  onChanged: (String? newValue) { controller.state.value = newValue; },
                                  validator: (v) => controller.validateDropdown(v, 'UF'),
                                )),
                                const SizedBox(height: 32),

                                // Terms section
                                _buildSectionHeader(
                                  icon: Icons.gavel_outlined,
                                  title: 'Termos e Condições',
                                  subtitle: 'Autorizações necessárias',
                                ),
                                const SizedBox(height: 20),
                                
                                _buildCheckboxTile(
                                  value: controller.acceptTerms,
                                  title: 'Eu aceito os termos de uso e autorizo o uso dos meus dados para fins de atendimento e cadastro',
                                  onLinkTap: () => Get.to(() => const TermsScreen()),
                                ),
                                const SizedBox(height: 40),

                                // Register button
                                Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1CB5E0).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Obx(() => ElevatedButton(
                                    onPressed: controller.isLoading.value ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.person_add, color: Colors.white, size: 24),
                                              SizedBox(width: 12),
                                              Text(
                                                'CRIAR MINHA CONTA',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1CB5E0).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1CB5E0), size: 20) : null,
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
          borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
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
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1CB5E0), size: 20),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
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
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF1CB5E0), size: 20),
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
          borderSide: const BorderSide(color: Color(0xFF1CB5E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1CB5E0).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1CB5E0).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
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
              activeColor: const Color(0xFF1CB5E0),
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
                        color: Color(0xFF222B45),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: linkText,
                          style: const TextStyle(
                            color: Color(0xFF1CB5E0),
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
                      color: Color(0xFF222B45),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
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
      if (!controller.acceptTerms.value) {
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
