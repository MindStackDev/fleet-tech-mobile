import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/inspection_repository.dart';

enum ItemCheckStatus { pass, fail, na }

class ChecklistItemData {
  final int id;
  final String label;
  final String section;
  final bool isCritical;
  ItemCheckStatus status;
  String? comments;

  ChecklistItemData({
    required this.id,
    required this.label,
    required this.section,
    required this.isCritical,
    this.status = ItemCheckStatus.pass,
    this.comments,
  });
}

class PreUseInspectionScreen extends ConsumerStatefulWidget {
  final String plateNumber;
  final String vehicleModel;

  const PreUseInspectionScreen({
    super.key,
    this.plateNumber = 'ABC-123',
    this.vehicleModel = 'Toyota Hilux 4x4 (2023)',
  });

  @override
  ConsumerState<PreUseInspectionScreen> createState() => _PreUseInspectionScreenState();
}

class _PreUseInspectionScreenState extends ConsumerState<PreUseInspectionScreen> {
  late List<ChecklistItemData> _items;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _items = [
      // 1. Luces y Eléctrico (Checklist items 6)
      ChecklistItemData(id: 6, section: '1. Sistema Eléctrico y Luces', label: 'Faros Principales, Neblineros y Módulos LED', isCritical: false),
      ChecklistItemData(id: 6, section: '1. Sistema Eléctrico y Luces', label: 'Luces de freno, reversa e intermitentes de emergencia', isCritical: true),
      ChecklistItemData(id: 13, section: '1. Sistema Eléctrico y Luces', label: 'Linterna y advertencia acústica de patio', isCritical: false),

      // 2. Frenos y Dirección (Checklist items 5)
      ChecklistItemData(id: 5, section: '2. Frenos y Dirección', label: 'Sistema de Frenos y Presión Neumática de Aire', isCritical: true),
      ChecklistItemData(id: 5, section: '2. Frenos y Dirección', label: 'Freno de mano / estacionamiento (Retención en pendiente)', isCritical: true),
      ChecklistItemData(id: 12, section: '2. Frenos y Dirección', label: 'Escáner y terminales de diagnóstico de dirección', isCritical: false),

      // 3. Fluidos y Motor (Checklist items 4)
      ChecklistItemData(id: 4, section: '3. Niveles de Fluidos', label: 'Nivel de Aceite de Motor y ausencia de fugas activas', isCritical: true),
      ChecklistItemData(id: 4, section: '3. Niveles de Fluidos', label: 'Líquido de frenos y refrigerante / Coolant en radiador', isCritical: true),

      // 4. Neumáticos y Equipamiento (Checklist items 10, 14)
      ChecklistItemData(id: 14, section: '4. Neumáticos y Carrocería', label: 'Medidor de presión y profundidad de banda de rodadura (>3mm)', isCritical: true),
      ChecklistItemData(id: 10, section: '4. Neumáticos y Carrocería', label: 'Extintor PQS 6kg (Manómetro en verde y precinto)', isCritical: true),
      ChecklistItemData(id: 9, section: '4. Neumáticos y Carrocería', label: 'Triángulos de seguridad y conos reflectivos reglamentarios', isCritical: false),
    ];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _hasCriticalFail => _items.any((i) => i.status == ItemCheckStatus.fail && i.isCritical);
  int get _failedCount => _items.where((i) => i.status == ItemCheckStatus.fail).length;
  int get _passCount => _items.where((i) => i.status == ItemCheckStatus.pass).length;

