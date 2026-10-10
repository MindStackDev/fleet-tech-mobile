import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key});

  void _copyVin(BuildContext context, String vin) {
    Clipboard.setData(ClipboardData(text: vin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('VIN $vin copiado al portapapeles'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GESTIÓN DE FLOTA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Ficha de Vehículo',
              style: TextStyle(
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
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 3.5,
                  backgroundColor: AppColors.success,
                ),
                SizedBox(width: 5),
                Text(
                  'Activo',
                  style: TextStyle(
                    color: AppColors.successText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
            // Placa Card
            _buildPlateCard(),
            const SizedBox(height: 16),
            // Technical Specs Grid Card
            _buildSpecsCard(context),
            const SizedBox(height: 16),
            // Último Servicio Registrado Card
            _buildLastServiceCard(context),
            const SizedBox(height: 16),
            // Materiales y Accesorios Asignados Card
            _buildAssignedMaterialsCard(),
            const SizedBox(height: 24),
            // Action Buttons
            ElevatedButton.icon(
              onPressed: () => context.push('/yard/handover'),
              icon: const Icon(Icons.assignment_turned_in_rounded, size: 20, color: Colors.white),
              label: const Text(
                'Iniciar Relevo de Turno y Patio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.push('/intervention'),
              icon: const Icon(Icons.build_rounded, size: 18, color: AppColors.primaryDark),
              label: const Text(
                'Ficha de Intervención Técnica',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: AppColors.textPrimary),
              label: const Text(
                'Volver a Escanear',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Simulated Plate Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.textPrimary, width: 2),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'PERÚ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'ABC-123',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Vehicle General Details
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toyota Hilux 4x4',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pick-up Doble Cabina • Blanco',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: AppColors.primaryDark,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsCard(BuildContext context) {
    const vinText = '9AJFT2264P0194821';
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
            'DATOS DEL VEHÍCULO Y CLIENTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          _buildSpecRow(
            icon: Icons.business_outlined,
            label: 'Empresa / Cliente',
            value: 'Transportes y Logística Andina S.A.C.',
            extra: 'RUC 20492817401',
          ),
          const Divider(height: 22, color: AppColors.border),
          _buildSpecRow(
            icon: Icons.calendar_month_outlined,
            label: 'Año y Motorización',
            value: 'Año 2023 • Diésel Turbo Intercooler',
            extra: 'Transmisión Manual 6 Vel.',
          ),
          const Divider(height: 22, color: AppColors.border),
          // VIN Row with copy button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fingerprint_rounded, size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VIN / Chasis',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      vinText,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyVin(context, vinText),
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Copiar', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    required String extra,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 1),
              Text(
                extra,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLastServiceCard(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, size: 16, color: AppColors.primaryDark),
                  SizedBox(width: 6),
                  Text(
                    'ÚLTIMO SERVICIO REGISTRADO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '14 Ene 2025',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Mantenimiento preventivo de sensor de combustible',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Text(
                'Técnico: ',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                'M. Soto',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              SizedBox(width: 14),
              Text(
                'Dispositivo: ',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                'Teltonika FMB920',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Estado Operativo OK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successText,
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: const Text(
                  'Ver detalles >',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedMaterialsCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MATERIALES Y ACCESORIOS ASIGNADOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3 Ítems',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMaterialItem(
            tag: 'ARNÉS',
            tagColor: const Color(0xFF6366F1),
            title: 'Arnés OBD2 Hilux',
            subtitle: 'Conector rápido T2 plug & play',
          ),
          const Divider(height: 18, color: AppColors.border),
          _buildMaterialItem(
            tag: 'CORTE',
            tagColor: const Color(0xFFEA580C),
            title: 'Relé corta-corriente',
            subtitle: '12V 40A protegido contra picos',
          ),
          const Divider(height: 18, color: AppColors.border),
          _buildMaterialItem(
            tag: 'SENSOR',
            tagColor: const Color(0xFF0D9488),
            title: 'Sensor BLE combustible',
            subtitle: 'Escort TD-BLE digital con calibración',
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem({
    required String tag,
    required Color tagColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: tagColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: tagColor,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_rounded, color: AppColors.success, size: 18),
      ],
    );
  }
}
