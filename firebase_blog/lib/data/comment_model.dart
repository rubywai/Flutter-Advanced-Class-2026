class CommentModel {
  CommentModel({this.uid, this.comment, this.createdAt});

  CommentModel.fromJson(dynamic json) {
    uid = json['userId'];
    comment = json['comment'];
    createdAt = json['createdAt'];
  }

  String? uid;
  String? comment;
  int? createdAt;

  CommentModel copyWith({String? uid, String? comment, int? createdAt}) =>
      CommentModel(
        uid: uid ?? this.uid,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = uid;
    map['comment'] = comment;
    map['createdAt'] = createdAt;
    return map;
  }
}
