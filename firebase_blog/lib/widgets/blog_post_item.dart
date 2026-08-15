import 'package:firebase_blog/data/blog_database.dart';
import 'package:flutter/material.dart';

import '../data/blog_post_model.dart';
import 'edit_blog_post_dialog.dart';

class BlogPostItem extends StatefulWidget {
  const BlogPostItem({super.key, required this.blogDoc, required this.docId});

  final BlogPostModel blogDoc;
  final String docId;

  @override
  State<BlogPostItem> createState() => _BlogPostItemState();
}

class _BlogPostItemState extends State<BlogPostItem> {
  final MenuController _menuController = MenuController();
  final BlogDatabase _database = BlogDatabase();

  @override
  Widget build(BuildContext context) {
    BlogPostModel blogDoc = widget.blogDoc;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "Maung Maung",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  MenuAnchor(
                    controller: _menuController,
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          _menuController.close();
                          _editBlogPostDialog(
                            title: blogDoc.title ?? "",
                            desc: blogDoc.description ?? "",
                            docId: widget.docId,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Edit"),
                        ),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          _menuController.close();
                          _delete();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Delete"),
                        ),
                      ),
                    ],
                    builder: (_, _, _) {
                      return IconButton(
                        onPressed: () {
                          _menuController.open();
                        },
                        icon: Icon(Icons.more_vert),
                      );
                    },
                  ),
                ],
              ),
              Divider(),
              Center(
                child: Text(
                  widget.blogDoc.title ?? "",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 4),
              Text(widget.blogDoc.description ?? ""),
            ],
          ),
        ),
      ),
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

  void _delete() async {
    try {
      await _database.deletePost(widget.docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Delete blog post successfully",
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to delete blog post",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
  }
}
