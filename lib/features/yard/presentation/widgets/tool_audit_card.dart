import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/tool_item.dart';

class ToolAuditCard extends StatelessWidget {
  final ToolItem tool;
  final ToolAuditAnswer answer;
  final ValueChanged<InspectionStatus> onStatusChanged;
  final ValueChanged<DefectSeverity> onSeverityChanged;
  final ValueChanged<String> onObservationChanged;
  final VoidCallback onAddPhoto;

  const ToolAuditCard({
    super.key,
    required this.tool,
    required this.answer,
    required this.onStatusChanged,
    required this.onSeverityChanged,
    required this.onObservationChanged,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isFail = answer.status == InspectionStatus.fail;
    final isPass = answer.status == InspectionStatus.pass;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFail
              ? AppColors.error
              : (isPass ? AppColors.success.withValues(alpha: 0.5) : AppColors.border),
          width: isFail ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tool.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (tool.isCritical) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CRÍTICO',
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
                    const SizedBox(height: 2),
                    Text(
                      tool.specification,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Segmented Buttons Pass / Fail / NA
              _buildStatusButtons(),
            ],
          ),
          // Fail expansion section: Severity + Observations + Photo
          if (isFail) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Severidad de la falla / novedad:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: DefectSeverity.values.map((sev) {
                      final isSelected = answer.defectSeverity == sev;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            sev.label.split(' ')[0],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: sev == DefectSeverity.critical
                              ? AppColors.error
                              : AppColors.warning,
                          onSelected: (_) => onSeverityChanged(sev),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: onObservationChanged,
                    decoration: const InputDecoration(
                      hintText: 'Detalle la novedad o daño encontrado...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onAddPhoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: Text(
                      answer.photosBase64.isEmpty
                          ? 'Adjuntar Foto Obligatoria'
                          : 'Foto Adjuntada (${answer.photosBase64.length})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircleButton(
          status: InspectionStatus.pass,
          icon: Icons.check_rounded,
          activeColor: AppColors.success,
        ),
        const SizedBox(width: 6),
        _buildCircleButton(
          status: InspectionStatus.fail,
          icon: Icons.close_rounded,
          activeColor: AppColors.error,
        ),
        const SizedBox(width: 6),
        _buildCircleButton(
          status: InspectionStatus.na,
          icon: Icons.remove_rounded,
          activeColor: AppColors.textMuted,
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required InspectionStatus status,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = answer.status == status;
    return InkWell(
      onTap: () => onStatusChanged(status),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}
