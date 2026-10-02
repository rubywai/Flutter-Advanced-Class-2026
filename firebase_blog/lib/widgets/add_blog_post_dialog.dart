import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/data/blog_database.dart';
import 'package:firebase_blog/data/blog_post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  Uint8List? _image;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          if (_image == null)
            IconButton(
              onPressed: () async {
                XFile? image = await _pickImage();
                if (image != null) {
                  _image = await image.readAsBytes();
                  setState(() {});
                }
              },
              icon: Icon(Icons.image),
              color: Colors.blueAccent,
              iconSize: 36,
            ),
          if (_image != null)
            Image.memory(_image!, width: 200, height: 200, fit: BoxFit.cover),
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
                        blogPostModel: BlogPostModel(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          image: _image != null ? Blob(_image!) : null,
                        ),
                      );
                      if (mounted) {
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
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Create blog post failed $e",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
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

  Future<XFile?> _pickImage() {
    ImagePicker imagePicker = ImagePicker();
    return imagePicker.pickImage(source: ImageSource.gallery);
  }
}
