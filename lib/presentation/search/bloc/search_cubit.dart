import 'package:app_nghenhac/core/usecase/search_usecase.dart';
import 'package:app_nghenhac/domain/usecases/search/clear_search_history.dart';
import 'package:app_nghenhac/domain/usecases/search/get_search_history.dart';
import 'package:app_nghenhac/domain/usecases/search/search.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchUseCase _searchUseCase;
  final GetSearchHistoryUseCase _getSearchHistoryUseCase;
  final ClearSearchHistoryUseCase _clearSearchHistoryUseCase;
  
  SearchCubit({
    required SearchUseCase searchUseCase,
    required GetSearchHistoryUseCase getSearchHistoryUseCase,
    required ClearSearchHistoryUseCase clearSearchHistoryUseCase,
  }) : _searchUseCase = searchUseCase,
       _getSearchHistoryUseCase = getSearchHistoryUseCase,
       _clearSearchHistoryUseCase = clearSearchHistoryUseCase,
       super(SearchInitial());

  Future<void> search(String query) async {
    print('🔍 SearchCubit: Starting search for "$query"');
    
    if (query.trim().isEmpty) {
      print('🔍 SearchCubit: Empty query, emitting SearchEmpty');
      emit(SearchEmpty());
      return;
    }

    print('🔍 SearchCubit: Emitting SearchLoading');
    emit(SearchLoading());

    try {
      print('🔍 SearchCubit: Calling SearchUseCase...');
      final result = await _searchUseCase.call(params: query);
      
      print('🔍 SearchCubit: UseCase returned result');
      
      result.fold(
        (failure) {
          print('❌ SearchCubit: Search failed with error: $failure');
          emit(SearchFailure(message: failure));
        },
        (searchResult) {
          print('✅ SearchCubit: Search successful!');
          print('📊 Songs: ${searchResult.songs.length}');
          print('📊 Artists: ${searchResult.artists.length}');
          print('📊 Albums: ${searchResult.albums.length}');
          print('📊 Playlists: ${searchResult.playlists.length}');
          
          // Debug individual items
          if (searchResult.songs.isNotEmpty) {
            print('🎵 First song: ${searchResult.songs.first.title}');
          }
          if (searchResult.albums.isNotEmpty) {
            print('💿 First album: ${searchResult.albums.first.title}');
          }
          
          emit(SearchSuccess(
            songs: searchResult.songs,
            artists: searchResult.artists,
            albums: searchResult.albums,
            playlists: searchResult.playlists,
          ));
          
          print('✅ SearchCubit: Emitted SearchSuccess state');
        },
      );
    } catch (e) {
      print('❌ SearchCubit: Exception caught: $e');
      emit(SearchFailure(message: e.toString()));
    }
  }

  Future<void> getSearchHistory() async {
    final result = await _getSearchHistoryUseCase.call(params: NoParams());
    
    result.fold(
      (failure) => null, // Handle silently for history
      (history) => emit(SearchHistoryLoaded(history: history)),
    );
  }

  Future<void> clearSearchHistory() async {
    await _clearSearchHistoryUseCase.call(params: NoParams());
    emit(SearchInitial());
  }

  void clearSearch() {
    emit(SearchInitial());
  }

  void reset() {
    emit(SearchInitial());
  }
}