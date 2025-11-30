import 'package:app_nghenhac/domain/entities/auth/user.dart';

class UserModel {
  
  String ? fullName;
  String ? email;
  String ? imageURl;

  UserModel({
    this.fullName,
    this.email,
    this.imageURl
  });

  UserModel.fromJson(Map<String, dynamic> data) {
    fullName = data['name'];
    email = data['email'];
  }

}

extension User on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      email: email!,
      fullName: fullName,
      imageURl: imageURl
    );
  }
}