import 'package:firebase_blog/data/blog_database.dart';
import 'package:firebase_blog/data/blog_post_model.dart';
import 'package:flutter/material.dart';

class EditBlogPostDialog extends StatefulWidget {
  const EditBlogPostDialog({
    super.key,
    required this.title,
    required this.desc,
    required this.docId,
  });

  final String title;
  final String desc;
  final String docId;

  @override
  State<EditBlogPostDialog> createState() => _EditBlogPostDialogState();
}

class _EditBlogPostDialogState extends State<EditBlogPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BlogDatabase _blogDatabase = BlogDatabase();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _descriptionController.text = widget.desc;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Title",
            ),
          ),
          SizedBox(height: 8),
          TextField(
            maxLines: 5,
            minLines: 4,
            controller: _descriptionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Description",
            ),
          ),
          SizedBox(height: 8),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isLoading
              ? null
              : () async {
                  try {
                    if (_titleController.text.trim().isEmpty ||
                        _descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all fields")),
                      );
                      return;
                    } else {
                      setState(() {
                        _isLoading = true;
                      });
                      await _blogDatabase.updatePost(
                        blogPostModel: BlogPostModel(
                          title: _titleController.text,
                          description: _descriptionController.text,
                        ),
                        docId: widget.docId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            "Blog post updated successfully",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "Update blog post failed $e",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context);
                  }
                },
          child: Text("Update Post"),
        ),
      ],
    );
  }
}
