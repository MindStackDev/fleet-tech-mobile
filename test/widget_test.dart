import 'package:fleet_tech_mobile/features/inspection/presentation/pre_use_inspection_screen.dart';
import 'package:fleet_tech_mobile/features/intervention/presentation/intervention_evidence_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fleet_tech_mobile/main.dart';
import 'package:fleet_tech_mobile/features/home/presentation/home_screen.dart';
import 'package:fleet_tech_mobile/features/vehicle/presentation/vehicle_detail_screen.dart';
import 'package:fleet_tech_mobile/features/intervention/presentation/intervention_wizard_screen.dart';
import 'package:fleet_tech_mobile/features/yard/presentation/shift_handover_screen.dart';
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

  testWidgets('VehicleDetailScreen renders vehicle specs and handover CTA', (WidgetTester tester) async {
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
    expect(find.text('Iniciar Relevo de Turno y Patio'), findsOneWidget);
    expect(find.text('Ficha de Intervención Técnica'), findsOneWidget);
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

  testWidgets('ShiftHandoverScreen renders operational fields, tools audit and dual signatures', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShiftHandoverScreen(plateNumber: 'ABC-123', vehicleId: 105),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verification of operational parameters
    expect(find.text('RELEVO DE TURNO & PATIO'), findsOneWidget);
    expect(find.text('Unidad ABC-123'), findsOneWidget);
    expect(find.text('PARÁMETROS OPERATIVOS DE RELEVO'), findsOneWidget);
    expect(find.text('Mañana'), findsOneWidget);
    expect(find.text('Tarde'), findsOneWidget);
    expect(find.text('Noche'), findsOneWidget);

    // Verification of tool audit section
    expect(find.text('CUSTODIA DE KIT DE HERRAMIENTAS'), findsOneWidget);
    expect(find.text('Extintor PQS 6kg (Vigencia & Presión)'), findsOneWidget);
    expect(find.text('Gata Hidráulica de Botella 20T'), findsOneWidget);

    // Verification of signatures
    expect(find.text('DESLINDE LEGAL Y DOBLE FIRMA DIGITAL'), findsOneWidget);
    expect(find.text('Firma de Entrega'), findsOneWidget);
    expect(find.text('Firma de Recepción y Conformidad'), findsOneWidget);
    expect(find.text('Registrar Relevo y Custodia'), findsOneWidget);
  });

  testWidgets('PreUseInspectionScreen renders daily safety checklist items and state buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PreUseInspectionScreen(plateNumber: 'ABC-123'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inspección Pre-Uso de Seguridad'), findsOneWidget);
    expect(find.text('Checklist Diario • ABC-123'), findsOneWidget);
    expect(find.text('2. Frenos y Dirección'), findsOneWidget);
    expect(find.text('Registrar Inspección Conforme'), findsOneWidget);
  });

  testWidgets('InterventionEvidenceScreen renders step 3 photo slots and seals', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: InterventionEvidenceScreen(orderCode: 'OT-2024-8931', plateNumber: 'ABC-123'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Registro de Intervención'), findsOneWidget);
    expect(find.text('Orden OT-2024-8931'), findsOneWidget);
    expect(find.text('Paso 3 de 3: Evidencias y Conformidad'), findsOneWidget);
    expect(find.text('EVIDENCIAS FOTOGRÁFICAS'), findsOneWidget);
    expect(find.text('Precinto de Seguridad GPS'), findsWidgets);
    expect(find.text('Finalizar y Registrar Intervención'), findsOneWidget);
  });
}
