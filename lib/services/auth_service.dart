import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔥 CADASTRO COM GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      /// 🔥 GOOGLE SIGN IN
      final GoogleSignIn googleSignIn = GoogleSignIn();

      /// 🔥 MOSTRA SELETOR DE CONTAS
      await googleSignIn.signOut();

      /// 🔥 ESCOLHER CONTA
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      /// 🔥 AUTH GOOGLE
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      /// 🔥 CREDENCIAL
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      /// 🔥 LOGIN FIREBASE
      return await _auth.signInWithCredential(
        credential,
      );
    } catch (e) {
      print(
        "Erro no cadastro Google: $e",
      );

      rethrow;
    }
  }

  /// 🔥 LOGIN COM GOOGLE
  Future<UserCredential?> loginWithGoogle() async {
    try {
      print("1 - Criando GoogleSignIn");

      final GoogleSignIn googleSignIn = GoogleSignIn();

      print("2 - Fazendo signOut");

      await googleSignIn.signOut();

      print("3 - Chamando signIn()");

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      print("4 - Retornou do signIn()");

      if (googleUser == null) {
        print("Usuário cancelou");
        return null;
      }

      print("5 - Pegando autenticação");

      final googleAuth = await googleUser.authentication;

      print("6 - Criando credencial");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("7 - Login Firebase");

      return await _auth.signInWithCredential(
        credential,
      );
    } catch (e, s) {
      print("ERRO:");
      print(e);
      print(s);
      rethrow;
    }
  }
}
