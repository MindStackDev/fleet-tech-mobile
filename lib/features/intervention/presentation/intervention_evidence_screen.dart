import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class InterventionEvidenceScreen extends StatefulWidget {
  final String orderCode;
  final String plateNumber;

  const InterventionEvidenceScreen({
    super.key,
    this.orderCode = 'OT-2024-8931',
    this.plateNumber = 'ABC-123',
  });

  @override
  State<InterventionEvidenceScreen> createState() => _InterventionEvidenceScreenState();
}

class _InterventionEvidenceScreenState extends State<InterventionEvidenceScreen> {
  // Photo slot states
  final Map<int, bool> _capturedSlots = {
    0: true,  // Tablero terminado (simulada)
    1: true,  // Precinto GPS (simulada)
    2: false, // Antena oculta
    3: false, // Panorámica
  };

  bool _telemetryPlatformVerified = true;
  bool _isSigned = false;

  final List<Map<String, dynamic>> _slots = [
    {
      'title': 'Tablero y Cableado Cerrado',
      'subtitle': 'Sin cables expuestos, relé asegurado',
      'icon': Icons.dashboard_customize_outlined,
      'required': true,
    },
    {
      'title': 'Precinto de Seguridad GPS',
      'subtitle': 'Número de precinto visible y legible',
      'icon': Icons.security_rounded,
      'required': true,
    },
    {
      'title': 'Ubicación y Antena Oculta',
      'subtitle': 'Línea de vista al cielo despejada',
      'icon': Icons.satellite_alt_rounded,
      'required': true,
    },
    {
      'title': 'Panorámica de Cabina',
      'subtitle': 'Estado general de entrega del vehículo',
      'icon': Icons.directions_car_filled_outlined,
      'required': false,
    },
  ];

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
              'Registro de Intervención',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              'Orden ${widget.orderCode}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 3.5, backgroundColor: AppColors.success),
                SizedBox(width: 5),
                Text(
                  'En linea',
                  style: TextStyle(color: AppColors.successText, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar (Paso 3 de 3)
            _buildProgressBar(),
            const SizedBox(height: 16),

            // Vehicle summary card
            _buildVehicleBanner(),
            const SizedBox(height: 16),

            // Photos Grid Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EVIDENCIAS FOTOGRÁFICAS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tome o adjunte las fotos reglamentarias del trabajo',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_capturedSlots.values.where((v) => v).length}/4 Fotos',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4 Photo Slots
            ...List.generate(_slots.length, (index) => _buildPhotoSlotCard(index)),
            const SizedBox(height: 16),

            // Telemetry Verification Switch
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _telemetryPlatformVerified,
                    onChanged: (val) => setState(() => _telemetryPlatformVerified = val ?? false),
                    activeColor: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pruebas de Transmisión en Vivo OK',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'El GPS Teltonika FMB920 está reportando eventos de ignición ON/OFF a la central.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Technician Conformity Signature Pad
            _buildSignatureCard(),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _finishIntervention,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Finalizar y Registrar Intervención',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
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

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paso 3 de 3: Evidencias y Conformidad',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Text(
              '100% completado',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 1.0,
            minHeight: 6,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toyota Hilux 2023 • Placa ${widget.plateNumber}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Transportes y Logística Minera S.A.C.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlotCard(int index) {
    final slot = _slots[index];
    final isCaptured = _capturedSlots[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCaptured ? AppColors.success.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isCaptured ? AppColors.successLight : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCaptured ? Icons.check_circle_rounded : slot['icon'] as IconData,
              color: isCaptured ? AppColors.successText : AppColors.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        slot['title'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    if (slot['required'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Obligatoria', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  slot['subtitle'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _capturedSlots[index] = !isCaptured;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_capturedSlots[index]!
                      ? '📷 Foto de "${slot['title']}" capturada y comprimida a 1080p.'
                      : 'Foto removida.'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
            icon: Icon(
              isCaptured ? Icons.replay_rounded : Icons.camera_alt_rounded,
              color: isCaptured ? AppColors.textSecondary : AppColors.primaryDark,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Firma de Conformidad del Técnico',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () => setState(() => _isSigned = !_isSigned),
                child: Text(
                  _isSigned ? 'Limpiar' : 'Firmar Demo',
                  style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            alignment: Alignment.center,
            child: _isSigned
                ? const Text(
                    '✍️ Carlos Mendoza (Firma Digital Estampada)',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  )
                : const Text(
                    'Toque "Firmar Demo" o dibuje sobre el recuadro',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
          ),
        ],
      ),
    );
  }

  void _finishIntervention() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('¡Intervención Cerrada!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'La orden OT-2024-8931 ha sido completada con 4 evidencias fotográficas y validación técnica de transmisión.',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_done_rounded, color: AppColors.successText, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Encolado en cola Drift SQLite para sincronización con fleet-tech-api.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.successText),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: const Text('Volver al Inicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
