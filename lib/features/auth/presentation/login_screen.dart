import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'carlos.mendoza@gltracker.com');
  final _passwordController = TextEditingController(text: '••••••••••••');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await ref.read(authProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
      _rememberMe,
    );
    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleBiometric() async {
    final success = await ref.read(authProvider.notifier).loginBiometric();
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Logo & Brand Header
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.gps_fixed_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GL TRACKER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gestión de Flotas e Instalaciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Pill Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: AppColors.primaryDark,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Portal de Técnicos y Operaciones',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Form Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.border, width: 1.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Correo o Usuario Corporativo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 20),
                                hintText: 'usuario@empresa.com',
                                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Contraseña',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                hintText: 'Ingresa tu clave',
                                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Remember Me Checkbox
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.primaryDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _rememberMe = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Recordar usuario en este dispositivo',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Iniciar Sesión -> Button
                            ElevatedButton(
                              onPressed: authState.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 18),
                            // Biometric Button
                            OutlinedButton.icon(
                              onPressed: authState.isLoading ? null : _handleBiometric,
                              icon: const Icon(
                                Icons.fingerprint_rounded,
                                color: AppColors.primaryDark,
                                size: 22,
                              ),
                              label: const Text(
                                'Ingreso con Biometría (Huella / Face ID)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryLight, width: 1.2),
                                backgroundColor: AppColors.primarySoft.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer Help Text
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '¿Problemas de acceso? Contactar a Mesa de Ayuda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'GL Tracker v4.2 • Enterprise Field Edition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
