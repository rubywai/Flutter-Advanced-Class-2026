import 'package:firebase_blog/data/login_utils.dart';
import 'package:flutter/material.dart';

import '../data/blog_database.dart';
import '../data/blog_post_model.dart';
import '../data/profile_database.dart';
import '../data/profile_model.dart';
import 'edit_blog_post_dialog.dart';

class BlogPostProfileHeader extends StatefulWidget {
  const BlogPostProfileHeader({
    super.key,
    required this.blogDoc,
    required this.docId,
  });

  final BlogPostModel blogDoc;
  final String docId;

  @override
  State<BlogPostProfileHeader> createState() => _BlogPostProfileHeaderState();
}

class _BlogPostProfileHeaderState extends State<BlogPostProfileHeader> {
  final MenuController _menuController = MenuController();
  final BlogDatabase _database = BlogDatabase();

  @override
  Widget build(BuildContext context) {
    BlogPostModel blogDoc = widget.blogDoc;
    return Row(
      children: [
        Icon(Icons.person, size: 30),
        SizedBox(width: 8),
        FutureBuilder<ProfileModel?>(
          future: ProfileDatabase().getProfile(widget.blogDoc.userId ?? ""),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Icon(Icons.error);
            } else if (snapshot.hasData) {
              return Text(
                snapshot.data?.name ?? "",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              );
            }
            return Text(".....");
          },
        ),
        Spacer(),
        if(getUser()?.uid == blogDoc.userId)
        MenuAnchor(
          controller: _menuController,
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                _menuController.close();
                _editBlogPostDialog(
                  blogDoc: blogDoc,
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
    );
  }

  void _editBlogPostDialog({
    required BlogPostModel blogDoc,
    required String docId,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return EditBlogPostDialog(blogDoc: blogDoc, docId: docId);
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
