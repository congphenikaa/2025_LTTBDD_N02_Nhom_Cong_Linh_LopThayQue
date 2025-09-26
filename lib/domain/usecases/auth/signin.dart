import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/data/models/auth/signin_user_req.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:dartz/dartz.dart';

class SigninUseCase implements Usecase<Either ,SigninUserReq> {


  @override
  Future<Either> call({SigninUserReq ? params}) {
    return sl<AuthRepository>().signin(params!);
  }

}