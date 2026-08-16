import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/data/blog_database.dart';
import 'package:firebase_blog/data/blog_post_model.dart';
import 'package:firebase_blog/data/google_login.dart';
import 'package:firebase_blog/widgets/add_blog_post_dialog.dart';
import 'package:firebase_blog/widgets/edit_blog_post_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets/blog_post_item.dart';

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
      appBar: AppBar(
        title: Text("Blog App"),
        actions: [
          IconButton(
            onPressed: () {
              signInWithGoogle();
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
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
                return BlogPostItem(blogDoc: blogDoc, docId: documentId);
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
}
