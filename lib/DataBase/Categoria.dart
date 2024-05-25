class Categoria {
  int idCategoria;
  String nombreCategoria;

  Categoria({required this.idCategoria, required this.nombreCategoria});

  Map<String, dynamic> toMap() {
    return {
      'idCategoria': idCategoria,
      'nombreCategoria': nombreCategoria,
    };
  }

  static Categoria fromMap(Map<String, dynamic> map) {
    return Categoria(
      idCategoria: map['idCategoria'] ?? 0,
      nombreCategoria: map['nombreCategoria'] ?? '', 
    );
  }
}