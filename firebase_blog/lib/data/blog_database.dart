import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_blog/data/blog_post_model.dart';

class BlogDatabase {
  final CollectionReference<BlogPostModel> _blogCollection = FirebaseFirestore
      .instance
      .collection("blogs")
      .withConverter(
        fromFirestore: (snapshot, _) => BlogPostModel.fromJson(snapshot),
        toFirestore: (blogPostModel, _) => blogPostModel.toJson(),
      );

  late final Stream<QuerySnapshot<BlogPostModel>> _blogPostStream =
      _blogCollection.snapshots();

  Future<DocumentReference> createBlogPost({
    required BlogPostModel blogPostModel,
  }) async {
    try {
      final DateTime now = DateTime.now();
      final User? user = FirebaseAuth.instance.currentUser;
      final String? userId = user?.uid;
      if (userId == null) {
        return Future.error("User not authenticated");
      }
      return _blogCollection.add(
        blogPostModel.copyWith(
          createdAt: now.millisecondsSinceEpoch,
          userId: userId,
        ),
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  Stream<QuerySnapshot<BlogPostModel>> readBlogList() {
    try {
      return _blogPostStream;
    } catch (e) {
      return Stream.error(e);
    }
  }

  Future<void> deletePost(String docId) async {
    try {
      await _blogCollection.doc(docId).delete();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> updatePost({
    required BlogPostModel blogPostModel,
    required String docId,
  }) async {
    try {
      DateTime now = DateTime.now();
      _blogCollection
          .doc(docId)
          .update(
            blogPostModel
                .copyWith(updatedAt: now.millisecondsSinceEpoch)
                .toJson(),
          );
    } catch (e) {
      return Future.error(e);
    }
  }
}
