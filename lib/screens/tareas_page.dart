
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/tarea.dart';

// Pantalla base SIN persistencia ni operaciones CRUD implementadas
// Conserva las indicaciones TODO para orientar tu trabajo
class TareasPage extends StatefulWidget {
  const TareasPage({
    super.key,
    required this.database,
  });

  final AppDatabase database;

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController =
      TextEditingController();

  List<Tarea> _tareas = [];

  bool _cargando = true;
  bool _guardando = false;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  // Consultar las tareas guardadas en SQLite
  Future<void> _cargarTareas() async {
    try {
      final registros = await widget.database.obtenerTareas();

      if (!mounted) return;

      setState(() {
        _tareas = registros.map((registro) {
          return Tarea(
            id: registro.id,
            titulo: registro.titulo,
            completada: registro.completada,
          );
        }).toList();

        _cargando = false;
        _errorCarga = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _errorCarga = 'No se pudieron cargar las tareas.';
      });
    }
  }

  // Agregar una nueva tarea a SQLite
  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text.trim();

    // Validar que no esté vacío.
    if (titulo.isEmpty) {
      _mostrarMensaje('Escribe un título para la tarea.');
      return;
    }

    if (_guardando) return;

    setState(() {
      _guardando = true;
    });

    try {
      // INSERT en SQLite
      await widget.database.agregarTarea(titulo);

      if (!mounted) return;

      _tituloController.clear();

      // Consultar nuevamente después de guardar
      await _cargarTareas();

      if (!mounted) return;

      _mostrarMensaje('Tarea guardada correctamente.');
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('Error al guardar la tarea.');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // PENDIENTE
  void _alternarCompletada(Tarea tarea, bool completada) {
    _pendiente('Implementar actualización de tarea');
  }

  // PENDIENTE
  void _editarTarea(Tarea tarea) {
    _pendiente('Implementar edición de título');
  }

  // PENDIENTE
  void _eliminarTarea(Tarea tarea) {
    _pendiente('Implementar eliminación de tarea');
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _pendiente(String mensaje) {
    _mostrarMensaje(mensaje);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de tareas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: _guardando ? null : _agregarTarea,
              icon: const Icon(Icons.add),
              label: Text(
                _guardando ? 'Guardando...' : 'Agregar tarea',
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Mis tareas',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorCarga != null
                      ? Center(
                          child: Text(_errorCarga!),
                        )
                      : _tareas.isEmpty
                          ? const Center(
                              child: Text(
                                'Todavía no hay tareas guardadas',
                              ),
                            )
                          : ListView.builder(
                              itemCount: _tareas.length,
                              itemBuilder: (context, index) {
                                final tarea = _tareas[index];

                                return Card(
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: tarea.completada,
                                      onChanged: (valor) {
                                        if (valor != null) {
                                          _alternarCompletada(
                                            tarea,
                                            valor,
                                          );
                                        }
                                      },
                                    ),

                                    title: Text(tarea.titulo),

                                    subtitle: Text(
                                      'ID: ${tarea.id}',
                                    ),

                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Editar',
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _editarTarea(tarea),
                                        ),

                                        IconButton(
                                          tooltip: 'Eliminar',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () =>
                                              _eliminarTarea(tarea),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
