import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  await GoogleSignIn.instance.initialize(
    clientId:
        "515332910105-8qe79k90lhvsv1trqu2j9tsr5d7aoc9t.apps.googleusercontent.com",
  );
  final GoogleSignInAccount account = await GoogleSignIn.instance
      .authenticate();
  final GoogleSignInAuthentication authentication = account.authentication;

  final credential = GoogleAuthProvider.credential(
    idToken: authentication.idToken,
  );
  return FirebaseAuth.instance.signInWithCredential(credential);
}

void listenAuthState(Function(User?) onChangeAuthState) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    onChangeAuthState(user);
  });
}
