class Patient {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String cpf;
  final String rg;
  final String phone;
  final String? secondaryPhone;
  final DateTime birthDate;
  final String gender;
  final String maritalStatus;
  final String nationality;
  final String address;
  final double? height; // altura em metros
  final double? weight; // peso em kg
  final String? bloodType; // tipo sanguíneo
  final List<String>? allergies; // lista de alergias
  final List<String>? chronicDiseases; // doenças crônicas
  final bool usesMedications; // flag para uso de medicamentos
  final String? medications; // medicamentos em uso
  final bool hadSurgeries; // flag para cirurgias
  final String? surgeries; // cirurgias realizadas
  final String? insuranceProvider; // operadora do convênio
  final String? insuranceNumber; // número do convênio
  final DateTime? insuranceValidity; // validade do convênio
  final bool acceptedTerms; // aceitou os termos de uso
  final bool acceptedPrivacyPolicy; // aceitou a política de privacidade
  final bool acceptedDataUsage; // aceitou o uso de dados
  final String? twoFactorCode; // Código 2FA
  final DateTime? twoFactorExpires; // Expiração do código 2FA
  final String? passwordResetCode; // Código de redefinição de senha
  final DateTime? passwordResetExpires; // Expiração do código de redefinição
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.cpf,
    required this.rg,
    required this.phone,
    this.secondaryPhone,
    required this.birthDate,
    required this.gender,
    required this.maritalStatus,
    required this.nationality,
    required this.address,
    this.height,
    this.weight,
    this.bloodType,
    this.allergies,
    this.chronicDiseases,
    required this.usesMedications,
    this.medications,
    required this.hadSurgeries,
    this.surgeries,
    this.insuranceProvider,
    this.insuranceNumber,
    this.insuranceValidity,
    required this.acceptedTerms,
    required this.acceptedPrivacyPolicy,
    required this.acceptedDataUsage,
    this.twoFactorCode,
    this.twoFactorExpires,
    this.passwordResetCode,
    this.passwordResetExpires,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'rg': rg,
      'phone': phone,
      'secondaryPhone': secondaryPhone,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'address': address,
      'height': height,
      'weight': weight,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'usesMedications': usesMedications,
      'medications': medications,
      'hadSurgeries': hadSurgeries,
      'surgeries': surgeries,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'insuranceValidity': insuranceValidity?.toIso8601String(),
      'acceptedTerms': acceptedTerms,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
      'acceptedDataUsage': acceptedDataUsage,
      'twoFactorCode': twoFactorCode,
      'twoFactorExpires': twoFactorExpires?.toIso8601String(),
      'passwordResetCode': passwordResetCode,
      'passwordResetExpires': passwordResetExpires?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id']?.toString(),
      name: json['name'],
      email: json['email'],
      password: json['password'],
      cpf: json['cpf'],
      rg: json['rg'],
      phone: json['phone'],
      secondaryPhone: json['secondaryPhone'],
      birthDate: DateTime.parse(json['birthDate']),
      gender: json['gender'],
      maritalStatus: json['maritalStatus'],
      nationality: json['nationality'],
      address: json['address'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      bloodType: json['bloodType'],
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : null,
      chronicDiseases: json['chronicDiseases'] != null ? List<String>.from(json['chronicDiseases']) : null,
      usesMedications: json['usesMedications'] ?? false,
      medications: json['medications'],
      hadSurgeries: json['hadSurgeries'] ?? false,
      surgeries: json['surgeries'],
      insuranceProvider: json['insuranceProvider'],
      insuranceNumber: json['insuranceNumber'],
      insuranceValidity: json['insuranceValidity'] != null ? DateTime.parse(json['insuranceValidity']) : null,
      acceptedTerms: json['acceptedTerms'] ?? false,
      acceptedPrivacyPolicy: json['acceptedPrivacyPolicy'] ?? false,
      acceptedDataUsage: json['acceptedDataUsage'] ?? false,
      twoFactorCode: json['twoFactorCode'],
      twoFactorExpires: json['twoFactorExpires'] != null ? DateTime.parse(json['twoFactorExpires']) : null,
      passwordResetCode: json['passwordResetCode'],
      passwordResetExpires: json['passwordResetExpires'] != null ? DateTime.parse(json['passwordResetExpires']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Método para calcular IMC
  double? get bmi {
    if (height == null || weight == null) return null;
    return weight! / (height! * height!);
  }

  // Método para obter categoria do IMC
  String? get bmiCategory {
    if (bmi == null) return null;
    if (bmi! < 18.5) return 'Abaixo do peso';
    if (bmi! < 25) return 'Peso normal';
    if (bmi! < 30) return 'Sobrepeso';
    if (bmi! < 35) return 'Obesidade Grau I';
    if (bmi! < 40) return 'Obesidade Grau II';
    return 'Obesidade Grau III';
  }
} 