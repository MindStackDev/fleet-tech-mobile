import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HandoverReceiptDialog extends StatelessWidget {
  final String orderCode;
  final String plateNumber;
  final String vehicleModel;
  final String odometer;
  final String fuelLevel;
  final String bayNumber;
  final String outgoingOperator;
  final String incomingOperator;
  final String verificationHash;
  final bool hasDefects;

  const HandoverReceiptDialog({
    super.key,
    required this.orderCode,
    required this.plateNumber,
    required this.vehicleModel,
    required this.odometer,
    required this.fuelLevel,
    required this.bayNumber,
    required this.outgoingOperator,
    required this.incomingOperator,
    required this.verificationHash,
    required this.hasDefects,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon and Title
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: hasDefects ? AppColors.warningLight : AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasDefects ? Icons.warning_amber_rounded : Icons.verified_rounded,
                    color: hasDefects ? AppColors.warningText : AppColors.successText,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  hasDefects ? 'Relevo con Observaciones' : 'Acta de Relevo Certificada',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Código de Auditoría: $orderCode',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Vehicle & Shift Info Table
              _buildDataRow('Unidad Vehicular', '$plateNumber ($vehicleModel)'),
              const SizedBox(height: 8),
              _buildDataRow('Odómetro Registrado', '$odometer km'),
              const SizedBox(height: 8),
              _buildDataRow('Nivel de Combustible', fuelLevel),
              const SizedBox(height: 8),
              _buildDataRow('Bahía de Patio', bayNumber),
              const SizedBox(height: 8),
              _buildDataRow('Operador Saliente', outgoingOperator),
              const SizedBox(height: 8),
              _buildDataRow('Operador Entrante', incomingOperator),
              const SizedBox(height: 8),
              _buildDataRow(
                'Estado Operativo',
                hasDefects ? 'BLOQUEO PREVENTIVO' : 'CONFORME (En Servicio)',
                valueColor: hasDefects ? AppColors.error : AppColors.successText,
              ),

              const SizedBox(height: 14),
              // Cryptographic Hash Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text(
                          'Sello de No Repudio (SHA-256)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      verificationHash,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Actions
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/home');
                },
                icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Entendido, Finalizar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
