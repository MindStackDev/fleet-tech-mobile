# FleetTech Mobile - Directivas de Arquitectura y Rendimiento para Agentes

## 1. 🛡️ Protocolo de Seguridad Git (ESTRICTO)
- **PROHIBIDO EJECUTAR `git push` SIN AUTORIZACIÓN EXPRESA DEL USUARIO EN EL CHAT.**
- Todo commit, widget, pantalla y cambio se mantiene estrictamente en local.
- Solo se ejecuta `git push origin <branch>` cuando el usuario lo solicite explícitamente con confirmación textual.

---

## 2. 📱 Arquitectura Flutter (Feature-First Clean Architecture)
1. **Separación por Features:** `features/auth/`, `features/yard/`, `features/inspection/`, `features/vehicle/`.
2. **Capas por Feature:** 
   - `data/`: datasources (Drift SQLite local, Dio remoto), DTOs y modelos.
   - `domain/`: entidades, contratos de repositorio y casos de uso.
   - `presentation/`: pantallas, widgets reutilizables y controladores de estado con Riverpod.
3. **Núcleo Compartido en `core/`:** 
   - `network/`: Cliente Dio + interceptores Bearer Token Sanctum.
   - `storage/`: FlutterSecureStorage para tokens y credenciales.
   - `database/`: Base de datos Drift (SQLite) para catálogo offline y cola de sincronización.
   - `theme/`: Alto contraste y visibilidad adaptada a luz solar directa en patio.
   - `utils/`: Compresor de imágenes (máx 1280x720 WebP/JPEG al 75%), formateadores y firmas.

---

## 3. ⚡ Guardarraíles de Rendimiento Obligatorios (Anti-Lag & 60/120 FPS en Patio)
1. **Lienzo de Firmas Aislado:**
   - Todo componente de captura de firmas (`Signature` / `CustomPainter`) **DEBE** estar envuelto en un `RepaintBoundary`.
   - Prohibido reconstruir la pantalla de inspección durante los trazos táctiles.
   - Capturar firma del operador saliente y del entrante en lienzos separados con exportación a PNG transparente.
2. **Virtualización de Listas:**
   - Prohibido usar `SingleChildScrollView + Column` para listas dinámicas o de tamaño variable. Usar exclusivamente `ListView.builder` o `SliverList.builder` con `prototypeItem` o `itemExtent`.
3. **Cálculos Pesados Fuera del Hilo Principal:**
   - La deserialización de JSON masivos, cifrado y transformaciones de bytes deben delegarse a `Isolate.run()` o `compute()`.
4. **Manejo de Imágenes en Memoria:**
   - Toda imagen cargada desde la red o disco debe especificar `memCacheWidth` y `memCacheHeight`.
   - Comprimir toda fotografía antes de encolarla en SQLite o enviarla por red débil (3G/WiFi de patio).
5. **Reconstrucción Mínima de Widgets:**
   - Usar `ref.watch(provider.select((s) => s.property))` para suscripciones atómicas en Riverpod.
   - Declarar como `const` todos los constructores y widgets inmutables.

---

## 4. 🏛️ Estándares de Código y Calidad
- **Inmutabilidad:** Usar modelos inmutables para todas las entidades y estados.
- **Tipado Fuerte:** Prohibido el uso de tipos `dynamic` sin cast o validación previa.
- **Formato y Análisis:** Ejecutar `dart format .` y asegurar `flutter analyze` con cero errores y advertencias antes de concluir cualquier tarea.
