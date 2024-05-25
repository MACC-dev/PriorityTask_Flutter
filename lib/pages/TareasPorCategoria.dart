import 'package:flutter/material.dart';
import 'package:flutter_application_1/DataBase/DatabaseHelper.dart';
import 'package:flutter_application_1/DataBase/Tarea.dart';
import 'package:flutter_application_1/pages/DetallesTareas.dart';
import 'package:intl/intl.dart';

class TareasPorCategoriaPage extends StatefulWidget {
  final String categoria;
  final int idUsuario;

  TareasPorCategoriaPage({required this.categoria, required this.idUsuario});

  @override
  _TareasPorCategoriaPageState createState() => _TareasPorCategoriaPageState();
}

class _TareasPorCategoriaPageState extends State<TareasPorCategoriaPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas de ${widget.categoria}'),
      ),
      body: FutureBuilder<List<Tarea>>(
        future: _dbHelper.getTasksByCategory(widget.categoria, widget.idUsuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tareas disponibles'));
          } else {
            List<Tarea> tareas = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                dataRowHeight: 60,
                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade200),
                columns: [
                  DataColumn(
                    label: Text(
                      'Nombre',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Fecha Límite',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Importancia',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: tareas.map((tarea) {
                  return DataRow(
                    cells: [
                      DataCell(
                        GestureDetector(
                          onTap: () async {
                            bool? updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailPage(tarea: tarea),
                              ),
                            );
                            if (updated == true) {
                              setState(() {}); // Refresh the table after an update
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(tarea.nombreTarea),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            DateFormat('dd-MM-yyyy').format(tarea.fechaLimite),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            tarea.importancia.toString(),
                            style: TextStyle(
                              color: _getImportanciaColor(tarea.importancia),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Color _getImportanciaColor(int importancia) {
    switch (importancia) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.deepPurpleAccent;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
