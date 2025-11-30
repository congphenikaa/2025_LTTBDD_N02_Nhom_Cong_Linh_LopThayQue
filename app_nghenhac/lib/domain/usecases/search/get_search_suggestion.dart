import 'package:app_nghenhac/core/usecase/search_usecase.dart';
import 'package:app_nghenhac/domain/repository/search/search.dart';
import 'package:dartz/dartz.dart';

class GetSearchSuggestionsUseCase implements UseCase<List<String>, String> {
  final SearchRepository _searchRepository;

  GetSearchSuggestionsUseCase({required SearchRepository searchRepository})
      : _searchRepository = searchRepository;

  @override
  Future<Either<String, List<String>>> call({String? params}) async {
    if (params == null || params.trim().isEmpty) {
      return const Right([]);
    }

    try {
      return await _searchRepository.getSearchSuggestions(params.trim());
    } catch (e) {
      return Left('Failed to get suggestions: ${e.toString()}');
    }
  }
}