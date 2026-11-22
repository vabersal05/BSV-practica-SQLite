import 'dart:async';
import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'screens/tareas_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GestorTareasApp());
}

class GestorTareasApp extends StatefulWidget {
  const GestorTareasApp({super.key, this.database});

  final AppDatabase? database;

  @override
  State<GestorTareasApp> createState() => _GestorTareasAppState();
}

class _GestorTareasAppState extends State<GestorTareasApp> {
  late final AppDatabase _database;
  late final bool _esPropia;

  @override
  void initState() {
    super.initState();

    _esPropia = widget.database == null;
    _database = widget.database ?? AppDatabase(); // crear la instancia de la base de datos si no se proporciona una
  }

  @override
  void dispose() {
    if (_esPropia) {
      unawaited(_database.close()); // cerrar la conexion a la BD
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(database: _database), // compartir la instancia de la base de datos con la pantalla de tareas
    );
  }
}
