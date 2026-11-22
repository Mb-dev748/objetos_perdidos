import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:objetos_perdidos/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool cargando = false;
  String mensajeError = '';

  Future<void> ingresar() async {
    setState(() {
      cargando = true;
      mensajeError = '';
    });
    try {
      await AuthService().iniciarSesionGoogle();
    } on GoogleSignInException catch (ex) {
      if (ex.code != GoogleSignInExceptionCode.canceled) {
        mensajeError = 'No se pudo iniciar sesion con google';
      }
    } on FirebaseAuthException {
      mensajeError = 'Error al conectar la Firebase';
    }
    if (!mounted) return;
    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colores.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.travel_explore, size: 96, color: colores.secondary),
              const SizedBox(height: 16),
              Text(
                'Objetos perdidos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colores.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Publica lo que perdiste o encontraste',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colores.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 48),
              cargando
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colores.secondary,
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: ingresar,
                      style: FilledButton.styleFrom(
                        backgroundColor: colores.secondary,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Ingresar con google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
              const SizedBox(height: 16),
              Text(
                mensajeError,
                textAlign: TextAlign.center,
                style: TextStyle(color: colores.errorContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
