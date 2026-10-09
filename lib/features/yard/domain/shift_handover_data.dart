import 'package:flutter/foundation.dart';
import 'tool_item.dart';

class ShiftHandoverData {
  final int vehicleId;
  final String plateNumber;
  final ShiftType shiftType;
  final double odometer;
  final String fuelLevel; // Ej: '6/8'
  final String bayNumber;
  final String outgoingOperatorName;
  final String incomingOperatorName;
  final Uint8List? outgoingSignaturePng;
  final Uint8List? incomingSignaturePng;
  final List<ToolAuditAnswer> toolAnswers;
  final DateTime timestamp;

  const ShiftHandoverData({
    required this.vehicleId,
    required this.plateNumber,
    required this.shiftType,
    required this.odometer,
    required this.fuelLevel,
    required this.bayNumber,
    required this.outgoingOperatorName,
    required this.incomingOperatorName,
    this.outgoingSignaturePng,
    this.incomingSignaturePng,
    this.toolAnswers = const [],
    required this.timestamp,
  });

  bool get hasCriticalDefect {
    return toolAnswers.any((a) =>
        a.status == InspectionStatus.fail &&
        a.defectSeverity == DefectSeverity.critical);
  }

  int get failedToolsCount {
    return toolAnswers.where((a) => a.status == InspectionStatus.fail).length;
  }
}
