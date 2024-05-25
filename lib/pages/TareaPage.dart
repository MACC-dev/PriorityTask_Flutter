import 'package:flutter/material.dart';
import 'package:flutter_application_1/DataBase/DatabaseHelper.dart';
import 'package:flutter_application_1/pages/TareasPorCategoria.dart';

class CategoriaSelectionPage extends StatefulWidget {
  final int idUsuario;

  CategoriaSelectionPage({required this.idUsuario});

  @override
  _CategoriaSelectionPageState createState() => _CategoriaSelectionPageState();
}

class _CategoriaSelectionPageState extends State<CategoriaSelectionPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Categoría'),
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
            return ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categorias[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TareasPorCategoriaPage(
                          categoria: categorias[index],
                          idUsuario: widget.idUsuario,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
