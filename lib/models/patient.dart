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
  final bool acceptedTerms; // aceitou os termos de uso, política de privacidade e uso de dados
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
    required this.acceptedTerms,
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
      'acceptedTerms': acceptedTerms,
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
      acceptedTerms: json['acceptedTerms'] ?? false,
      twoFactorCode: json['twoFactorCode'],
      twoFactorExpires: json['twoFactorExpires'] != null ? DateTime.parse(json['twoFactorExpires']) : null,
      passwordResetCode: json['passwordResetCode'],
      passwordResetExpires: json['passwordResetExpires'] != null ? DateTime.parse(json['passwordResetExpires']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 