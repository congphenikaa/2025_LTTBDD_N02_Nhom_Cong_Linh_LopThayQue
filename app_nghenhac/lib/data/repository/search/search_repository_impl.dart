import 'package:app_nghenhac/data/sources/search/search_firebase_service.dart';
import 'package:app_nghenhac/data/sources/search/search_local_service.dart';
import 'package:app_nghenhac/domain/entities/search/search_result.dart';
import 'package:app_nghenhac/domain/repository/search/search.dart';
import 'package:dartz/dartz.dart';

class SearchRepositoryImpl extends SearchRepository {
  final SearchFirebaseService _firebaseService;
  final SearchLocalService _localService;

  SearchRepositoryImpl({
    required SearchFirebaseService firebaseService,
    required SearchLocalService localService,
  })  : _firebaseService = firebaseService,
        _localService = localService;

  @override
  Future<Either<String, SearchResultEntity>> search(String query) async {
    try {
      final searchResult = await _firebaseService.search(query);
      
      // Save to local history if search is successful
      await _localService.saveSearchQuery(query);
      
      return Right(searchResult.toEntity());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<String>>> getSearchHistory() async {
    try {
      final history = await _localService.getSearchHistory();
      return Right(history);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> saveSearchQuery(String query) async {
    try {
      await _localService.saveSearchQuery(query);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> clearSearchHistory() async {
    try {
      await _localService.clearSearchHistory();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<String>>> getSearchSuggestions(String query) async {
    try {
      final suggestions = await _firebaseService.getSearchSuggestions(query);
      return Right(suggestions);
    } catch (e) {
      return Left(e.toString());
    }
  }
}