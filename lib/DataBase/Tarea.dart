export 'Tarea.dart';

class Tarea {
  int? idTarea;
  String nombreTarea;
  String descripcion;
  DateTime fechaLimite;
  int importancia;
  int idCategoria;
  int idUsuario;
  

  Tarea({
    required this.idTarea,
    required this.nombreTarea,
    required this.descripcion,
    required this.fechaLimite,
    required this.importancia,
    required this.idCategoria,
    required this.idUsuario,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'idTarea': idTarea,
      'nombreTarea': nombreTarea,
      'descripcion': descripcion,
      'fecha_limite': fechaLimite.toString(),
      'importancia': importancia,
      'id_categoria': idCategoria,
      'id_usuario': idUsuario,
    };
  }

  static Tarea fromMap(Map<String, dynamic> map) {
  return Tarea(
    idTarea: map['idTarea'] as int?, 
    nombreTarea: map['nombreTarea'] ?? '',
    descripcion: map['descripcion'] ?? '',
    fechaLimite: DateTime.parse(map['fecha_limite'] ?? ''),
    importancia: map['importancia'] ?? 0,
    idCategoria: map['id_categoria'] ?? 0,
    idUsuario: map['id_usuario'] ?? 0,
  );
}
}

