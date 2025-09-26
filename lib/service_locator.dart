import 'package:app_nghenhac/data/repository/auth/auth_repository_impl.dart';
import 'package:app_nghenhac/data/sources/auth/auth_firebase_service.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/domain/usecases/auth/signin.dart';
import 'package:app_nghenhac/domain/usecases/auth/signup.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;
Future<void> initilizeDependencies() async {

  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl()
  );

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl()
  );

  sl.registerSingleton<SignupUseCase>(
    SignupUseCase()
  );

  sl.registerSingleton<SigninUseCase>(
    SigninUseCase()
  );
  
}