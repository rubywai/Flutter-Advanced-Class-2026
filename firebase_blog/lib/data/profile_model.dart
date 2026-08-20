class ProfileModel {
  ProfileModel({this.uid, this.name, this.profilePic, this.email});

  ProfileModel.fromJson(dynamic json) {
    uid = json['uid'];
    name = json['name'];
    profilePic = json['profile_pic'];
    email = json['email'];
  }

  String? uid;
  String? name;
  String? profilePic;
  String? email;

  ProfileModel copyWith({
    String? uid,
    String? name,
    String? profilePic,
    String? email,
  }) => ProfileModel(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    profilePic: profilePic ?? this.profilePic,
    email: email ?? this.email,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['name'] = name;
    map['profile_pic'] = profilePic;
    map['email'] = email;
    return map;
  }
}
