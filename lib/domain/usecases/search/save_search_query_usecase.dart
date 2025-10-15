import 'package:app_nghenhac/core/usecase/search_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:app_nghenhac/domain/repository/search/search.dart';

class SaveSearchQueryUseCase implements UseCase<void, String> {
  final SearchRepository repository;

  SaveSearchQueryUseCase({required this.repository});

  @override
  Future<Either<String, void>> call({String? params}) async {
    return await repository.saveSearchQuery(params!);
  }
}