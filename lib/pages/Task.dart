import 'package:flutter/material.dart';
import 'package:flutter_application_1/DataBase/DatabaseHelper.dart';
import 'package:flutter_application_1/pages/TareaPage.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<TaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaLimite;
  int _importancia = 1;
  String? _categoriaSeleccionada;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int idUsuario = 1;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      int idUsuario = await _dbHelper.getIdUsuario();
      await _dbHelper.insertTask(
        _nombreController.text,
        _descripcionController.text,
        _fechaLimite!,
        _importancia,
        _categoriaSeleccionada!,
        idUsuario,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se realizó exitosamente el ingreso de la tarea')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _fechaLimite = null;
        _importancia = 1;
        _categoriaSeleccionada = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Tarea'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriaSelectionPage(idUsuario: idUsuario)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _dbHelper.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay categorías disponibles'));
          } else {
            List<String> categorias = snapshot.data!;
            return Padding(
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
                          initialDate: DateTime.now(),
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
                    DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada,
                      items: categorias.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoriaSeleccionada = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Categoría'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una categoría';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveTask,
                      child: Text('Guardar Tarea'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}