import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fleet_tech_mobile/main.dart';
import 'package:fleet_tech_mobile/features/home/presentation/home_screen.dart';
import 'package:fleet_tech_mobile/features/vehicle/presentation/vehicle_detail_screen.dart';
import 'package:fleet_tech_mobile/features/intervention/presentation/intervention_wizard_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App smoke test - loads LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FleetTechApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GL TRACKER'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Ingreso con Biometría (Huella / Face ID)'), findsOneWidget);
  });

  testWidgets('HomeScreen renders dashboard elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('GL Tracker Enterprise'), findsOneWidget);
    expect(find.text('Hola, Carlos Mendoza'), findsOneWidget);
    expect(find.text('3 Pendientes'), findsOneWidget);
    expect(find.text('1 Completada'), findsOneWidget);
    expect(find.text('Escanear Código QR'), findsOneWidget);
  });

  testWidgets('VehicleDetailScreen renders vehicle specs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: VehicleDetailScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ABC-123'), findsOneWidget);
    expect(find.text('Toyota Hilux 4x4'), findsOneWidget);
    expect(find.text('Iniciar Intervención Técnica'), findsOneWidget);
    expect(find.text('3 Ítems'), findsOneWidget);
  });

  testWidgets('InterventionWizardScreen renders step 2 wizard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: InterventionWizardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Registro de Intervención'), findsOneWidget);
    expect(find.text('Paso 2 de 3: Datos de Instalación'), findsOneWidget);
    expect(find.text('Instalación'), findsOneWidget);
    expect(find.text('Continuar a Evidencias'), findsOneWidget);
  });
}
