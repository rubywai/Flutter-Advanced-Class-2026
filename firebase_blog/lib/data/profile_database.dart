import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/data/profile_model.dart';

class ProfileDatabase {
  final CollectionReference<ProfileModel> _profileCollection = FirebaseFirestore
      .instance
      .collection("profiles")
      .withConverter(
    fromFirestore: (snapshot, _) => ProfileModel.fromJson(snapshot),
    toFirestore: (profileModel, _) => profileModel.toJson(),
  );

  Future<DocumentReference<ProfileModel>> createProfile(
  {
    required ProfileModel profileModel
}
      ) async{
   return _profileCollection.add(profileModel);
  }
}