class Diabetes {
  final String? id;
  final String pacienteId;
  final DateTime data;
  final double glicemia;
  final String unidade; // mg/dL ou mmol/L

  Diabetes({
    this.id,
    required this.pacienteId,
    required this.data,
    required this.glicemia,
    required this.unidade,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'pacienteId': pacienteId,
      'data': data.toIso8601String(),
      'glicemia': glicemia,
      'unidade': unidade,
    };
  }

  factory Diabetes.fromMap(Map<String, dynamic> map) {
    return Diabetes(
      id: map['_id']?.toString(),
      pacienteId: map['pacienteId']?.toString() ?? '',
      data: DateTime.parse(map['data'] as String),
      glicemia: (map['glicemia'] is int)
          ? (map['glicemia'] as int).toDouble()
          : (map['glicemia'] as num).toDouble(),
      unidade: map['unidade']?.toString() ?? 'mg/dL',
    );
  }
}
