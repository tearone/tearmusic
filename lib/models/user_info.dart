class UserInfo {
  String username;
  String avatar;

  UserInfo({
    required this.username,
    required this.avatar,
  });

  factory UserInfo.fromJson(Map json) {
    return UserInfo(
      username: json["username"],
      avatar: json["avatar"],
    );
  }
}
