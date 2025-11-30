import 'package:app_nghenhac/core/usecase/search_usecase.dart';
import 'package:app_nghenhac/domain/entities/search/search_result.dart';
import 'package:app_nghenhac/domain/repository/search/search.dart';
import 'package:dartz/dartz.dart';

class SearchUseCase implements UseCase<SearchResultEntity, String> {
  final SearchRepository _searchRepository;

  SearchUseCase({required SearchRepository searchRepository})
      : _searchRepository = searchRepository;

  @override
  Future<Either<String, SearchResultEntity>> call({String? params}) async {
    if (params == null || params.trim().isEmpty) {
      return const Left('Search query cannot be empty');
    }

    try {
      final result = await _searchRepository.search(params.trim());
      
      // Save search query to history if successful
      result.fold(
        (failure) => null,
        (searchResult) => _searchRepository.saveSearchQuery(params.trim()),
      );
      
      return result;
    } catch (e) {
      return Left('Failed to search: ${e.toString()}');
    }
  }
}