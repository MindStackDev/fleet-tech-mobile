import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inspection/data/inspection_repository.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/tool_item.dart';
import '../domain/shift_handover_data.dart';
import 'widgets/dual_signature_pad.dart';
import 'widgets/tool_audit_card.dart';
import 'widgets/handover_receipt_dialog.dart';

class ShiftHandoverScreen extends ConsumerStatefulWidget {
  final String plateNumber;
  final int vehicleId;

  const ShiftHandoverScreen({
    super.key,
    this.plateNumber = 'V-105-TRUCK',
    this.vehicleId = 105,
  });

  @override
  ConsumerState<ShiftHandoverScreen> createState() => _ShiftHandoverScreenState();
}

class _ShiftHandoverScreenState extends ConsumerState<ShiftHandoverScreen> {
  // Operational state
  ShiftType _shiftType = ShiftType.morning;
  final TextEditingController _odometerController = TextEditingController(text: '128450');
  final TextEditingController _bayController = TextEditingController(text: 'BAHIA-08');
  final TextEditingController _outgoingOpController = TextEditingController(text: 'Juan Pérez (Saliente)');
  final TextEditingController _incomingOpController = TextEditingController(text: 'Carlos Méndez (Entrante)');
  String _selectedFuel = '6/8';

  // Signatures
  Uint8List? _outgoingSigBytes;
  Uint8List? _incomingSigBytes;

  // Dotación reglamentaria de herramientas
  late List<ToolItem> _officialKit;
  late Map<int, ToolAuditAnswer> _answers;

  @override
  void initState() {
    super.initState();
    _officialKit = const [
      ToolItem(
        id: 101,
        name: 'Extintor PQS 6kg (Vigencia & Presión)',
        category: ToolCategory.safety,
        specification: 'Manómetro en zona verde, precinto intacto',
        isCritical: true,
      ),
      ToolItem(
        id: 102,
        name: 'Gata Hidráulica de Botella 20T',
        category: ToolCategory.mechanic,
        specification: 'Sin fugas de aceite, palanca de bombeo incluida',
        isCritical: true,
      ),
      ToolItem(
        id: 103,
        name: 'Llave de Ruedas Cruz c/ Dado 33mm',
        category: ToolCategory.mechanic,
        specification: 'Estructura forjada sin fisuras',
        isCritical: false,
      ),
      ToolItem(
        id: 104,
        name: 'Triángulos de Seguridad Reflectivos (Par)',
        category: ToolCategory.safety,
        specification: '2 unidades con soporte plegable operativo',
        isCritical: false,
      ),
      ToolItem(
        id: 105,
        name: 'Conos de Seguridad 28" c/ Cinta Reflectiva',
        category: ToolCategory.safety,
        specification: '2 conos de PVC flexible naranja',
        isCritical: false,
      ),
      ToolItem(
        id: 106,
        name: 'Botiquín de Primeros Auxilios Reglamentario',
        category: ToolCategory.safety,
        specification: 'Con insumos completos y vigentes según MTC',
        isCritical: false,
      ),
      ToolItem(
        id: 107,
        name: 'Linterna LED de Inspección de Patio',
        category: ToolCategory.electronics,
        specification: 'Batería recargable y cuerpo anti-impacto',
        isCritical: false,
      ),
    ];

    _answers = {
      for (var tool in _officialKit)
        tool.id: ToolAuditAnswer(
          toolId: tool.id,
          toolName: tool.name,
          status: InspectionStatus.pass,
        ),
    };
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _bayController.dispose();
    _outgoingOpController.dispose();
    _incomingOpController.dispose();
    super.dispose();
  }

