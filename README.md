# Práctica - Gestor de tareas SQLite multiplataforma

**Código base deliberadamente incompleto.** Su objetivo es ofrecer una pantalla Flutter que se pueda ejecutar desde el primer momento; **NO implementa SQLite, CRUD ni persistencia**.

## Preparación

1. Instala Flutter y comprueba `flutter doctor -v`.
2. Crea un proyecto nuevo **con este nombre**, para que coincida el `package:` usado en la prueba inicial:

   ```bash
   flutter create gestor_tareas_local
   cd gestor_tareas_local
   ```

3. Copia al proyecto generado las carpetas `lib/` y `test/` de esta base. No sobrescribas las carpetas `android/`, `ios/`, `web/`, `windows/`, `linux/` ni `macos/` generadas por Flutter.
4. Ejecuta:

   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter run -d chrome
   ```

   Sustituye `chrome` por otro identificador de `flutter devices` si lo necesitas.

## Tarea por realizar

- Persistencia SQLite real en Android, iOS, Windows, Linux, macOS y web.
- Agregar, listar, editar título, marcar completada y eliminar tareas.
- Comprobar que la información persiste después de cerrar/abrir la app y, en web, después de recargar/cerrar la pestaña en un mismo origen y perfil.
- Investigar Drift + drift_flutter para compartir una sola base de código entre plataformas.
- Investigar cómo agregar `sqlite3.wasm` y `drift_worker.dart.js` en `web/` para que la base funcione en el navegador.
- Añadir pruebas significativas y documentar las plataformas verificadas.

Consulta la consigna PDF/LaTeX: contiene pasos de investigación, criterios, evidencias y rúbrica.

## Notas

- **No uses una base MySQL ni API REST:** esta práctica es de almacenamiento **local**.
- **No se acepta una lista solo en memoria** ni guardar la lista como JSON en `shared_preferences` en lugar de SQLite.
- Los datos de cada instalación/plataforma son propios; no se exige sincronización entre dispositivos.
- iOS y macOS requieren una Mac para compilarse/probarse; Windows requiere Windows para compilarse y Linux, Linux. La compatibilidad del código sí debe contemplar las seis plataformas.

### Referencias recomendadas

- https://drift.simonbinder.eu/
- https://drift.simonbinder.eu/platforms/web/
- https://pub.dev/packages/drift_flutter
- https://docs.flutter.dev/data-and-backend/persistence/sqlite
