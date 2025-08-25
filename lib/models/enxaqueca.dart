class Enxaqueca {
  final String? id;
  final String pacienteId;
  final DateTime data;
  final String intensidade;
  final int duracao;

  Enxaqueca({
    this.id,
    required this.pacienteId,
    required this.data,
    required this.intensidade,
    required this.duracao,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'pacienteId': pacienteId,
      'data': data.toIso8601String(),
      'intensidade': intensidade,
      'duracao': duracao,
    };
  }

  factory Enxaqueca.fromMap(Map<String, dynamic> map) {
    return Enxaqueca(
      id: map['_id']?.toString(),
      pacienteId: map['pacienteId'] ?? '',
      data: DateTime.parse(map['data']),
      intensidade: map['intensidade'] ?? '',
      duracao: map['duracao'] ?? 0,
    );
  }
}
