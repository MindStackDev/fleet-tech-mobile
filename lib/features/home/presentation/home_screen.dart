import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentNavIndex = 0;
  bool _isFlashlightOn = false;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _showManualInputDialog() {
    final plateController = TextEditingController(text: 'ABC-123');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ingreso Manual de Placa', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingrese la placa del vehículo para cargar la ficha técnica:'),
            const SizedBox(height: 12),
            TextField(
              controller: plateController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Ej. ABC-123',
                prefixIcon: Icon(Icons.directions_car_filled_rounded),
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
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/vehicle');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 44),
            ),
            child: const Text('Buscar Ficha'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting Card
                    _buildGreetingCard(),
                    const SizedBox(height: 14),
                    // Stats Row
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    // Scanner Card
                    _buildScannerCard(context),
                    const SizedBox(height: 14),
                    // Main CTA Button
                    ElevatedButton.icon(
                      onPressed: () => context.push('/vehicle'),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 22, color: Colors.white),
                      label: const Text(
                        'Escanear Código QR',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Secondary Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showManualInputDialog,
                            icon: const Icon(Icons.keyboard_outlined, size: 18, color: AppColors.textPrimary),
                            label: const Text(
                              'Ingreso manual',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isFlashlightOn = !_isFlashlightOn;
                              });
                            },
                            icon: Icon(
                              _isFlashlightOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                              size: 18,
                              color: _isFlashlightOn ? Colors.amber[700] : AppColors.textPrimary,
                            ),
                            label: Text(
                              _isFlashlightOn ? 'Linterna (ON)' : 'Linterna',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isFlashlightOn ? Colors.amber[800] : AppColors.textPrimary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status Footer
                    _buildStatusFooter(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo & Name
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.gps_fixed_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPERACIONES DE CAMPO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'GL Tracker Enterprise',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Online Badge
          Container(
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
          const SizedBox(width: 10),
          // Avatar CM
          InkWell(
            onTap: () => context.go('/login'),
            borderRadius: BorderRadius.circular(20),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primarySoft,
              child: Text(
                'CM',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TÉCNICO INSTALADOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      'Bogotá (UTC-5)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Hola, Carlos Mendoza',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildPill(
                icon: Icons.check_circle_outline_rounded,
                text: 'En Turno',
                color: AppColors.primaryDark,
                bgColor: AppColors.primarySoft,
              ),
              _buildPill(
                icon: Icons.location_on_outlined,
                text: 'Base Norte • Bahía 4',
                color: AppColors.textSecondary,
                bgColor: AppColors.surfaceVariant,
              ),
              _buildPill(
                icon: Icons.calendar_today_outlined,
                text: 'Hoy',
                color: AppColors.textSecondary,
                bgColor: AppColors.surfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // 3 Pendientes hoy
        Expanded(
          child: Container(
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
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: AppColors.warningText,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3 Pendientes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Asignadas hoy',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 1 Completada
        Expanded(
          child: Container(
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
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.successText,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1 Completada',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Intervención cerrada',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerCard(BuildContext context) {
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
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryDark, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Escaneo de Unidad Telemática',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Cámara Activa',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Viewport Frame
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 200,
              color: const Color(0xFF0F172A),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera Simulation / Grid
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: CustomPaint(
                        painter: _GridBackgroundPainter(),
                      ),
                    ),
                  ),
                  // Reticle and Scanner Target Box
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(180, 150),
                          painter: _ScannerReticlePainter(
                            scanProgress: _scanAnimation.value,
                          ),
                        );
                      },
                    ),
                  ),
                  // Center Overlay Instructions
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Alinee el código QR dentro del recuadro',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enfoque el código QR del vehículo o kit telemático',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.satellite_alt_outlined, size: 14, color: AppColors.success),
              SizedBox(width: 6),
              Text(
                'GPS calibrado • Precisión ±1.2m',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            'Versión 4.2',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 1) {
            // Can switch to history view or feedback
          } else if (index == 2) {
            // Can switch to profile
          }
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        elevation: 0,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_filled, color: AppColors.primaryDark),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded, color: AppColors.primaryDark),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryDark),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }
}

class _ScannerReticlePainter extends CustomPainter {
  final double scanProgress;

  _ScannerReticlePainter({required this.scanProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = AppColors.scannerCorner
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 22.0;

    // Top Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), cornerPaint);

    // Top Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), cornerPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), cornerPaint);

    // Bottom Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), cornerPaint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), cornerPaint);

    // Bottom Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), cornerPaint);

    // Scanning animated line
    final scanLineY = size.height * scanProgress;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primaryLight.withValues(alpha: 0.9),
          Colors.white,
          AppColors.primaryLight.withValues(alpha: 0.9),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, scanLineY - 2, size.width, 4))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(4, scanLineY), Offset(size.width - 4, scanLineY), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerReticlePainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress;
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
