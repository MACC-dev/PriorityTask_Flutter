class Usuario {
  int idUsuario;
  String nombreUsuario;
  String apellidoUsuario;
  String email;
  String contrasena;

  Usuario({required this.idUsuario, required this.nombreUsuario, required this.apellidoUsuario, required this.email, required this.contrasena});

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nombreUsuario': nombreUsuario,
      'apellidoUsuario': apellidoUsuario,
      'email': email,
      'contrasena': contrasena,
    };
  }

  static Usuario fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['idUsuario'],
      nombreUsuario: map['nombreUsuario'],
      apellidoUsuario: map['apellidoUsuario'],
      email: map['email'],
      contrasena: map['contrasena'],
    );
  }
}