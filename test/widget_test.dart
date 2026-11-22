
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:gestor_tareas_local/main.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  // Prueba básica de apertura de la aplicación
  testWidgets('Muestra correctamente la pantalla inicial', (tester) async {
    await tester.pumpWidget(
      GestorTareasApp(database: database),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);

    expect(
      find.text('Todavía no hay tareas guardadas'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  // Prueba de interacción con la interfaz y SQLite
  testWidgets('Permite agregar una tarea desde la interfaz', (tester) async {
    await tester.pumpWidget(
      GestorTareasApp(database: database),
    );

    await tester.pumpAndSettle();

    // Escribir el título en el campo de texto
    await tester.enterText(
      find.byType(TextField),
      'Estudiar para el examen',
    );

    // Presionar el botón para agregar
    await tester.tap(find.text('Agregar tarea'));

    await tester.pumpAndSettle();

    // Verificar que la tarea aparece en pantalla
    expect(
      find.text('Estudiar para el examen'),
      findsOneWidget,
    );

    // Comprobar que también se guardo en SQLite
    final tareas = await database.obtenerTareas();

    expect(tareas.length, 1);
    expect(tareas.first.titulo, 'Estudiar para el examen');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
