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

# Tecnología de persistencia elegida

## Diseño de la base de datos

Para esta práctica utilizaré SQLite como base de datos local,
junto con Drift y drift_flutter para manejar la persistencia
desde Flutter.

Elegí estas herramientas porque permiten guardar la información
sin conexión a internet y utilizar una misma implementación
para Android, Windows y web.

### Tabla: tareas

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | INTEGER | Identificador único y autoincremental |
| titulo | TEXT | Título de la tarea, obligatorio |
| completada | INTEGER | Estado: 0 = pendiente, 1 = completada |

Cada tarea tendrá un identificador único. Cuando se agregue
una nueva tarea, su estado inicial será pendiente.

La base de datos será la encargada de conservar la información,
mientras que la interfaz mostrará los registros consultados.

### Plataformas seleccionadas

Se trabajará con las plataformas Android, Windows y web


## Tarea por realizar

- Persistencia SQLite real en Android, iOS, Windows, Linux, macOS y web.
- Agregar, listar, editar título, marcar completada y eliminar tareas.
- Comprobar que la información persiste después de cerrar/abrir la app y, en web, después de recargar/cerrar la pestaña en un mismo origen y perfil.
- Investigar Drift + drift_flutter para compartir una sola base de código entre plataformas.
- Investigar cómo agregar `sqlite3.wasm` y `drift_worker.dart.js` en `web/` para que la base funcione en el navegador.
- Añadir pruebas significativas y documentar las plataformas verificadas.

Consulta la consigna PDF/LaTeX: contiene pasos de investigación, criterios, evidencias y rúbrica.

## Etapa 2. Persistencia local con SQLite

Se configuró la persistencia de tareas con SQLite, Drift y drift_flutter. La base de datos se encuentra definida en `lib/data/app_database.dart` y utiliza una tabla llamada `tareas`, con los campos `id`, `titulo` y `completada`.

En esta etapa se implementaron las operaciones para agregar y consultar tareas. La interfaz utiliza funciones asíncronas para guardar los registros y actualizar la lista después de cada inserción. Para Flutter Web se agregaron los archivos `sqlite3.wasm` y `drift_worker.dart.js` dentro de la carpeta `web/`.


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
