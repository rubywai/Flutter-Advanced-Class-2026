import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_blog/analytics/analytics_utils.dart';
import 'package:firebase_blog/data/blog_database.dart';
import 'package:firebase_blog/data/comment_model.dart';
import 'package:firebase_blog/data/login_utils.dart';
import 'package:firebase_blog/widgets/blog_post_profile_header.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  final TextEditingController _commentController = TextEditingController();
  final BlogDatabase _blogDatabase = BlogDatabase();
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
                      AnalyticsUtils.customEvent("view comment", "pressed");
                      showDialog(context: context, builder:
                      (context){
                        return AlertDialog(
                          title: Text("Comment"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StreamBuilder
                                <QuerySnapshot<CommentModel>>(stream: _blogDatabase.readComments(widget.docId),
                                  builder: (context,snapshot){
                                    if(snapshot.hasError){
                                      return Icon(Icons.error);
                                    }
                                    if(snapshot.hasData){
                                      final list = snapshot.data?.docs ?? [];
                                      if(list.isEmpty){
                                        return Text("No comment!");
                                      }
                                      return SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: list.length,
                                            itemBuilder: (context,index){
                                          final String documentId = list[index].id;
                                          final CommentModel commentDoc = list[index].data();
                                          return ListTile(
                                            title: Text(commentDoc.comment ?? ""),
                                          );
                                        }),
                                      );
                                    }
                                    return Center(child: CircularProgressIndicator(),);
                                  }),
                              TextField(
                                controller : _commentController,
                                decoration: InputDecoration(
                                  hintText: "Enter your comment",
                                ),
                              ),
                              SizedBox(height: 8)
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: (){
                              Navigator.pop(context);
                              _commentController.clear();
                            }, child: Text("Cancel"),),
                            FilledButton(onPressed: (){
                              _blogDatabase.addComment(widget.docId, CommentModel(
                                uid: getUser()?.uid ?? "",
                                comment: _commentController.text,
                                createdAt: DateTime.now().millisecondsSinceEpoch,
                              ));
                              Navigator.pop(context,true);
                              _commentController.clear();
                            }, child: Text("Comment"))
                          ],
                        );
                      })
                      .then((v){
                        if(v != true){
                          FirebaseCrashlytics.instance.log("Cancel the comment");
                        }
                      });
                      
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
