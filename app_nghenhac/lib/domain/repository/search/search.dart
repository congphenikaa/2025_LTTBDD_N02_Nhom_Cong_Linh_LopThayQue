import 'package:dartz/dartz.dart';
import '../../entities/search/search_result.dart';

abstract class SearchRepository {
  Future<Either<String, SearchResultEntity>> search(String query);
  Future<Either<String, List<String>>> getSearchHistory();
  Future<Either<String, void>> saveSearchQuery(String query);
  Future<Either<String, void>> clearSearchHistory();
  Future<Either<String, List<String>>> getSearchSuggestions(String query);
}