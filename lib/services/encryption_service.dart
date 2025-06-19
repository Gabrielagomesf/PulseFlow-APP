import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  final _storage = const FlutterSecureStorage();
  static const String _saltKey = 'password_salt';

  factory EncryptionService() {
    return _instance;
  }

  EncryptionService._internal();

  // Gera um salt aleatório
  String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return sha256.convert(utf8.encode(random)).toString().substring(0, 16);
  }

  // Obtém o salt armazenado ou gera um novo
  Future<String> _getOrCreateSalt() async {
    String? storedSalt = await _storage.read(key: _saltKey);
    if (storedSalt == null) {
      storedSalt = _generateSalt();
      await _storage.write(key: _saltKey, value: storedSalt);
    }
    return storedSalt;
  }

  // Criptografa a senha usando SHA-256 com salt
  Future<String> hashPassword(String password) async {
    final salt = await _getOrCreateSalt();
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Verifica se a senha fornecida corresponde à senha criptografada
  Future<bool> verifyPassword(String password, String hashedPassword) async {
    final salt = await _getOrCreateSalt();
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString() == hashedPassword;
  }
} 