  @override
  Widget build(BuildContext context) {
    // Group by section
    final sections = <String, List<ChecklistItemData>>{};
    for (var item in _items) {
      sections.putIfAbsent(item.section, () => []).add(item);
    }

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
              'Inspección Pre-Uso de Seguridad',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              'Checklist Diario • ${widget.plateNumber}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle Info Card
            _buildVehicleCard(),
            const SizedBox(height: 14),

            // Critical Failure Warning Banner
            if (_hasCriticalFail) ...[
              _buildCriticalWarningBanner(),
              const SizedBox(height: 14),
            ],

            // Quick Stats Row
            _buildSummaryRow(),
            const SizedBox(height: 16),

            // Dynamic Sections
            for (var entry in sections.entries) ...[
              _buildSectionCard(entry.key, entry.value),
              const SizedBox(height: 16),
            ],

            // General Observations
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OBSERVACIONES GENERALES DE SALIDA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Detalles adicionales sobre ruidos, carrocería o estado de la unidad...',
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitInspection,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              label: Text(
                _isSubmitting
                    ? 'Guardando en Base de Datos PostgreSQL...'
                    : (_hasCriticalFail ? 'Registrar Inspección y Bloquear Unidad' : 'Registrar Inspección Conforme'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasCriticalFail ? AppColors.error : AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.checklist_rounded, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.plateNumber,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.vehicleModel,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Odómetro: 128,450 km • Base Norte • Bahía 4',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_rounded, color: AppColors.error, size: 28),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BLOQUEO PREVENTIVO ACTIVADO',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.error),
                ),
                SizedBox(height: 2),
                Text(
                  'Se han detectado fallos críticos de seguridad. Al registrar este checklist, el vehículo pasará de inmediato a estado IN_MAINTENANCE en la base de datos central.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF991B1B), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$_passCount Conformes',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.successText),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: _failedCount > 0 ? AppColors.errorLight : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _failedCount > 0 ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _failedCount > 0 ? AppColors.error : AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_failedCount Con Falla',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _failedCount > 0 ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String sectionTitle, List<ChecklistItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const Divider(height: 20, color: AppColors.border),
            itemBuilder: (ctx, i) => _buildChecklistItem(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItemData item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (item.isCritical) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Crítico',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // 3-state buttons
        Row(
          children: [
            _buildStateButton(
              item,
              ItemCheckStatus.pass,
              'CONFORME',
              AppColors.success,
              AppColors.successLight,
            ),
            const SizedBox(width: 8),
            _buildStateButton(
              item,
              ItemCheckStatus.fail,
              'DEFECTO',
              AppColors.error,
              AppColors.errorLight,
            ),
            const SizedBox(width: 8),
            _buildStateButton(
              item,
              ItemCheckStatus.na,
              'N/A',
              AppColors.textSecondary,
              AppColors.surfaceVariant,
            ),
          ],
        ),
        // Defect notes input when status == fail
        if (item.status == ItemCheckStatus.fail) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => item.comments = val,
                  decoration: InputDecoration(
                    hintText: 'Describa la falla detectada...',
                    hintStyle: const TextStyle(fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📷 Evidencia fotográfica de la avería capturada.'),
                      duration: Duration(milliseconds: 900),
                    ),
                  );
                },
                icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primaryDark),
                tooltip: 'Adjuntar foto del fallo',
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStateButton(
    ChecklistItemData item,
    ItemCheckStatus status,
    String label,
    Color activeColor,
    Color activeBg,
  ) {
    final isSelected = item.status == status;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            item.status = status;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitInspection() async {
    setState(() => _isSubmitting = true);

    // Prepare payload matching Laravel API
    final answersPayload = _items.map((item) {
      String statusStr;
      switch (item.status) {
        case ItemCheckStatus.pass:
          statusStr = 'pass';
          break;
        case ItemCheckStatus.fail:
          statusStr = 'fail';
          break;
        case ItemCheckStatus.na:
          statusStr = 'na';
          break;
      }
      return {
        'checklist_item_id': item.id,
        'status': statusStr,
        'notes': item.comments?.trim(),
      };
    }).toList();

    final repo = ref.read(inspectionRepositoryProvider);
    final result = await repo.submitInspection(
      vehicleId: 3, // ABC-123 in PostgreSQL
      checklistTemplateId: 1, // Routine check template in PostgreSQL
      shift: 'morning',
      startMileage: 128450,
      fuelLevel: '4/4',
      yardLocation: 'Base Central - Bahía 4',
      generalNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      answers: answersPayload,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _hasCriticalFail ? Icons.warning_amber_rounded : Icons.verified_rounded,
              color: _hasCriticalFail ? AppColors.error : AppColors.success,
              size: 28,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _hasCriticalFail ? 'Bloqueo Preventivo en BD' : 'Inspección Registrada en BD',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hasCriticalFail
                  ? 'La unidad ABC-123 ha sido actualizada a estado IN_MAINTENANCE en la base de datos PostgreSQL. Se crearon ${result.defectsCreated} órdenes de defecto para taller.'
                  : 'Inspección guardada exitosamente en PostgreSQL (ID #${result.inspectionId}). La unidad ABC-123 permanece ACTIVA.',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _hasCriticalFail ? AppColors.errorLight : AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasCriticalFail ? AppColors.error.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.storage_rounded,
                    size: 18,
                    color: _hasCriticalFail ? AppColors.error : AppColors.successText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PostgreSQL 14 • Tabla "inspections" #${result.inspectionId}\nEstado Vehículo: ${result.vehicleStatus?.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _hasCriticalFail ? AppColors.error : AppColors.successText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasCriticalFail ? AppColors.error : AppColors.primaryDark,
            ),
            child: const Text('Aceptar y Finalizar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
