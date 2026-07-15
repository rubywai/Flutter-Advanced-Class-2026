import 'package:firebase_blog/data/blog_database.dart';
import 'package:flutter/material.dart';

class AddBlogPostDialog extends StatefulWidget {
  const AddBlogPostDialog({super.key});

  @override
  State<AddBlogPostDialog> createState() => _AddBlogPostDialogState();
}

class _AddBlogPostDialogState extends State<AddBlogPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BlogDatabase _blogDatabase = BlogDatabase();
  bool _isLoading = false;

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
                      await _blogDatabase.createBlogPost(
                        title: _titleController.text,
                        description: _descriptionController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            "Blog post created successfully",
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
                          "Create blog post failed $e",
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
          child: Text("Add Post"),
        ),
      ],
    );
  }
}
