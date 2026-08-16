import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPostModel {
  BlogPostModel({
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  BlogPostModel.fromJson(dynamic json) {
    title = json['title'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    image = json['image'];
  }

  String? title;
  String? description;
  int? createdAt;
  int? updatedAt;
  Blob? image;

  BlogPostModel copyWith({
    String? title,
    String? description,
    int? createdAt,
    int? updatedAt,
    Blob? image,
  }) => BlogPostModel(
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    image: image ?? this.image,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['description'] = description;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['image'] = image;
    return map;
  }
}
