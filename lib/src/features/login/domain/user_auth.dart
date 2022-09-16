class UserAuth {
  const UserAuth({required this.jwt, required this.userName});
  final String jwt;
  final String userName;

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
        jwt: json['jwt'].toString(), userName: json['userName'].toString());
  }
}
