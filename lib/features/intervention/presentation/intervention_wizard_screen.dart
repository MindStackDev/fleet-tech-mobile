import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class InterventionWizardScreen extends StatefulWidget {
  const InterventionWizardScreen({super.key});

  @override
  State<InterventionWizardScreen> createState() => _InterventionWizardScreenState();
}

class _InterventionWizardScreenState extends State<InterventionWizardScreen> {
  int _selectedJobType = 0; // 0: Instalación, 1: Mantenimiento, 2: Retiro
  bool _isPowerValidated = true;
  final TextEditingController _obsController = TextEditingController();

  final List<String> _quickChips = [
    '+ Empalme soldado',
    '+ Tras panel',
    '+ Voz',
    '+ Botón SOS probado',
  ];

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  void _addQuickChip(String chip) {
    final cleanChip = chip.replaceFirst('+ ', '');
    setState(() {
      if (_obsController.text.isEmpty) {
        _obsController.text = cleanChip;
      } else {
        _obsController.text = '${_obsController.text}, $cleanChip';
      }
    });
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
              'Registro de Intervención',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Orden OT-2024-8931',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
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
                  'En linea',
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
            // Progress Bar Section
            _buildProgressBar(),
            const SizedBox(height: 16),
            // Vehicle Summary Card
            _buildVehicleBanner(),
            const SizedBox(height: 16),
            // Work Type Segmented Selector
            _buildWorkTypeSelector(),
            const SizedBox(height: 20),
            // Devices Section
            _buildDevicesSection(),
            const SizedBox(height: 20),
            // Connection Validation Checkbox
            _buildValidationSection(),
            const SizedBox(height: 20),
            // Observations and Quick Chips
            _buildObservationsSection(),
            const SizedBox(height: 24),
            // Main Submit / Next Button
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paso 2 de 3: Datos de Instalación',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '66% completado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.66,
              minHeight: 7,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
            ),
          ),
        ],
      ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_car_rounded, color: AppColors.primaryDark, size: 20),
              SizedBox(width: 10),
              Text(
                'Toyota Hilux 2023 • Placa ABC-123',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Flota Minera',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTypeSelector() {
    final types = ['Instalación', 'Mantenimiento', 'Retiro'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(types.length, (index) {
          final isSelected = _selectedJobType == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedJobType = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  types[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDevicesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Equipos a Vincular',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '1 de 2 listos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dashed Scan Button
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primaryDark),
            label: const Text(
              'Escanear código de equipo (GPS / Dashcam / Sensores)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryDark, style: BorderStyle.solid, width: 1.2),
              backgroundColor: AppColors.primarySoft.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Device 1: GPS Teltonika (Linked)
          _buildDeviceCard(
            icon: Icons.router_rounded,
            title: 'GPS Teltonika FMB920',
            serial: 'S/N: 9481023912',
            isLinked: true,
            actionIcon: Icons.close_rounded,
            actionTooltip: 'Desvincular',
          ),
          const SizedBox(height: 10),
          // Device 2: Dashcam (Pending)
          _buildDeviceCard(
            icon: Icons.videocam_outlined,
            title: 'Dashcam Dual HD Pro',
            serial: 'S/N: DC-77210',
            isLinked: false,
            actionIcon: Icons.qr_code_scanner_rounded,
            actionTooltip: 'Escanear ahora',
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard({
    required IconData icon,
    required String title,
    required String serial,
    required bool isLinked,
    required IconData actionIcon,
    required String actionTooltip,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 10),
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
                Text(
                  serial,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isLinked ? AppColors.successLight : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isLinked ? 'Vinculado' : 'Pendiente',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isLinked ? AppColors.successText : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(actionIcon, size: 18, color: AppColors.textSecondary),
            tooltip: actionTooltip,
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationSection() {
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
          const Text(
            'Validación Técnica de Conexión',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                _isPowerValidated = !_isPowerValidated;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isPowerValidated,
                  activeColor: AppColors.primaryDark,
                  onChanged: (val) {
                    setState(() {
                      _isPowerValidated = val ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Alimentación eléctrica 12V/24V verificada con multímetro (Línea BAT protegida con fusible) - Comprobación de voltaje en reposo y con arranque de ignición activo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Observaciones Técnicas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              AnimatedBuilder(
                animation: _obsController,
                builder: (context, _) {
                  return Text(
                    '${_obsController.text.length}/250',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _obsController,
            maxLength: 250,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Detalle la ubicación del equipo, tipo de empalmes o anomalías encontradas...',
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          // Quick Chips Row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _quickChips.map((chip) {
              return ActionChip(
                label: Text(
                  chip,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                backgroundColor: AppColors.primarySoft,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _addQuickChip(chip),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => context.push('/intervention/evidence'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continuar a Evidencias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Paso siguiente: Registro fotográfico del tablero y precintos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
