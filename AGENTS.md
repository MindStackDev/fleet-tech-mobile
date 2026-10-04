# FleetTech Mobile - Directivas de Arquitectura y Rendimiento para Agentes

## 1. 🛡️ Protocolo de Seguridad Git (ESTRICTO)
- **PROHIBIDO EJECUTAR `git push` SIN AUTORIZACIÓN EXPRESA DEL USUARIO EN EL CHAT.**
- Todos los commits, ramas de prueba y modificaciones se mantienen estrictamente en el entorno local.
- Solo se ejecuta `git push origin <branch>` cuando el usuario lo solicite explícitamente con confirmación textual.

---

## 2. ⚡ Guardarraíles de Rendimiento Obligatorios (Anti-Lag & 60/120 FPS)
1. **Lienzo de Firmas Aislado:**
   - Todo componente de captura de firmas (`Signature` / `CustomPainter`) **DEBE** estar envuelto en un `RepaintBoundary`.
   - Prohibido reconstruir la pantalla de inspección durante los trazos táctiles.
2. **Virtualización de Listas:**
   - Prohibido usar `SingleChildScrollView + Column` para listas dinámicas o de tamaño variable. Usar exclusivamente `ListView.builder` o `SliverList.builder` con `prototypeItem` o `itemExtent` siempre que sea posible.
3. **Cálculos Pesados Fuera del Hilo Principal:**
   - La deserialización de JSON masivos, cifrado y transformaciones de bytes deben delegarse a `Isolate.run()` o `compute()`.
4. **Manejo de Imágenes en Memoria:**
   - Toda imagen cargada desde la red o desde disco debe especificar `memCacheWidth` y `memCacheHeight` (máx. 1080p).
   - Comprimir toda fotografía con `flutter_image_compress` antes de encolarla o persistirla.
5. **Reconstrucción Mínima de Widgets:**
   - Usar `ref.watch(provider.select((s) => s.property))` para suscripciones atómicas.
   - Declarar como `const` todos los constructores y widgets estáticos posibles.

---

## 3. 🏛️ Estándares de Código y Arquitectura
- **Clean Architecture:** Estricta separación entre `presentation`, `domain` y `data`.
- **Inmutabilidad:** Usar `freezed` para todas las entidades y estados complejos.
- **Tipado Fuerte:** Prohibido el uso de tipos `dynamic` sin cast o validación previa.
- **Formato Estándar:** Ejecutar `dart format .` y asegurar `flutter analyze` con cero errores y advertencias antes de concluir cualquier tarea.
