import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/data/models/auth/create_user_req.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:dartz/dartz.dart';

class SignupUseCase implements Usecase<Either ,CreateUserReq> {


  @override
  Future<Either> call({CreateUserReq ? params}) {
    return sl<AuthRepository>().signup(params!);
  }

}