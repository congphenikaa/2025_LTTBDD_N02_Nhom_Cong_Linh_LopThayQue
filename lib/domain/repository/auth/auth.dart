import 'package:app_nghenhac/data/models/auth/create_user_req.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {

  Future<Either> signup(CreateUserReq createUserReq);

  Future<void> signin();


}