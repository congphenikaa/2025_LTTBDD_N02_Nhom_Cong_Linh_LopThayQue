import 'package:app_nghenhac/data/models/auth/create_user_req.dart';
import 'package:app_nghenhac/data/sources/auth/auth_firebase_service.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl extends AuthRepository {

  @override
  Future<void> signin() {
    // TODO: implement signin
    throw UnimplementedError();
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    return await sl<AuthFirebaseService>().signup(createUserReq);
  }

}