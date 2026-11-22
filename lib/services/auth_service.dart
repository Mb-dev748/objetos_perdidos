import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final Future<void> _inicializacion = GoogleSignIn.instance
      .initialize();

  Future<User?> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> iniciarSesionGoogle() async {
    await _inicializacion;
    final cuenta = await GoogleSignIn.instance.authenticate();
    final idToken = cuenta.authentication.idToken;
    final credencial = GoogleAuthProvider.credential(idToken: idToken);
    await FirebaseAuth.instance.signInWithCredential(credencial);
  }
}
