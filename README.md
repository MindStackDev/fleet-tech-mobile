# 📱 Fleet Tech Mobile (Flutter)

Aplicación móvil empresarial de alto rendimiento diseñada para operadores de patio, técnicos de campo y supervisores de taller. Permite la ejecución de inspecciones de pre-uso, relevo de turno con doble firma digital, auditoría de hardware telemático y registro fotográfico de defectos, funcionando con soporte total **Offline-First** y sincronización asíncrona hacia [`fleet-tech-api`](../fleet-tech-api).

---

## 📑 Tabla de Contenidos

- [📱 Fleet Tech Mobile (Flutter)](#-fleet-tech-mobile-flutter)
  - [📑 Tabla de Contenidos](#-tabla-de-contenidos)
  - [🌟 Rol en el Ecosistema FleetTech](#-rol-en-el-ecosistema-fleettech)
  - [🛠️ Stack Tecnológico](#️-stack-tecnológico)
  - [🏛️ Arquitectura de Software (Clean Architecture)](#️-arquitectura-de-software-clean-architecture)
    - [📂 Estructura de Directorios (`lib/`)](#-estructura-de-directorios-lib)
  - [⚡ Pautas de Rendimiento \& Renderizado Anti-Lag (60 / 120 FPS)](#-pautas-de-rendimiento--renderizado-anti-lag-60--120-fps)
    - [1. Presupuesto de Frame y Tasa de Refresco](#1-presupuesto-de-frame-y-tasa-de-refresco)
    - [2. Aislamiento de Repintado (`RepaintBoundary`) en Lienzo de Firmas](#2-aislamiento-de-repintado-repaintboundary-en-lienzo-de-firmas)
    - [3. Renderizado Virtualizado de Checklists Dinámicos](#3-renderizado-virtualizado-de-checklists-dinámicos)
    - [4. Descarga de Computación Pesada en Background Isolates](#4-descarga-de-computación-pesada-en-background-isolates)
    - [5. Pipeline de Optimización y Compresión de Evidencias Fotográficas](#5-pipeline-de-optimización-y-compresión-de-evidencias-fotográficas)
    - [6. Prevención de Rebuilds Innecesarios en el Árbol de Widgets](#6-prevención-de-rebuilds-innecesarios-en-el-árbol-de-widgets)
    - [7. Motor Offline-First \& Sincronización sin Bloqueo de UI](#7-motor-offline-first--sincronización-sin-bloqueo-de-ui)
  - [🎯 Matriz de Skills \& Competencias del Ingeniero Mobile](#-matriz-de-skills--competencias-del-ingeniero-mobile)
  - [🔌 Integración y Contratos con `fleet-tech-api`](#-integración-y-contratos-con-fleet-tech-api)
    - [Flujo de Autenticación Sanctum](#flujo-de-autenticación-sanctum)
    - [Contrato de Envío de Inspección y Checklists](#contrato-de-envío-de-inspección-y-checklists)
  - [🚀 Puesta en Marcha y Ejecución Local](#-puesta-en-marcha-y-ejecución-local)
  - [🧪 Monitoreo y Profiling de Rendimiento](#-monitoreo-y-profiling-de-rendimiento)

---

## 🌟 Rol en el Ecosistema FleetTech

En operaciones de patio y talleres mecánicos, las condiciones de conectividad son erráticas y la velocidad de respuesta es crítica. `fleet-tech-mobile` resuelve los siguientes flujos de negocio:

1. **Relevo de Turno Operativo:** Captura de odómetro inicial/final, nivel de combustible en octavos, bahía asignada y verificación de geolocalización GPS.
2. **Doble Firma Digital Vinculante:** Captura vectorial fluida de la firma del operador saliente y del operador entrante sobre la misma pantalla sin congelamiento ni saltos de trazo.
3. **Custodia de Herramientas y Deslinde:** Checklists dinámicos organizados por secciones para validar el estado de las herramientas asignadas al vehículo; cualquier faltante o daño registra automáticamente un defecto.
4. **Inspección Pre-Uso y Bloqueo Preventivo:** Registro de fallas críticas (`critical`) que activan el pase inmediato del vehículo al estado `in_maintenance` en la API central.
5. **Captura Fotográfica de Evidencia:** Procesamiento, compresión y adjunto de imágenes de daños o precintos sin saturar la memoria RAM del dispositivo ni causar pausas de Garbage Collection (GC).

---

## 🛠️ Stack Tecnológico

| Capa / Componente | Tecnología | Propósito |
| :--- | :--- | :--- |
| **Framework Base** | Flutter 3.24+ / Dart 3.5+ | Compilación AOT nativa (ARM64) para Android e iOS |
| **Gestión de Estado** | Flutter Riverpod 2.5+ (Code Generation) | Inyección de dependencias reactiva, selectores atómicos y aislamiento de estado |
| **Arquitectura** | Clean Architecture + Feature-First | Desacoplamiento estricto entre UI, Casos de Uso y Fuentes de Datos |
| **Persistencia Local** | Drift (SQLite) / Hive CE | Almacenamiento tipado, relacional, offline-first y reactivo |
| **Cliente HTTP** | Dio 5.x | Interceptores de autenticación Bearer, reintentos y subida de archivos multipart |
| **Compresión Multimedia** | `flutter_image_compress` | Reducción de imágenes a 1080p WebP/JPEG 80% en hilos secundarios |
| **Canvas & Firmas** | `signature` / `CustomPainter` nativo | Captura de vectores bajo `RepaintBoundary` sin latencia |
| **Tareas en Segundo Plano**| `workmanager` / `background_fetch` | Cola de sincronización periódica de inspecciones pendientes |
| **Serialización** | `freezed` + `json_serializable` | Inmutabilidad y deserialización segura |

---

## 🏛️ Arquitectura de Software (Clean Architecture)

El proyecto implementa una arquitectura por capas modularizada por características (**Feature-First Clean Architecture**), garantizando que la lógica de negocio y los casos de uso sean totalmente independientes del framework y de los servicios de red.

```mermaid
graph TD
    subgraph Presentation_Layer ["Presentation Layer (Flutter)"]
        UI[Views & Widgets] -->|Observa con select| Controller[Riverpod Notifiers]
    end

    subgraph Domain_Layer ["Domain Layer (Dart Puro)"]
        Controller -->|Invoca| UseCase[Use Cases / Actions]
        UseCase -->|Utiliza| DomainEntities[Entities & Enums]
        UseCase -->|Define| RepoInterface[Repository Interfaces]
    end

    subgraph Data_Layer ["Data Layer (Infraestructura)"]
        RepoImpl[Repository Implementations] -.->|Implementa| RepoInterface
        RepoImpl -->|Lee/Escribe| LocalDS[Local Data Source (Drift SQLite)]
        RepoImpl -->|Sincroniza| RemoteDS[Remote Data Source (Dio API)]
        RemoteDS -->|HTTP/REST| API[fleet-tech-api]
    end
```

### 📂 Estructura de Directorios (`lib/`)

```text
lib/
├── app/
│   ├── app.dart                                # MaterialApp con configuración de temas y rutas
│   ├── config/                                 # Entornos (env.dev.dart, env.prod.dart)
│   ├── router/                                 # GoRouter con guardias de autenticación
│   └── theme/                                  # Tokens de diseño, tipografías y paletas
│
├── core/
│   ├── constants/                              # StorageKeys, ApiEndpoints
│   ├── errors/                                 # Failure classes, AppException
│   ├── network/                                # DioClient, AuthInterceptor, RetryInterceptor
│   ├── storage/                                # SecureStorage (tokens), CacheManager
│   └── utils/                                  # Isolates helpers, formatters, image utilities
│
├── features/
│   ├── auth/                                   # Login, perfil, sesión local
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── fleet/                                  # Listado de vehículos, escaneo de placa/QR
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── inspections/                            # Relevo de turno, inspección de patio
│   │   ├── data/                               # Local/Remote DataSources, Drift tables
│   │   ├── domain/                             # SubmitInspectionUseCase, InspectionEntity
│   │   └── presentation/                       # InspectionWizardScreen, DualSignatureWidget
│   │
│   ├── checklists/                             # Renderizador de plantillas dinámicas
│   │   ├── data/
│   │   ├── domain/                             # ChecklistTemplate, Section, Item
│   │   └── presentation/                       # ChecklistItemsList, DynamicFieldItem
│   │
│   ├── defects/                                # Reporte y triage de defectos
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── sync/                                   # Motor de cola y sincronización en segundo plano
│       ├── data/                               # SyncQueueDao, NetworkObserver
│       ├── domain/                             # ProcessSyncQueueUseCase
│       └── presentation/                       # SyncStatusBar, OfflineIndicator
│
└── main.dart                                   # Inicialización de servicios y arranque
```

---

## ⚡ Pautas de Rendimiento & Renderizado Anti-Lag (60 / 120 FPS)

Para garantizar una experiencia instantánea y sin tartamudeo (*jank* o *stutter*) en terminales móviles de gama media y baja utilizados por los técnicos en talleres, es mandatario cumplir las siguientes 7 reglas arquitectónicas:

### 1. Presupuesto de Frame y Tasa de Refresco

- **Tasa de Refresco Objetivo:** 60 FPS (pantallas estándar) y 120 FPS (pantallas ProMotion / AMOLED de alta tasa).
- **Presupuesto por Frame:**
  - A 60 FPS: **16.6 milisegundos**.
  - A 120 FPS: **8.3 milisegundos**.
- **Regla Estricta:** Ningún cálculo en el hilo de UI (UI Isolate) debe superar los **8 milisegundos**. Todo cómputo prolongado debe ser delegado a un Isolate secundario mediante `compute()` o `Isolate.run()`.

---

### 2. Aislamiento de Repintado (`RepaintBoundary`) en Lienzo de Firmas

La captura de firmas del operador saliente y entrante requiere pintar trazos vectoriales a más de 60 eventos por segundo. Si el lienzo comparte la capa de renderizado con el resto del formulario, **toda la pantalla se repintará en cada milímetro de trazo**, provocando congelamiento total.

#### Solución Mandatoria:
1. Envolver el widget de firma en un `RepaintBoundary` para crear una `RenderRepaintBoundary` con su propia capa gráfica (RenderLayer).
2. Mantener las coordenadas de trazo en listas ligeras de tipo `Float32List` o estructuras planas de puntos sin instanciar objetos pesados por cada evento táctil.

```dart
// lib/features/inspections/presentation/widgets/dual_signature_pad.dart
class DualSignaturePad extends StatelessWidget {
  final SignatureController controller;
  final String signerRole; // 'Operador Saliente' | 'Operador Entrante'

  const DualSignaturePad({
    super.key,
    required this.controller,
    required this.signerRole,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(signerRole, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // RepaintBoundary aísla los repintados continuos del canvas
          // impidiendo que la pantalla completa de la inspección sufra jank.
          child: RepaintBoundary(
            child: Signature(
              controller: controller,
              height: 180,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### 3. Renderizado Virtualizado de Checklists Dinámicos

Las plantillas de inspección vehiculares pueden contener más de 60 ítems (revisión de neumáticos, luces, frenos, fluidos, herramientas de auxilio, botiquín).
- ❌ **Prohibido:** Renderizar ítems usando `Column(children: list.map(...))` dentro de un `SingleChildScrollView`. Esto infla decenas de widgets simultáneamente en memoria y bloquea la creación del frame inicial.
- ✅ **Mandatorio:** Emplear `ListView.builder` o `CustomScrollView` con `SliverList.builder`. Definir `prototypeItem` o `itemExtent` siempre que la altura sea predecible para omitir el cálculo de geometría en cada frame de desplazamiento.

```dart
// lib/features/checklists/presentation/widgets/checklist_items_list.dart
class ChecklistItemsList extends StatelessWidget {
  final List<ChecklistItemEntity> items;

  const ChecklistItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Renderiza estrictamente los elementos visibles en el viewport actual
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      // prototypeItem optimiza el cálculo del layout al evitar mediciones dinámicas costosas
      prototypeItem: const ChecklistItemTilePlaceholder(),
      itemBuilder: (context, index) {
        return ChecklistItemTile(
          key: ValueKey(items[index].id),
          item: items[index],
        );
      },
    );
  }
}
```

---

### 4. Descarga de Computación Pesada en Background Isolates

La deserialización de payloads JSON de gran tamaño (plantillas de inspección completas con preguntas condicionales e historiales de defectos) no debe ejecutarse en el hilo principal de renderizado.

```dart
// lib/core/utils/isolate_json_parser.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

Future<T> parseJsonInIsolate<T>(
  String jsonString,
  T Function(Map<String, dynamic>) fromJson,
) async {
  // Isolate.run ejecuta el cómputo en un hilo nativo independiente
  return Isolate.run(() {
    final Map<String, dynamic> decoded = json.decode(jsonString);
    return fromJson(decoded);
  });
}
```

---

### 5. Pipeline de Optimización y Compresión de Evidencias Fotográficas

Las fotos capturadas con cámaras de smartphones modernos superan los 12 megapíxeles (entre 4MB y 15MB cada una). Cargar estas imágenes completas en el heap de Flutter produce **Out Of Memory (OOM)** y bloqueos severos del recolector de basura (GC pauses de >100ms).

#### Reglas de Compresión y Caché:
1. **Compresión Pre-Upload:** Toda fotografía debe redimensionarse a una resolución máxima de **1920x1080 píxeles** con compresión JPEG al 80% o WebP en un Isolate antes de almacenarse en la base de datos local Drift o enviarse a `fleet-tech-api`.
2. **Dimensionamiento de Caché en Memoria:** Al renderizar miniaturas de evidencia en pantalla, especificar obligatoriamente `memCacheWidth` y `memCacheHeight` en `ResizeImage` o `CachedNetworkImage`.

```dart
// lib/core/utils/image_optimizer.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageOptimizer {
  static Future<File?> compressEvidencePhoto(File file) async {
    final targetPath = '${file.parent.path}/comp_${file.uri.pathSegments.last}';
    
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
      keepExif: false, // Descarta metadatos pesados innecesarios
    );

    return result != null ? File(result.path) : null;
  }
}
```

---

### 6. Prevención de Rebuilds Innecesarios en el Árbol de Widgets

- **Selectores Atómicos:** Utilizar `ref.watch(provider.select((state) => state.propiedadEspecifica))` para evitar reconstruir pantallas enteras cuando solo cambia un estado menor (ej: el odómetro o la carga de la batería).
- **Constructores `const`:** Usar `const` de manera estricta en todo widget estático para permitir que Flutter reutilice los elementos sin instanciar nuevos objetos en el árbol de renderizado.
- **Desacople de Formularios:** No usar `setState()` en el widget raíz para almacenar entradas de texto. Emplear controladores de texto locales con listeners aislados o proveedores de campo atómico.

```dart
// Correcto: Solo se reconstruye el indicador cuando cambia específicamente el estado de sincronización
final isSyncing = ref.watch(syncControllerProvider.select((s) => s.isSyncing));
```

---

### 7. Motor Offline-First & Sincronización sin Bloqueo de UI

1. Toda inspección, firma y fotografía se guarda de manera inmediata en la base de datos local SQLite (**Drift**) con estado `status = 'pending_upload'`.
2. La interfaz de usuario confirma la finalización de manera instantánea (Optimistic UI) sin hacer esperar al operario por la respuesta de red.
3. Un servicio en segundo plano (`SyncQueueWorker`) procesa los registros de la cola enviándolos a `fleet-tech-api` con reintentos exponenciales cuando se detecta conexión celular o Wi-Fi.

---

## 🎯 Matriz de Skills & Competencias del Ingeniero Mobile

Para garantizar el cumplimiento de los estándares de arquitectura y rendimiento, el equipo de desarrollo y los agentes que intervengan en este repositorio deben dominar:

| Dimensión | Competencia Requerida | Aplicación en `fleet-tech-mobile` |
| :--- | :--- | :--- |
| **Arquitectura Flutter** | Clean Architecture, Inversión de Dependencias | Separación estricta entre Data, Domain y Presentation; aislamiento de lógica mediante casos de uso |
| **Gestión de Estado** | Riverpod 2.x con Notifiers tipados | `AsyncNotifier`, selectores atómicos con `select`, control de ciclo de vida (`autoDispose`) |
| **Profiling & Anti-Lag** | Flutter DevTools (CPU Profiler, Memory Leak Detection) | Detección de jank, inspección de capas de repintado, análisis de tiempos de raster y frame budget |
| **Persistencia & Offline** | Drift (SQLite relacional) & Migraciones Seguras | Tablas con claves foráneas, DAOs optimizados con índices en `vehicle_id` y `sync_status` |
| **Manejo de Hardware** | Integración nativa de Cámara, GPS y Canvas | Configuración adecuada de precisión de GPS, compresión de fotos antes de escribir a disco |
| **Consumo de APIs REST** | Dio con Interceptores y Refresh Token | Manejo de encabezados `Authorization: Bearer <token>`, reintentos idempotentes y multipart/form-data |

---

## 🔌 Integración y Contratos con `fleet-tech-api`

### Flujo de Autenticación Sanctum

1. **Login:** `POST /api/v1/auth/login` con credenciales de operador.
2. **Respuesta:**
   ```json
   {
     "success": true,
     "message": "Autenticación exitosa",
     "data": {
       "user": {
         "id": 4,
         "name": "Carlos Méndez",
         "role": "technician"
       },
       "token": "1|qX8y9K0Z..."
     }
   }
   ```
3. El token se almacena de forma cifrada en **Flutter Secure Storage** (Keystore en Android / Keychain en iOS).

### Contrato de Envío de Inspección y Checklists

- **Endpoint:** `POST /api/v1/inspections`
- **Encabezados:** `Authorization: Bearer <token>`, `Accept: application/json`
- **Payload Multipart / JSON:**
  ```json
  {
    "vehicle_id": 12,
    "inspection_type": "pre_use",
    "shift_type": "morning",
    "odometer": 84520.5,
    "fuel_level": "6/8",
    "bay_number": "BAHIA-04",
    "latitude": -12.046374,
    "longitude": -77.042793,
    "outgoing_operator_signature": "data:image/png;base64,iVBORw0KGgo...",
    "incoming_operator_signature": "data:image/png;base64,iVBORw0KGgo...",
    "answers": [
      {
        "template_item_id": 101,
        "status": "pass",
        "value": "Sin fugas detectadas"
      },
      {
        "template_item_id": 102,
        "status": "fail",
        "value": "Extintor descargado o ausente",
        "defect_severity": "critical",
        "comments": "Venció el mes pasado"
      }
    ]
  }
  ```

---

## 🚀 Puesta en Marcha y Ejecución Local

### Prerrequisitos
- Flutter SDK `>= 3.24.0`
- Dart SDK `>= 3.5.0`
- Android Studio / Xcode configurados con emuladores o dispositivos físicos
- Backend [`fleet-tech-api`](../fleet-tech-api) corriendo en red local

### Pasos de Instalación
```bash
# 1. Obtener dependencias
flutter pub get

# 2. Generar código tipado (Freezed, Riverpod, Drift)
dart run build_runner build --delete-conflicting-outputs

# 3. Copiar archivo de entorno y configurar la URL del backend
cp .env.example .env

# 4. Ejecutar en modo desarrollo
flutter run --flavor dev -t lib/main.dart
```

---

## 🧪 Monitoreo y Profiling de Rendimiento

Para validar que la aplicación cumple con las pautas de fluidez y ausencia de lag, ejecutar el perfilador de Flutter:

```bash
# Ejecutar en modo Profile en un dispositivo físico real
flutter run --profile

# Abrir DevTools en el navegador
dart run devtools
```

### Métricas de Aceptación:
- **Raster Thread:** Menos de 8ms por frame durante el desplazamiento rápido del checklist.
- **UI Thread:** Menos de 8ms continuos durante el trazo de la firma digital.
- **Uso de Memoria Heap:** Máximo 180MB tras capturar y procesar 15 fotografías de evidencia en una misma sesión de inspección.
- **Zero Memory Leaks:** Comprobar que al cerrar la pantalla de firma o checklist no queden controladores ni listeners activos.
