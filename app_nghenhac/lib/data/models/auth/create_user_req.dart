class CreateUserReq {
  final String fullName;
  final String email;
  final String? password; 
  final String? avatar;   
  final String? googleId; 
  final String? token;

  CreateUserReq({
    required this.fullName,
    required this.email,
    this.password,
    this.avatar,
    this.googleId,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'avatar': avatar,
      'googleId': googleId,
      'token': token,
    };
  }
}