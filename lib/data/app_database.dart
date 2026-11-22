
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Tabla para las tareas
@DataClassName('TareaRegistro')
class Tareas extends Table {
  @override
  String get tableName => 'tareas';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get titulo => text()();

  BoolColumn get completada =>
      boolean().withDefault(const Constant(false))();
}

// Clase principal para manejar la base SQLite
@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'gestor_tareas',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.dart.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 1;

  // INSERT: guardar una tarea nueva
  Future<int> agregarTarea(String titulo) {
    final tituloLimpio = titulo.trim();

    if (tituloLimpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío.');
    }

    return into(tareas).insert(
      TareasCompanion.insert(titulo: tituloLimpio),
    );
  }

  // SELECT: consultar las tareas guardadas ordenadas por ID
  Future<List<TareaRegistro>> obtenerTareas() {
    return (select(tareas)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }
}
