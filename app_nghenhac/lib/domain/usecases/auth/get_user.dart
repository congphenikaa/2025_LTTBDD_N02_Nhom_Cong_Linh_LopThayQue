import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:dartz/dartz.dart';

class GetUserUseCase implements Usecase<Either ,dynamic> {


  @override
  Future<Either> call({params}) async {
    return await sl<AuthRepository>().getUser();
  }

}