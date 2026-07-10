import 'package:firebase_auth/firebase_auth.dart';

class UserLocalKeys {
  const UserLocalKeys._();

  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  static String nomeUsuario(String uid) => 'nome_usuario_$uid';

  static String fotoUsuario(String uid) => 'foto_usuario_$uid';

  static String corPerfil(String uid) => 'cor_perfil_$uid';

  static String favoritos(String uid) => 'favoritos_$uid';

  static String tutorialVisto(String uid) => 'tutorial_visto_$uid';

  static Set<String> allFor(String uid) {
    return {
      nomeUsuario(uid),
      fotoUsuario(uid),
      corPerfil(uid),
      favoritos(uid),
      tutorialVisto(uid),
    };
  }
}
