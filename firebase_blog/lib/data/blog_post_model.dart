class BlogPostModel {
  BlogPostModel({
      this.title, 
      this.description, 
      this.createdAt, 
      this.updatedAt,});

  BlogPostModel.fromJson(dynamic json) {
    title = json['title'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
  String? title;
  String? description;
  int? createdAt;
  int? updatedAt;
BlogPostModel copyWith({  String? title,
  String? description,
  int? createdAt,
  int? updatedAt,
}) => BlogPostModel(  title: title ?? this.title,
  description: description ?? this.description,
  createdAt: createdAt ?? this.createdAt,
  updatedAt: updatedAt ?? this.updatedAt,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['description'] = description;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    return map;
  }

}