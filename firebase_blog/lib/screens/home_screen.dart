import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/data/blog_database.dart';
import 'package:firebase_blog/widgets/add_blog_post_dialog.dart';
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _blogDatabase.readBlogList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final list = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final blogDoc = list[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal:  8.0),
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      title: Text(blogDoc['title'] ?? ""),
                      subtitle: Text(blogDoc['description'] ?? ""),
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
}
