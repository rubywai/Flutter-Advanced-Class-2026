import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/data/blog_database.dart';
import 'package:firebase_blog/data/blog_post_model.dart';
import 'package:firebase_blog/widgets/add_blog_post_dialog.dart';
import 'package:firebase_blog/widgets/edit_blog_post_dialog.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BlogDatabase _blogDatabase = BlogDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Blog App")),
      body: StreamBuilder<QuerySnapshot<BlogPostModel>>(
        stream: _blogDatabase.readBlogList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final list = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final String documentId = list[index].id;
                final BlogPostModel blogDoc = list[index].data();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      leading: IconButton(
                        onPressed: () {
                          _editBlogPostDialog(
                            title: blogDoc.title ?? "",
                            desc: blogDoc.description ?? "",
                            docId: documentId,
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                      title: Text(blogDoc.title ?? ""),
                      subtitle: Text(blogDoc.description ?? ""),
                      trailing: IconButton(
                        onPressed: () {
                          _blogDatabase.deletePost(documentId);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Something wrong");
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBlogPostDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _addBlogPostDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddBlogPostDialog();
      },
    );
  }

  void _editBlogPostDialog({
    required String title,
    required String desc,
    required String docId,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return EditBlogPostDialog(title: title, desc: desc, docId: docId);
      },
    );
  }
}
