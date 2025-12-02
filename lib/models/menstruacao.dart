import 'package:mongo_dart/mongo_dart.dart';

class DiaMenstruacao {
  final String fluxo; // "Intenso", "Moderado", "Leve"
  final bool teveColica;
  final String humor; // "Ansioso", "Raiva", "Cansado", "Triste", "Feliz", etc.

  DiaMenstruacao({
    required this.fluxo,
    required this.teveColica,
    required this.humor,
  });

  factory DiaMenstruacao.fromJson(Map<String, dynamic> json) {
    return DiaMenstruacao(
      fluxo: json['fluxo']?.toString() ?? '',
      teveColica: json['teveColica'] as bool? ?? false,
      humor: json['humor']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fluxo': fluxo,
      'teveColica': teveColica,
      'humor': humor,
    };
  }
}

class Menstruacao {
  final String? id;
  final String? pacienteId;
  final DateTime dataInicio;
  final DateTime dataFim;
  final Map<String, DiaMenstruacao>? diasPorData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Menstruacao({
    this.id,
    this.pacienteId,
    required this.dataInicio,
    required this.dataFim,
    this.diasPorData,
    this.createdAt,
    this.updatedAt,
  });

  factory Menstruacao.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic idValue) {
      if (idValue == null) return null;
      if (idValue is String) return idValue;
      if (idValue is ObjectId) return idValue.toHexString();
      if (idValue is Map && idValue['\$oid'] != null) {
        return idValue['\$oid'].toString();
      }
      return idValue.toString();
    }

    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue == null) throw 'Data inválida';
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        final parsed = DateTime.tryParse(dateValue);
        if (parsed != null) return parsed;
      }
      if (dateValue is Map && dateValue['\$date'] != null) {
        final dateData = dateValue['\$date'];
        if (dateData is String) {
          final parsed = DateTime.tryParse(dateData);
          if (parsed != null) return parsed;
        } else if (dateData is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateData, isUtc: true);
        }
      }
      throw 'Data inválida: $dateValue';
    }

    Map<String, DiaMenstruacao>? diasPorData;
    if (json['diasPorData'] != null) {
      diasPorData = <String, DiaMenstruacao>{};
      final diasData = json['diasPorData'] as Map<String, dynamic>;
      diasData.forEach((data, dados) {
        if (dados is Map<String, dynamic>) {
          diasPorData![data] = DiaMenstruacao.fromJson(dados);
        }
      });
    }

    return Menstruacao(
      id: extractId(json['_id']),
      pacienteId: extractId(json['pacienteId']),
      dataInicio: parseDateTime(json['dataInicio']),
      dataFim: parseDateTime(json['dataFim']),
      diasPorData: diasPorData,
      createdAt: json['createdAt'] != null ? parseDateTime(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? parseDateTime(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? diasPorDataJson;
    if (diasPorData != null) {
      diasPorDataJson = <String, dynamic>{};
      diasPorData!.forEach((data, dia) {
        diasPorDataJson![data] = dia.toJson();
      });
    }

    return {
      if (id != null) '_id': ObjectId.parse(id!),
      if (pacienteId != null) 'pacienteId': ObjectId.parse(pacienteId!),
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      if (diasPorDataJson != null) 'diasPorData': diasPorDataJson,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Menstruacao copyWith({
    String? id,
    String? pacienteId,
    DateTime? dataInicio,
    DateTime? dataFim,
    Map<String, DiaMenstruacao>? diasPorData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Menstruacao(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      diasPorData: diasPorData ?? this.diasPorData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calcula a duração do ciclo em dias
  int get duracaoEmDias {
    return dataFim.difference(dataInicio).inDays + 1;
  }

  // Verifica se a menstruação está ativa (hoje está entre dataInicio e dataFim)
  bool get isAtiva {
    final hoje = DateTime.now();
    return hoje.isAfter(dataInicio.subtract(const Duration(days: 1))) && 
           hoje.isBefore(dataFim.add(const Duration(days: 1)));
  }

  // Retorna o status da menstruação
  String get status {
    final hoje = DateTime.now();
    if (hoje.isBefore(dataInicio)) {
      return 'Próxima';
    } else if (hoje.isAfter(dataFim)) {
      return 'Finalizada';
    } else {
      return 'Ativa';
    }
  }
}
