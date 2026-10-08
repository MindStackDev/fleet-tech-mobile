# 02. Especificación Técnica y Arquitectura Mobile (Flutter)

Este documento define los estándares de arquitectura limpia, gestión de estado, compresión de fotos, captura de firmas, rendimiento y modo offline para la aplicación móvil **FleetTech Mobile** desarrollada en Flutter 3.47+.

---

## 📱 1. Arquitectura de Software Mobile (Feature-First Clean Architecture)

Para garantizar un código desacoplado y fácil de mantener, la app se estructura por funcionalidades (**Feature-First**):

```text
lib/
├── core/                                    # Núcleo transversal
│   ├── network/                             # Cliente Dio con interceptor para Token Sanctum
│   ├── storage/                             # Almacenamiento seguro local (flutter_secure_storage / Hive)
│   ├── theme/                               # Paleta de colores de alto contraste para patio
│   ├── utils/                               # Compresor de imágenes, formateadores de fecha/placa
│   └── errors/                              # Manejo de fallos de red y excepciones
│
├── features/                                # Módulos de la aplicación
│   ├── auth/                                # Autenticación de Operadores
│   │   ├── data/ (datasources, models)
│   │   ├── domain/ (entities, repositories)
│   │   └── presentation/ (login screen, controllers/cubits)
│   │
│   ├── yard/                                # Búsqueda y Selección de Unidades en Patio
│   │   ├── data/ (vehicle_api, vehicle_model)
│   │   ├── domain/ (vehicle_entity)
│   │   └── presentation/ (vehicle_list_screen, vehicle_detail_screen)
│   │
│   └── inspection/                          # Llenado de Checklist & Relevo de Turno
│       ├── data/ (inspection_api, offline_queue)
│       ├── domain/ (checklist_entity, inspection_entity)
│       └── presentation/
│           ├── screens/ (checklist_form_screen, review_summary_screen)
│           └── widgets/ (item_row, camera_capture_modal, dual_signature_pad)
│
└── main.dart                                # Punto de entrada de la aplicación
```

---

## ⚡ 2. Rendimiento y Optimización para Dispositivos de Campo

Los operadores de patio suelen utilizar teléfonos o tablets empresariales en condiciones de calor, baja conectividad y luz solar directa:

1. **Compresión Automática de Evidencias Fotográficas:**
   * La cámara captura a resolución completa (ej. 12-48 MP).
   * Antes de almacenar en cola o subir a la API, la app redimensiona la imagen a un máximo de **1280x720 px** con calidad JPEG al **75%** (`flutter_image_compress`).
   * Reduce el tamaño de 8-15 MB a menos de **300 KB** por foto, permitiendo subidas instantáneas incluso con red móvil 3G o WiFi débil de patio.

2. **Doble Lienzo de Firma Digital Táctil:**
   * Dos lienzos separados e independientes:
     * Lienzo A: Firma del Operador Saliente (Entrega).
     * Lienzo B: Firma del Operador Entrante (Recepción de conformidad).
   * Exportación automática a PNG transparente optimizado para adjuntar al JSON o subir al servidor.

3. **Modo Offline y Cola de Reintentos:**
   * Si el operador se encuentra en una zona muerta del patio (detrás de contenedores o hangares metálicos), la inspección completa, sus respuestas y las fotos se guardan localmente en la cola de SQLite / Hive.
   * Un servicio en segundo plano detecta la reconexión a Internet y procesa la sincronización automática sin pérdida de datos.

4. **Diseño de Interfaz de Alto Contraste para Luz Solar:**
   * Componentes grandes y botones táctiles accesibles con guantes de trabajo.
   * Indicadores de estado con semáforos claros:
     * 🟢 **Verde (`pass`):** Herramienta / componente operativo.
     * 🔴 **Rojo (`fail`):** Herramienta faltante / componente averiado (exige foto obligatoria).
     * ⚪ **Gris (`na`):** No aplica para este modelo de unidad.
