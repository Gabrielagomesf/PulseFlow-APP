import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class SMSService extends GetxController {
  static SMSService get instance => Get.find<SMSService>();
  
  // Configurações do Twilio (15.000 SMS gratuitos/mês)
  String get _twilioAccountSid => AppConfig.twilioAccountSid;
  String get _twilioAuthToken => AppConfig.twilioAuthToken;
  String get _twilioPhoneNumber => AppConfig.twilioPhoneNumber;
  
  static const String _appName = 'PulseFlow';
  static const int _codeExpiryMinutes = 5;

  String _generateSMSMessage(String code, {String? userName}) {
    if (userName != null && userName.isNotEmpty) {
      return 'Ola $userName! Seu codigo $_appName: $code (expira em $_codeExpiryMinutes min)';
    } else {
      return 'Seu codigo $_appName: $code (expira em $_codeExpiryMinutes min)';
    }
  }

  Future<bool> sendSMSViaTwilio(String phoneNumber, String code, {String? userName}) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      
      final url = 'https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': formattedPhone,
          'From': _twilioPhoneNumber,
          'Body': _generateSMSMessage(code, userName: userName),
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['sid'] != null;
      } else {
        print('Erro ao enviar SMS via Twilio: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao enviar SMS via Twilio: $e');
      return false;
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }
    
    if (cleanNumber.startsWith('0')) {
      return '+55${cleanNumber.substring(1)}';
    }
    
    if (cleanNumber.length == 11) {
      return '+55$cleanNumber';
    }
    
    if (cleanNumber.length == 10) {
      return '+55$cleanNumber';
    }
    
    return phoneNumber;
  }

  Future<bool> send2FACode(String phoneNumber, String code, {String? userName}) async {
    try {
      if (_twilioAccountSid.isNotEmpty && _twilioAuthToken.isNotEmpty) {
        final success = await sendSMSViaTwilio(phoneNumber, code, userName: userName);
        if (success) {
          print('Código 2FA enviado via Twilio');
          return true;
        }
      }
    } catch (e) {
      print('Erro ao enviar SMS via Twilio: $e');
    }

    return false;
  }
}
