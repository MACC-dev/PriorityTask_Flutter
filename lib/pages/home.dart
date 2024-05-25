import 'package:flutter/material.dart';
import 'package:flutter_application_1/DataBase/DatabaseHelper.dart';
import 'package:flutter_application_1/pages/RegisterPage.dart';
import 'package:flutter_application_1/pages/Task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

 @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'lib/images/login_image.jpg',
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bienvenido A PrioriTask',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty?? true) {
                              return 'Porfavor ingrese un email';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value!,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Por favor ingrese una contrasena con al menos 8 caracteres';
                            }
                            return null;
                          },
                          onSaved: (value) => _password = value!,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          ElevatedButton(
                          onPressed: () async {
                          final db = DatabaseHelper();
                          if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, rellene los campos de email y contraseña')),
                            );
                          return;
                            }
                          final email = emailController.text;
                          final password = passwordController.text;
                          final authenticated = await db.authenticated(email, password);
                          if (authenticated != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Autenticación exitosa')),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TaskPage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Autenticación fallida')),
                            );
                          
                          }
                          
                          int? idUsuario = await db.getIdUsuario();

                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('idUsuario', idUsuario);
                                                   },
                            child: const Text('Iniciar sesión'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                             );
                             },
                            child: const Text('Registrarse'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Olvide Contrasena
                            },
                            child: const Text('Olvidaste tu contraseña?'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}