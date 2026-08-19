import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPostModel {
  BlogPostModel({
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.image,
    this.userId,
  });

  BlogPostModel.fromJson(dynamic json) {
    title = json['title'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    image = json['image'];
    userId = json['userId'];
  }

  String? title;
  String? description;
  int? createdAt;
  int? updatedAt;
  Blob? image;
  String? userId;

  BlogPostModel copyWith({
    String? title,
    String? description,
    int? createdAt,
    int? updatedAt,
    Blob? image,
    String? userId,
  }) => BlogPostModel(
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    image: image ?? this.image,
    userId: userId ?? this.userId,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['description'] = description;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['image'] = image;
    map['userId'] = userId;
    return map;
  }
}
