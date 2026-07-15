import 'package:cloud_firestore/cloud_firestore.dart';
class BlogDatabase {
  final CollectionReference _blogCollection = FirebaseFirestore.instance.collection("blogs");
  final Stream<QuerySnapshot> _blogPostStream = FirebaseFirestore.instance.collection('blogs').snapshots();
  Future<DocumentReference> createBlogPost({required String title,required String description}) async{
    try{
      DateTime now = DateTime.now();
     return _blogCollection.add({
        "title" : title,
        "description" : description,
        "createdAt" : now.millisecondsSinceEpoch,
      });
    }
    catch(e){
      return Future.error(e);
    }
  }
  Stream<QuerySnapshot> readBlogList(){
    try{
      return _blogPostStream;
    }
    catch(e){
      return Stream.error(e);
    }
  }

}