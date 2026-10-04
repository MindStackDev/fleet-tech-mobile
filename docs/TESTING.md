# 🧪 Guía de Pruebas y Profiling de Rendimiento - Fleet Tech Mobile

Estrategia de testing automatizado, pruebas en condiciones de red hostiles y benchmarks de tasa de refresco (60 / 120 FPS).

---

## 1. Pruebas Unitarias de Base de Datos Local (Drift)

Las pruebas de base de datos se ejecutan en memoria usando `drift/native.dart`:

```dart
// test/unit/sync_queue_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fleet_tech_mobile/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Debe persistir una inspección y mantener estado pending_upload', () async {
    final entry = await db.syncDao.enqueueInspection(fakePayload);
    final items = await db.syncDao.getPendingItems();

    expect(items.length, 1);
    expect(items.first.id, entry.id);
  });
}
```

---

## 2. Pruebas en Condiciones Hostiles (Edge Cases Offline)

| Escenario | Acción de Prueba | Criterio de Éxito |
| :--- | :--- | :--- |
| **Corte de red a mitad de subida** | Activar modo avión mientras se envían fotos | No crashea; estado pasa a `retry_scheduled` |
| **Batería baja / apagado súbito** | Cerrar forzosamente la app durante la firma | El borrador de la inspección permanece intacto en Drift |
| **Pérdida de señal GPS en patio techado** | Bloquear permisos de GPS o entrar en zona ciega | Utiliza última posición conocida sin bloquear el flujo |

---

## 3. Benchmarks de Presupuesto de Frame y Profiling

Ejecutar la app en modo perfil sobre un dispositivo físico real:

```bash
flutter run --profile
dart run devtools
```

### Criterios de Calidad:
- **UI Thread:** Menor a **8.3ms** continuos durante el trazo de la firma digital.
- **Raster Thread:** Menor a **8.3ms** durante el scroll de listas con más de 60 ítems.
- **Tasa de Cuadros Perdidos (Jank):** Menor al **1.5%** de frames fuera de tiempo.
- **Memoria RAM:** Consumo estable por debajo de **180MB** tras capturar y procesar 15 fotografías consecutivas.
