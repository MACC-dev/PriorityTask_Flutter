import 'package:flutter/material.dart';
import 'package:flutter_application_1/DataBase/DatabaseHelper.dart';
import 'package:flutter_application_1/DataBase/Tarea.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatefulWidget {
  final Tarea tarea;

  TaskDetailPage({required this.tarea});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaLimite;
  int _importancia = 1;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.tarea.nombreTarea;
    _descripcionController.text = widget.tarea.descripcion;
    _fechaLimite = widget.tarea.fechaLimite;
    _importancia = widget.tarea.importancia;
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      Tarea updatedTask = Tarea(
        idTarea: widget.tarea.idTarea,
        nombreTarea: _nombreController.text,
        descripcion: _descripcionController.text,
        fechaLimite: _fechaLimite!,
        importancia: _importancia,
        idCategoria: widget.tarea.idCategoria,
        idUsuario: widget.tarea.idUsuario,
      );
      await _dbHelper.updateTask(updatedTask);
      Navigator.pop(context, true); // Indicate that the task was updated
    }
  }

  Future<void> _deleteTask() async {
    await _dbHelper.deleteTask(widget.tarea.idTarea!);
    Navigator.pop(context, true); // Indicate that the task was deleted
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la Tarea'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la tarea';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  _fechaLimite == null
                      ? 'Seleccione una fecha límite'
                      : 'Fecha Límite: ${DateFormat('yyyy-MM-dd').format(_fechaLimite!)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _fechaLimite ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _fechaLimite = pickedDate;
                    });
                  }
                },
              ),
              DropdownButtonFormField<int>(
                value: _importancia,
                items: List.generate(5, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('Importancia ${index + 1}'),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _importancia = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Importancia'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTask,
                child: Text('Actualizar Tarea'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteTask,
                child: Text('Eliminar Tarea'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
