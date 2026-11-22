
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
  bool _ocupado = false;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  // Consultar las tareas almacenadas en SQLite.
  Future<bool> _cargarTareas() async {
    try {
      final registros = await widget.database.obtenerTareas();

      if (!mounted) return false;

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

      return true;
    } catch (e) {
      debugPrint('Error al consultar tareas: $e');

      if (!mounted) return false;

      setState(() {
        _cargando = false;
        _errorCarga = 'No se pudieron cargar las tareas.';
      });

      return false;
    }
  }

  // Mostrar mensajes al usuario.
  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
  }

  // CREATE: agregar una tarea.
  Future<void> _agregarTarea() async {
    if (_ocupado) return;

    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      _mostrarMensaje('Escribe un título para la tarea.');
      return;
    }

    setState(() {
      _ocupado = true;
    });

    try {
      await widget.database.agregarTarea(titulo);

      if (!mounted) return;

      _tituloController.clear();

      final actualizada = await _cargarTareas();

      if (!mounted) return;

      _mostrarMensaje(
        actualizada
            ? 'Tarea guardada correctamente.'
            : 'Se guardó, pero no se pudo actualizar la lista.',
      );
    } catch (e) {
      debugPrint('Error al agregar tarea: $e');
      _mostrarMensaje('No se pudo guardar la tarea.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // Ejecutar cambios y volver a consultar SQLite.
  Future<void> _ejecutarCambio(
    Future<int> Function() operacion,
    String mensajeExito,
  ) async {
    if (_ocupado) return;

    setState(() {
      _ocupado = true;
    });

    try {
      final filas = await operacion();

      if (!mounted) return;

      if (filas == 0) {
        _mostrarMensaje('La tarea ya no existe.');
        await _cargarTareas();
        return;
      }

      final actualizada = await _cargarTareas();

      if (!mounted) return;

      _mostrarMensaje(
        actualizada
            ? mensajeExito
            : 'El cambio se guardó, pero no se pudo actualizar la lista.',
      );
    } catch (e) {
      debugPrint('Error al modificar tarea: $e');
      _mostrarMensaje('No se pudo completar la operación.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // UPDATE: marcar completada o pendiente.
  Future<void> _alternarCompletada(
    Tarea tarea,
    bool completada,
  ) async {
    await _ejecutarCambio(
      () => widget.database.cambiarEstado(
        tarea.id,
        completada,
      ),
      completada
          ? 'Tarea marcada como completada.'
          : 'Tarea marcada como pendiente.',
    );
  }

  // UPDATE: editar el título de una tarea.
  Future<void> _editarTarea(Tarea tarea) async {
    if (_ocupado) return;

    String nuevoTitulo = tarea.titulo;
    bool mostrarError = false;

    final resultado = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            return AlertDialog(
              title: const Text('Editar tarea'),
              content: TextFormField(
                initialValue: tarea.titulo,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Título de la tarea',
                  border: const OutlineInputBorder(),
                  errorText: mostrarError
                      ? 'El título no puede estar vacío.'
                      : null,
                ),
                onChanged: (valor) {
                  nuevoTitulo = valor;

                  if (mostrarError &&
                      valor.trim().isNotEmpty) {
                    actualizarDialogo(() {
                      mostrarError = false;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final titulo = nuevoTitulo.trim();

                    if (titulo.isEmpty) {
                      actualizarDialogo(() {
                        mostrarError = true;
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, titulo);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || resultado == null) return;

    if (resultado == tarea.titulo) return;

    await _ejecutarCambio(
      () => widget.database.editarTitulo(
        tarea.id,
        resultado,
      ),
      'Título actualizado correctamente.',
    );
  }

  // DELETE: eliminar una tarea con confirmación.
  Future<void> _eliminarTarea(Tarea tarea) async {
    if (_ocupado) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar tarea'),
          content: Text(
            '¿Seguro que deseas eliminar "${tarea.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    await _ejecutarCambio(
      () => widget.database.eliminarTarea(tarea.id),
      'Tarea eliminada correctamente.',
    );
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
              enabled: !_ocupado && !_cargando,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                _agregarTarea();
              },
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: _ocupado || _cargando
                  ? null
                  : _agregarTarea,
              icon: const Icon(Icons.add),
              label: Text(
                _ocupado
                    ? 'Procesando...'
                    : 'Agregar tarea',
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_errorCarga!),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () {
                                  _cargarTareas();
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
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
                                      onChanged: _ocupado
                                          ? null
                                          : (valor) {
                                              if (valor != null) {
                                                _alternarCompletada(
                                                  tarea,
                                                  valor,
                                                );
                                              }
                                            },
                                    ),

                                    title: Text(
                                      tarea.titulo,
                                      style: TextStyle(
                                        decoration: tarea.completada
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),

                                    subtitle: Text(
                                      'ID: ${tarea.id} - '
                                      '${tarea.completada ? "Completada" : "Pendiente"}',
                                    ),

                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Editar',
                                          icon: const Icon(Icons.edit),
                                          onPressed: _ocupado
                                              ? null
                                              : () => _editarTarea(tarea),
                                        ),
                                        IconButton(
                                          tooltip: 'Eliminar',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: _ocupado
                                              ? null
                                              : () => _eliminarTarea(tarea),
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
