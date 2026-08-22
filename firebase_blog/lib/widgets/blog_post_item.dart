import 'package:firebase_blog/widgets/blog_post_profile_header.dart';
import 'package:flutter/material.dart';
import '../data/blog_post_model.dart';

class BlogPostItem extends StatefulWidget {
  const BlogPostItem({super.key, required this.blogDoc, required this.docId});

  final BlogPostModel blogDoc;
  final String docId;

  @override
  State<BlogPostItem> createState() => _BlogPostItemState();
}

class _BlogPostItemState extends State<BlogPostItem> {
  @override
  Widget build(BuildContext context) {
    BlogPostModel blogDoc = widget.blogDoc;
    DateTime? createAt = DateTime.fromMillisecondsSinceEpoch(blogDoc.createdAt ?? 0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlogPostProfileHeader(blogDoc: blogDoc, docId: widget.docId),
              Divider(),
              Center(
                child: Text(
                  blogDoc.title ?? "",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 4),
              Text(blogDoc.description ?? ""),
              if (blogDoc.image != null) SizedBox(height: 4),
              if (blogDoc.image != null)
                Image.memory(
                  blogDoc.image!.bytes,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: IconButton(onPressed: (){
                      
                    }, icon: Icon(Icons.comment)),
                  ),
                  Text('|'),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${createAt.day}/${createAt.month}/${createAt.year} ${createAt.hour}:${createAt.minute}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
