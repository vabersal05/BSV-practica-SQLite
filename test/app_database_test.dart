
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_tareas_local/data/app_database.dart';

void main() {
  late AppDatabase database;

  // Crear una base de datos temporal antes de cada prueba
  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  // Cerrar la base de datos después de cada prueba
  tearDown(() async {
    await database.close();
  });

  // PRUEBA 1: validación de títulos
  test('No permite guardar tareas con títulos vacíos', () async {
    expect(
      () => database.agregarTarea(''),
      throwsArgumentError,
    );

    expect(
      () => database.agregarTarea('   '),
      throwsArgumentError,
    );

    final tareas = await database.obtenerTareas();

    expect(tareas, isEmpty);
  });

  // PRUEBA 2: creación y consulta de tareas
  test('Guarda y consulta las tareas correctamente', () async {
    final id1 = await database.agregarTarea('  Estudiar Flutter  ');
    final id2 = await database.agregarTarea('Hacer práctica SQLite');

    final tareas = await database.obtenerTareas();

    expect(tareas.length, 2);
    expect(id1, isNot(id2));

    expect(tareas[0].titulo, 'Estudiar Flutter');
    expect(tareas[1].titulo, 'Hacer práctica SQLite');

    expect(tareas[0].completada, false);
    expect(tareas[1].completada, false);
  });

  // PRUEBA 3: edición del título
  test('Edita solamente la tarea seleccionada', () async {
    final id1 = await database.agregarTarea('Estudiar');
    final id2 = await database.agregarTarea('Hacer tarea');

    final filas = await database.editarTitulo(
      id1,
      'Estudiar Flutter',
    );

    final tareas = await database.obtenerTareas();

    expect(filas, 1);
    expect(tareas.firstWhere((t) => t.id == id1).titulo,
        'Estudiar Flutter');

    expect(tareas.firstWhere((t) => t.id == id2).titulo,
        'Hacer tarea');

    // También verificamos que no permita editar
    // una tarea con un título vacío
    expect(
      () => database.editarTitulo(id1, '   '),
      throwsArgumentError,
    );
  });

  // PRUEBA 4: cambiar estado y eliminar
  test('Actualiza el estado y elimina tareas por ID', () async {
    final id = await database.agregarTarea('Comprar materiales');

    // Marcar como completada
    final actualizadas = await database.cambiarEstado(id, true);

    var tareas = await database.obtenerTareas();

    expect(actualizadas, 1);
    expect(tareas.single.completada, true);

    // Volver a marcar como pendiente
    await database.cambiarEstado(id, false);

    tareas = await database.obtenerTareas();

    expect(tareas.single.completada, false);

    // Eliminar la tarea
    final eliminadas = await database.eliminarTarea(id);

    tareas = await database.obtenerTareas();

    expect(eliminadas, 1);
    expect(tareas, isEmpty);

    // Si ya no existe, no debe eliminar ningún registro
    final segundoIntento = await database.eliminarTarea(id);

    expect(segundoIntento, 0);
  });
}
