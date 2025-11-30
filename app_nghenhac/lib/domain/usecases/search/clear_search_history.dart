import 'package:app_nghenhac/core/usecase/search_usecase.dart';
import 'package:app_nghenhac/domain/repository/search/search.dart';
import 'package:dartz/dartz.dart';

class ClearSearchHistoryUseCase implements UseCase<void, NoParams> {
  final SearchRepository _searchRepository;

  ClearSearchHistoryUseCase({required SearchRepository searchRepository})
      : _searchRepository = searchRepository;

  @override
  Future<Either<String, void>> call({NoParams? params}) async {
    try {
      return await _searchRepository.clearSearchHistory();
    } catch (e) {
      return Left('Failed to clear search history: ${e.toString()}');
    }
  }
}