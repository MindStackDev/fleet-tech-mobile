import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

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

class PreUseInspectionScreen extends StatefulWidget {
  final String plateNumber;
  final String vehicleModel;

  const PreUseInspectionScreen({
    super.key,
    this.plateNumber = 'ABC-123',
    this.vehicleModel = 'Toyota Hilux 4x4 (2023)',
  });

  @override
  State<PreUseInspectionScreen> createState() => _PreUseInspectionScreenState();
}

class _PreUseInspectionScreenState extends State<PreUseInspectionScreen> {
  late List<ChecklistItemData> _items;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = [
      // 1. Luces y Eléctrico
      ChecklistItemData(id: 1, section: '1. Sistema Eléctrico y Luces', label: 'Faros delanteros (Altas / Bajas) y neblineros', isCritical: false),
      ChecklistItemData(id: 2, section: '1. Sistema Eléctrico y Luces', label: 'Luces de freno, reversa e intermitentes de emergencia', isCritical: true),
      ChecklistItemData(id: 3, section: '1. Sistema Eléctrico y Luces', label: 'Bocina / Claxon de advertencia acústica', isCritical: false),

      // 2. Frenos y Dirección
      ChecklistItemData(id: 4, section: '2. Frenos y Dirección', label: 'Freno de servicio (Pedal firme sin esponjosidad)', isCritical: true),
      ChecklistItemData(id: 5, section: '2. Frenos y Dirección', label: 'Freno de mano / estacionamiento (Retención en pendiente)', isCritical: true),
      ChecklistItemData(id: 6, section: '2. Frenos y Dirección', label: 'Juego libre del volante y terminales de dirección', isCritical: false),

      // 3. Fluidos y Motor
      ChecklistItemData(id: 7, section: '3. Niveles de Fluidos', label: 'Nivel de aceite de motor (Varilla entre MIN y MAX)', isCritical: true),
      ChecklistItemData(id: 8, section: '3. Niveles de Fluidos', label: 'Líquido de frenos y embrague (Sin fugas activas)', isCritical: true),
      ChecklistItemData(id: 9, section: '3. Niveles de Fluidos', label: 'Líquido refrigerante / Coolant en radiador y depósito', isCritical: false),

      // 4. Neumáticos
      ChecklistItemData(id: 10, section: '4. Neumáticos y Carrocería', label: 'Presión y profundidad de banda de rodadura (>3mm)', isCritical: true),
      ChecklistItemData(id: 11, section: '4. Neumáticos y Carrocería', label: 'Espejos retrovisores y lunas sin rajaduras', isCritical: false),
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
            // Vehicle Info Header
            _buildVehicleCard(),
            const SizedBox(height: 14),

            // Critical Alert Banner (if any fail is critical)
            if (_hasCriticalFail) ...[
              _buildCriticalWarningBanner(),
              const SizedBox(height: 14),
            ],

            // Score Counter Card
            _buildSummaryRow(),
            const SizedBox(height: 16),

            // Sections
            ...sections.entries.map((entry) => _buildSectionGroup(entry.key, entry.value)),

            const SizedBox(height: 16),
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
                    'Observaciones Generales de Patio',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
              onPressed: _submitInspection,
              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              label: Text(
                _hasCriticalFail ? 'Registrar Inspección y Bloquear Unidad' : 'Registrar Inspección Conforme',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_problem_rounded, color: AppColors.error, size: 24),
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
                  'Se han detectado fallos críticos de seguridad. Al registrar este checklist, el vehículo pasará de inmediato a estado IN_MAINTENANCE en la central.',
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
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.successText, size: 18),
                const SizedBox(width: 8),
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
              border: Border.all(color: _failedCount > 0 ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: _failedCount > 0 ? AppColors.error : AppColors.textMuted, size: 18),
                const SizedBox(width: 8),
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

  Widget _buildSectionGroup(String sectionTitle, List<ChecklistItemData> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Text(
              sectionTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          ...items.map((item) => _buildItemTile(item)),
        ],
      ),
    );
  }

  Widget _buildItemTile(ChecklistItemData item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
              if (item.isCritical)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Crítico', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // 3-State Buttons Row
          Row(
            children: [
              _buildStateButton(item, ItemCheckStatus.pass, 'CONFORME', AppColors.success, AppColors.successLight),
              const SizedBox(width: 8),
              _buildStateButton(item, ItemCheckStatus.fail, 'DEFECTO', AppColors.error, AppColors.errorLight),
              const SizedBox(width: 8),
              _buildStateButton(item, ItemCheckStatus.na, 'N/A', AppColors.textSecondary, AppColors.surfaceVariant),
            ],
          ),
          if (item.status == ItemCheckStatus.fail) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => item.comments = val,
                    decoration: InputDecoration(
                      hintText: 'Describa la falla detectada...',
                      hintStyle: const TextStyle(fontSize: 11),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📷 Foto de evidencia de falla adjuntada.'),
                        duration: Duration(seconds: 1),
                        backgroundColor: AppColors.primaryDark,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_a_photo_outlined, size: 20, color: AppColors.error),
                  tooltip: 'Adjuntar foto',
                ),
              ],
            ),
          ],
        ],
      ),
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

  void _submitInspection() {
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
            Text(
              _hasCriticalFail ? 'Bloqueo Preventivo' : 'Inspección Aprobada',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hasCriticalFail
                  ? 'La unidad ABC-123 no está en condiciones de operar debido a fallas críticas en los frenos/fluidos. Pasará a estado IN_MAINTENANCE en la central.'
                  : 'Todos los puntos de seguridad han sido auditados satisfactoriamente. La unidad queda en servicio.',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Datos encolados en Drift SQLite para sincronización con fleet-tech-api.',
                style: TextStyle(fontSize: 11, color: AppColors.primaryDark),
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