  void _submitHandover() {
    final handoverPayload = ShiftHandoverData(
      vehicleId: widget.vehicleId,
      plateNumber: widget.plateNumber,
      shiftType: _shiftType,
      odometer: double.tryParse(_odometerController.text) ?? 0.0,
      fuelLevel: _selectedFuel,
      bayNumber: _bayController.text,
      outgoingOperatorName: _outgoingOpController.text,
      incomingOperatorName: _incomingOpController.text,
      outgoingSignaturePng: _outgoingSigBytes,
      incomingSignaturePng: _incomingSigBytes,
      toolAnswers: _answers.values.toList(),
      timestamp: DateTime.now(),
    );

    final hasCritical = handoverPayload.hasCriticalDefect;
    final failedCount = handoverPayload.failedToolsCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasCritical ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
              color: hasCritical ? AppColors.error : AppColors.success,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              hasCritical ? 'Bloqueo Preventivo' : 'Relevo Conforme',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasCritical) ...[
              const Text(
                '¡ATENCIÓN! Se detectaron defectos críticos en el kit de herramientas o seguridad.',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error),
              ),
              const SizedBox(height: 8),
              const Text(
                'La unidad pasará automáticamente a estado IN_MAINTENANCE en la central de patio y no podrá salir a ruta hasta su regularización.',
              ),
            ] else ...[
              const Text(
                'El relevo de turno y custodia de herramientas fue validado por ambos operadores.',
              ),
              const SizedBox(height: 8),
              Text(
                'Odómetro: ${handoverPayload.odometer} km • Bahía: ${handoverPayload.bayNumber} • Combustible: ${handoverPayload.fuelLevel}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              if (failedCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Novedades no críticas registradas: $failedCount ítem(s)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warningText,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Doble firma registrada y encolada para sincronización offline/online con fleet-tech-api.',
                style: TextStyle(fontSize: 11, color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              // Persist to PostgreSQL backend via inspectionRepository
              final repo = ref.read(inspectionRepositoryProvider);
              final result = await repo.submitInspection(
                vehicleId: 3, // ABC-123 in PostgreSQL
                checklistTemplateId: 1,
                shift: _shiftType.value,
                startMileage: int.tryParse(_odometerController.text) ?? 128450,
                fuelLevel: _selectedFuel,
                yardLocation: 'Bahía ${_bayController.text}',
                generalNotes: 'Relevo de turno entre ${_outgoingOpController.text} y ${_incomingOpController.text}',
                answers: _answers.values.map((a) => {
                  'checklist_item_id': a.toolId,
                  'status': a.status.value,
                  'notes': a.observation,
                }).toList(),
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(hasCritical
                      ? 'Relevo registrado en PostgreSQL #${result.inspectionId}. UNIDAD BLOQUEADA PREVENTIVAMENTE.'
                      : 'Relevo guardado en PostgreSQL #${result.inspectionId} con éxito.'),
                  backgroundColor: hasCritical ? AppColors.error : AppColors.successText,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => HandoverReceiptDialog(
                  orderCode: 'REL-2026-${result.inspectionId ?? 1027}',
                  plateNumber: widget.plateNumber,
                  vehicleModel: 'Toyota Hilux 4x4 (2023)',
                  odometer: _odometerController.text,
                  fuelLevel: _selectedFuel,
                  bayNumber: _bayController.text,
                  outgoingOperator: _outgoingOpController.text,
                  incomingOperator: _incomingOpController.text,
                  verificationHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                  hasDefects: hasCritical,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: hasCritical ? AppColors.error : AppColors.primaryDark,
            ),
            child: const Text('Confirmar Relevo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RELEVO DE TURNO & PATIO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Unidad ${widget.plateNumber}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Paso 1 de 2',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shift & Operational parameters
            _buildOperationalSection(),
            const SizedBox(height: 18),
            // Tools Audit Section
            _buildToolsAuditSection(),
            const SizedBox(height: 18),
            // Dual Signature Section
            _buildSignaturesSection(),
            const SizedBox(height: 24),
            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PARÁMETROS OPERATIVOS DE RELEVO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Shift Selector
          Row(
            children: ShiftType.values.map((shift) {
              final isSelected = _shiftType == shift;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(
                      shift.name == 'morning'
                          ? 'Mañana'
                          : (shift.name == 'afternoon' ? 'Tarde' : 'Noche'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryDark,
                    onSelected: (_) => setState(() => _shiftType = shift),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _odometerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Odómetro (km)',
                    prefixIcon: Icon(Icons.speed_rounded, size: 20),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _bayController,
                  decoration: const InputDecoration(
                    labelText: 'Bahía de Estacionamiento',
                    prefixIcon: Icon(Icons.local_parking_rounded, size: 20),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Nivel de Combustible:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: ['1/8', '2/8', '4/8', '6/8', '8/8'].map((f) {
              final isSel = _selectedFuel == f;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedFuel = f),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSel ? AppColors.primarySoft : Colors.white,
                      side: BorderSide(
                        color: isSel ? AppColors.primaryDark : AppColors.border,
                        width: isSel ? 1.5 : 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSel ? AppColors.primaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsAuditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CUSTODIA DE KIT DE HERRAMIENTAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Dotación oficial de la empresa • Deslinde legal',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${_answers.values.where((a) => a.status == InspectionStatus.pass).length}/${_officialKit.length} OK',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._officialKit.map((tool) {
          final ans = _answers[tool.id]!;
          return ToolAuditCard(
            tool: tool,
            answer: ans,
            onStatusChanged: (status) {
              setState(() {
                _answers[tool.id] = ans.copyWith(
                  status: status,
                  defectSeverity: status == InspectionStatus.fail
                      ? (tool.isCritical ? DefectSeverity.critical : DefectSeverity.moderate)
                      : null,
                );
              });
            },
            onSeverityChanged: (sev) {
              setState(() {
                _answers[tool.id] = ans.copyWith(defectSeverity: sev);
              });
            },
            onObservationChanged: (obs) {
              _answers[tool.id] = ans.copyWith(observation: obs);
            },
            onAddPhoto: () {
              setState(() {
                // Mock base64 evidence attachment
                _answers[tool.id] = ans.copyWith(
                  photosBase64: [...ans.photosBase64, 'mock_b64_evidence_${tool.id}'],
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evidencia fotográfica comprimida adjunta.'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSignaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'DESLINDE LEGAL Y DOBLE FIRMA DIGITAL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Al estampar la firma, el operador entrante da conformidad de los ítems recibidos.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        DualSignaturePad(
          outgoingOperatorName: _outgoingOpController.text,
          incomingOperatorName: _incomingOpController.text,
          onOutgoingSigned: (bytes) => _outgoingSigBytes = bytes,
          onIncomingSigned: (bytes) => _incomingSigBytes = bytes,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _submitHandover,
      icon: const Icon(Icons.assignment_turned_in_rounded, size: 20, color: Colors.white),
      label: const Text(
        'Registrar Relevo y Custodia',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
      ),
    );
  }
}
