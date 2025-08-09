class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String patientId;
  final String startDate;
  final String? endDate;
  final String instructions;
  final DateTime createdAt;
  final String caregiverId;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.patientId,
    required this.startDate,
    this.endDate,
    required this.instructions,
    required this.createdAt,
    required this.caregiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'patientId': patientId,
      'startDate': startDate,
      'endDate': endDate,
      'instructions': instructions,
      'createdAt': createdAt.toIso8601String(),
      'caregiverId': caregiverId,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      patientId: map['patientId'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'],
      instructions: map['instructions'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      caregiverId: map['caregiverId'] ?? '',
    );
  }
} 