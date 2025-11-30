

import 'package:app_nghenhac/core/usecase/search_usecase.dart';
import 'package:app_nghenhac/domain/repository/search/search.dart';
import 'package:dartz/dartz.dart';

class GetSearchHistoryUseCase implements UseCase<List<String>, NoParams> {
  final SearchRepository _searchRepository;

  GetSearchHistoryUseCase({required SearchRepository searchRepository})
      : _searchRepository = searchRepository;

  @override
  Future<Either<String, List<String>>> call({NoParams? params}) async {
    try {
      return await _searchRepository.getSearchHistory();
    } catch (e) {
      return Left('Failed to get search history: ${e.toString()}');
    }
  }
}