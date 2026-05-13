import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// 🔥 CADASTRO COM GOOGLE
  Future<UserCredential?> signInWithGoogle() async {

    try {

      /// 🔥 GOOGLE SIGN IN
      final GoogleSignIn googleSignIn =
          GoogleSignIn();

      /// 🔥 MOSTRA SELETOR DE CONTAS
      await googleSignIn.signOut();

      /// 🔥 ESCOLHER CONTA
      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) return null;

      /// 🔥 AUTH GOOGLE
      final GoogleSignInAuthentication
          googleAuth =
              await googleUser.authentication;

      /// 🔥 CREDENCIAL
      final credential =
          GoogleAuthProvider.credential(
        accessToken:
            googleAuth.accessToken,

        idToken:
            googleAuth.idToken,
      );

      /// 🔥 LOGIN FIREBASE
      return await _auth
          .signInWithCredential(
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

      /// 🔥 GOOGLE SIGN IN
      final GoogleSignIn googleSignIn =
          GoogleSignIn();

      /// 🔥 MOSTRA SELETOR DE CONTAS
      await googleSignIn.signOut();

      /// 🔥 ESCOLHER CONTA
      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) return null;

      /// 🔥 AUTH GOOGLE
      final GoogleSignInAuthentication
          googleAuth =
              await googleUser.authentication;

      /// 🔥 CREDENCIAL
      final credential =
          GoogleAuthProvider.credential(
        accessToken:
            googleAuth.accessToken,

        idToken:
            googleAuth.idToken,
      );

      /// 🔥 LOGIN FIREBASE
      return await _auth
          .signInWithCredential(
        credential,
      );

    } catch (e) {

      print(
        "Erro no login Google: $e",
      );

      rethrow;
    }
  }
}