import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/data/profile_database.dart';
import 'package:firebase_blog/data/profile_model.dart';
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
  final userCredential = await FirebaseAuth.instance.signInWithCredential(
    credential,
  );
  ProfileDatabase profileDatabase = ProfileDatabase();
  await profileDatabase.createProfile(
    profileModel: ProfileModel(
      uid: userCredential.user?.uid ?? "",
      email: userCredential.user?.email ?? "",
      name: userCredential.user?.displayName ?? "",
      profilePic: userCredential.user?.photoURL ?? "",
    ),
  );
  return userCredential;
}

void listenAuthState(Function(User?) onChangeAuthState) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    onChangeAuthState(user);
  });
}
