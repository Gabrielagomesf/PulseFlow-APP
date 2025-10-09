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
  late final RegistrationController controller;
  final RxBool isCepLoading = false.obs;
  final RxString cepError = ''.obs;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Deletar instância antiga se existir e criar nova
    try {
      Get.delete<RegistrationController>();
    } catch (e) {
      // Ignorar se não existir
    }
    controller = Get.put(RegistrationController());
    
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
    // Deletar controller ao sair da tela
    Get.delete<RegistrationController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;  // Mobile
    final isMediumScreen = size.width >= 480 && size.width < 768;  // Tablet portrait
    final isLargeScreen = size.width >= 768 && size.width < 1024;  // Tablet landscape
    final isVerySmallScreen = size.height < 700; // Para telas muito baixas
    final isLandscape = size.width > size.height; // Orientação paisagem
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF00324A),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header section
              Expanded(
                flex: isLandscape 
                  ? (isVerySmallScreen ? 1 : isSmallScreen ? 1 : isMediumScreen ? 1 : 1)
                  : (isVerySmallScreen ? 1 : isSmallScreen ? 1 : isMediumScreen ? 1 : 1),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/pulseflow2.png',
                        width: isLandscape 
                          ? (isVerySmallScreen ? 80 : isSmallScreen ? 90 : isMediumScreen ? 100 : isLargeScreen ? 110 : 120)
                          : (isVerySmallScreen ? 90 : isSmallScreen ? 100 : isMediumScreen ? 110 : isLargeScreen ? 120 : 130),
                        height: isLandscape 
                          ? (isVerySmallScreen ? 80 : isSmallScreen ? 90 : isMediumScreen ? 100 : isLargeScreen ? 110 : 120)
                          : (isVerySmallScreen ? 90 : isSmallScreen ? 100 : isMediumScreen ? 110 : isLargeScreen ? 120 : 130),
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Form section
              Expanded(
                flex: isLandscape 
                  ? (isVerySmallScreen ? 6 : isSmallScreen ? 6 : isMediumScreen ? 6 : 5)
                  : (isVerySmallScreen ? 6 : isSmallScreen ? 6 : isMediumScreen ? 6 : 5),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: isLandscape 
                          ? (isVerySmallScreen ? 10 : isSmallScreen ? 15 : isMediumScreen ? 20 : isLargeScreen ? 25 : 30)
                          : (isVerySmallScreen ? 15 : isSmallScreen ? 20 : isMediumScreen ? 25 : isLargeScreen ? 30 : 35),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header do container com botão de voltar
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: isLandscape 
                                ? (isVerySmallScreen ? 12 : isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20)
                                : (isVerySmallScreen ? 14 : isSmallScreen ? 16 : isMediumScreen ? 18 : isLargeScreen ? 20 : 22),
                              horizontal: isLandscape 
                                ? (isVerySmallScreen ? 12 : isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20)
                                : (isVerySmallScreen ? 14 : isSmallScreen ? 16 : isMediumScreen ? 18 : isLargeScreen ? 20 : 22),
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Get.back(),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: const Color(0xFF00324A),
                                    size: isLandscape 
                                      ? (isVerySmallScreen ? 18 : isSmallScreen ? 20 : isMediumScreen ? 22 : isLargeScreen ? 24 : 26)
                                      : (isVerySmallScreen ? 20 : isSmallScreen ? 22 : isMediumScreen ? 24 : isLargeScreen ? 26 : 28),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      // Linha decorativa
                                      Container(
                                        width: 50,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00324A).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      SizedBox(height: isLandscape 
                                        ? (isVerySmallScreen ? 8 : isSmallScreen ? 10 : isMediumScreen ? 12 : isLargeScreen ? 14 : 16)
                                        : (isVerySmallScreen ? 10 : isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18)),
                                      // Título de boas-vindas
                                      Text(
                                        'Criar Nova Conta',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isLandscape 
                                            ? (isVerySmallScreen ? 20 : isSmallScreen ? 22 : isMediumScreen ? 24 : isLargeScreen ? 26 : 28)
                                            : (isVerySmallScreen ? 22 : isSmallScreen ? 24 : isMediumScreen ? 26 : isLargeScreen ? 28 : 30),
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF00324A),
                                        ),
                                      ),
                                      SizedBox(height: isLandscape 
                                        ? (isVerySmallScreen ? 2 : isSmallScreen ? 3 : isMediumScreen ? 4 : isLargeScreen ? 5 : 6)
                                        : (isVerySmallScreen ? 3 : isSmallScreen ? 4 : isMediumScreen ? 5 : isLargeScreen ? 6 : 7)),
                                      Text(
                                        'Complete seus dados para acessar nossos serviços médicos',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isLandscape 
                                            ? (isVerySmallScreen ? 12 : isSmallScreen ? 13 : isMediumScreen ? 14 : isLargeScreen ? 15 : 16)
                                            : (isVerySmallScreen ? 13 : isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 16 : 17),
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 48), // Espaço para balancear o layout
                              ],
                            ),
                          ),
                          // Conteúdo do formulário
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isLandscape 
                                    ? (isVerySmallScreen ? 12 : isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20)
                                    : (isVerySmallScreen ? 14 : isSmallScreen ? 16 : isMediumScreen ? 18 : isLargeScreen ? 20 : 22),
                                  0,
                                  isLandscape 
                                    ? (isVerySmallScreen ? 12 : isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20)
                                    : (isVerySmallScreen ? 14 : isSmallScreen ? 16 : isMediumScreen ? 18 : isLargeScreen ? 20 : 22),
                                  isLandscape 
                                    ? (isVerySmallScreen ? 12 : isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20)
                                    : (isVerySmallScreen ? 14 : isSmallScreen ? 16 : isMediumScreen ? 18 : isLargeScreen ? 20 : 22),
                                ),
                                child: _buildRegistrationForm(),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildRegistrationForm() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    
    return Form(
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
          const SizedBox(height: 16),
          
          // Campo de foto de perfil
          _buildProfilePhotoField(context, controller),
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
          const SizedBox(height: 16),
          
          _buildTextField(
            context,
            controller: controller.heightController,
            label: 'Altura (cm)',
            icon: Icons.height_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: controller.validateHeight,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            context,
            controller: controller.weightController,
            label: 'Peso (kg)',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: controller.validateWeight,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            context,
            controller: controller.professionController,
            label: 'Profissão',
            icon: Icons.work_outline,
          ),
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
            title: 'Aceito os ',
            linkText: 'termos de uso',
            onLinkTap: () => Get.to(() => const TermsScreen()),
          ),
          const SizedBox(height: 40),

          // Register button
          Container(
            height: isSmallScreen ? 48 : isMediumScreen ? 52 : isLargeScreen ? 56 : 60,
            decoration: BoxDecoration(
              color: const Color(0xFF00324A),
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00324A).withValues(alpha: 0.3),
                  blurRadius: isSmallScreen ? 10 : isMediumScreen ? 12 : isLargeScreen ? 15 : 18,
                  offset: Offset(0, isSmallScreen ? 5 : isMediumScreen ? 6 : isLargeScreen ? 8 : 10),
                ),
              ],
            ),
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : isMediumScreen ? 20 : isLargeScreen ? 24 : 28,
                  vertical: isSmallScreen ? 12 : isMediumScreen ? 14 : isLargeScreen ? 16 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : isMediumScreen ? 16 : isLargeScreen ? 18 : 20),
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: isSmallScreen ? 20 : isMediumScreen ? 24 : isLargeScreen ? 26 : 28,
                      height: isSmallScreen ? 20 : isMediumScreen ? 24 : isLargeScreen ? 26 : 28,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, color: Colors.white, size: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22),
                        SizedBox(width: isSmallScreen ? 8 : isMediumScreen ? 10 : isLargeScreen ? 12 : 14),
                        Text(
                          'CRIAR MINHA CONTA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 15 : isMediumScreen ? 16 : isLargeScreen ? 17 : 18,
                          ),
                        ),
                      ],
                    ),
            )),
          ),
          const SizedBox(height: 32),
        ],
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
          colors: [Color(0xFF00324A), Color(0xFF00324A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00324A).withValues(alpha: 0.2),
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
              color: Colors.white.withValues(alpha: 0.2),
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
                    color: Colors.white.withValues(alpha: 0.8),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : isMediumScreen ? 17 : isLargeScreen ? 17 : 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
          ),
          prefixIcon: icon != null ? Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00324A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00324A), size: isSmallScreen ? 18 : isMediumScreen ? 19 : isLargeScreen ? 19 : 20),
          ) : null,
          suffixIcon: suffixIcon,
          suffixText: suffixText,
          helperText: helperText,
          helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00324A), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : isMediumScreen ? 22 : isLargeScreen ? 23 : 24, 
            vertical: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22
          ),
        ),
        obscureText: obscureText,
        validator: validator,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    final obscure = true.obs;
    
    return Obx(() => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure.value,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : isMediumScreen ? 17 : isLargeScreen ? 17 : 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00324A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lock_outline, color: const Color(0xFF00324A), size: isSmallScreen ? 18 : isMediumScreen ? 19 : isLargeScreen ? 19 : 20),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: IconButton(
              icon: Icon(
                obscure.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[500],
                size: isSmallScreen ? 18 : isMediumScreen ? 19 : isLargeScreen ? 19 : 20,
              ),
              onPressed: () => obscure.value = !obscure.value,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00324A), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : isMediumScreen ? 22 : isLargeScreen ? 23 : 24, 
            vertical: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22
          ),
        ),
        validator: validator,
      ),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 480;
    final isMediumScreen = size.width >= 480 && size.width < 768;
    final isLargeScreen = size.width >= 768 && size.width < 1024;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00324A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00324A), size: isSmallScreen ? 18 : isMediumScreen ? 19 : isLargeScreen ? 19 : 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00324A), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : isMediumScreen ? 22 : isLargeScreen ? 23 : 24, 
            vertical: isSmallScreen ? 18 : isMediumScreen ? 20 : isLargeScreen ? 21 : 22
          ),
        ),
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : isMediumScreen ? 17 : isLargeScreen ? 17 : 18,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF00324A),
          overflow: TextOverflow.ellipsis,
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : isMediumScreen ? 15 : isLargeScreen ? 15 : 16,
                color: const Color(0xFF00324A),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00324A)),
        menuMaxHeight: 300,
      ),
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
        color: const Color(0xFF00324A).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00324A).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              activeColor: const Color(0xFF00324A),
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
                            color: Color(0xFF00324A),
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

  Widget _buildProfilePhotoField(BuildContext context, RegistrationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera, color: Color(0xFF00324A), size: 20),
              const SizedBox(width: 8),
              Text(
                'Foto de Perfil',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '(Opcional)',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Obx(() => controller.profilePhoto.value != null
            ? _buildPhotoPreview(context, controller)
            : _buildPhotoPlaceholder(context, controller)
          ),
          
          const SizedBox(height: 8),
          Text(
            'Adicione uma foto para personalizar seu perfil',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context, RegistrationController controller) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: const Color(0xFF00324A), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00324A).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.file(
              controller.profilePhoto.value!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => controller.showImageSourceDialog(context),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Alterar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00324A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: controller.removeProfilePhoto,
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Remover'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context, RegistrationController controller) {
    return GestureDetector(
      onTap: () => controller.showImageSourceDialog(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(60),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Adicionar\nFoto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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