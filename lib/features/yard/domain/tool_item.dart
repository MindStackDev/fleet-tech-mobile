enum ShiftType {
  morning('morning', 'Turno Mañana (06:00 - 14:00)'),
  afternoon('afternoon', 'Turno Tarde (14:00 - 22:00)'),
  night('night', 'Turno Noche (22:00 - 06:00)');

  final String value;
  final String label;

  const ShiftType(this.value, this.label);

  static ShiftType fromValue(String value) {
    return ShiftType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShiftType.morning,
    );
  }
}

enum InspectionStatus {
  pass('pass', 'Conforme'),
  fail('fail', 'Falla / Incompleto'),
  na('na', 'No Aplica');

  final String value;
  final String label;

  const InspectionStatus(this.value, this.label);
}

enum DefectSeverity {
  minor('minor', 'Leve (Monitoreo)'),
  moderate('moderate', 'Moderado (Atención próxima)'),
  critical('critical', 'Crítico (Bloqueo de unidad)');

  final String value;
  final String label;

  const DefectSeverity(this.value, this.label);
}

enum ToolCategory {
  mechanic('Herramientas Mecánicas'),
  safety('Seguridad y Emergencia'),
  electronics('Diagnóstico y Señalización');

  final String label;
  const ToolCategory(this.label);
}

class ToolItem {
  final int id;
  final String name;
  final ToolCategory category;
  final String specification;
  final bool isMandatory;
  final bool isCritical;

  const ToolItem({
    required this.id,
    required this.name,
    required this.category,
    required this.specification,
    this.isMandatory = true,
    this.isCritical = false,
  });
}

class ToolAuditAnswer {
  final int toolId;
  final String toolName;
  final InspectionStatus status;
  final DefectSeverity? defectSeverity;
  final String? observation;
  final List<String> photosBase64;

  const ToolAuditAnswer({
    required this.toolId,
    required this.toolName,
    required this.status,
    this.defectSeverity,
    this.observation,
    this.photosBase64 = const [],
  });

  ToolAuditAnswer copyWith({
    InspectionStatus? status,
    DefectSeverity? defectSeverity,
    String? observation,
    List<String>? photosBase64,
  }) {
    return ToolAuditAnswer(
      toolId: toolId,
      toolName: toolName,
      status: status ?? this.status,
      defectSeverity: defectSeverity ?? this.defectSeverity,
      observation: observation ?? this.observation,
      photosBase64: photosBase64 ?? this.photosBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_item_id': toolId,
      'status': status.value,
      'value': status.label,
      if (defectSeverity != null) 'defect_severity': defectSeverity!.value,
      if (observation != null) 'comments': observation,
      if (photosBase64.isNotEmpty) 'photos': photosBase64,
    };
  }
}
