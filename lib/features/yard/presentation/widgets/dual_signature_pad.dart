import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../../core/theme/app_colors.dart';

class DualSignaturePad extends StatefulWidget {
  final String outgoingOperatorName;
  final String incomingOperatorName;
  final ValueChanged<Uint8List?> onOutgoingSigned;
  final ValueChanged<Uint8List?> onIncomingSigned;

  const DualSignaturePad({
    super.key,
    required this.outgoingOperatorName,
    required this.incomingOperatorName,
    required this.onOutgoingSigned,
    required this.onIncomingSigned,
  });

  @override
  State<DualSignaturePad> createState() => _DualSignaturePadState();
}

class _DualSignaturePadState extends State<DualSignaturePad> {
  late final SignatureController _outgoingController;
  late final SignatureController _incomingController;

  bool _isOutgoingSigned = false;
  bool _isIncomingSigned = false;

  @override
  void initState() {
    super.initState();
    _outgoingController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );
    _incomingController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    _outgoingController.addListener(_handleOutgoingChange);
    _incomingController.addListener(_handleIncomingChange);
  }

  void _handleOutgoingChange() async {
    final isNotEmpty = _outgoingController.isNotEmpty;
    if (isNotEmpty != _isOutgoingSigned) {
      setState(() => _isOutgoingSigned = isNotEmpty);
      if (isNotEmpty) {
        final bytes = await _outgoingController.toPngBytes();
        widget.onOutgoingSigned(bytes);
      } else {
        widget.onOutgoingSigned(null);
      }
    }
  }

  void _handleIncomingChange() async {
    final isNotEmpty = _incomingController.isNotEmpty;
    if (isNotEmpty != _isIncomingSigned) {
      setState(() => _isIncomingSigned = isNotEmpty);
      if (isNotEmpty) {
        final bytes = await _incomingController.toPngBytes();
        widget.onIncomingSigned(bytes);
      } else {
        widget.onIncomingSigned(null);
      }
    }
  }

  @override
  void dispose() {
    _outgoingController.removeListener(_handleOutgoingChange);
    _incomingController.removeListener(_handleIncomingChange);
    _outgoingController.dispose();
    _incomingController.dispose();
    super.dispose();
  }

  Widget _buildPad({
    required String title,
    required String operatorName,
    required String roleBadge,
    required SignatureController controller,
    required bool isSigned,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSigned ? AppColors.success : AppColors.border,
          width: isSigned ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          roleBadge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Operador: $operatorName',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textMuted),
                tooltip: 'Limpiar firma',
                onPressed: () {
                  controller.clear();
                  onClear();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Isolated RepaintBoundary per performance guidelines
          RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 120,
                color: Colors.white,
                child: Stack(
                  children: [
                    if (!isSigned)
                      const Center(
                        child: Text(
                          'Firme con el dedo dentro del recuadro',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    Signature(
                      controller: controller,
                      height: 120,
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPad(
          title: 'Firma de Entrega',
          operatorName: widget.outgoingOperatorName,
          roleBadge: 'SALIENTE',
          controller: _outgoingController,
          isSigned: _isOutgoingSigned,
          onClear: () => widget.onOutgoingSigned(null),
        ),
        const SizedBox(height: 14),
        _buildPad(
          title: 'Firma de Recepción y Conformidad',
          operatorName: widget.incomingOperatorName,
          roleBadge: 'ENTRANTE',
          controller: _incomingController,
          isSigned: _isIncomingSigned,
          onClear: () => widget.onIncomingSigned(null),
        ),
      ],
    );
  }
}
