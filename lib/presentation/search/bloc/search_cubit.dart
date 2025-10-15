import 'package:app_nghenhac/domain/usecases/search/clear_search_history.dart';
import 'package:app_nghenhac/domain/usecases/search/get_search_history.dart';
import 'package:app_nghenhac/domain/usecases/search/save_search_query_usecase.dart';
import 'package:app_nghenhac/domain/usecases/search/search.dart'; // Thêm import này
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchUseCase _searchUseCase;
  final GetSearchHistoryUseCase _getSearchHistoryUseCase;
  final ClearSearchHistoryUseCase _clearSearchHistoryUseCase;
  final SaveSearchQueryUseCase _saveSearchQueryUseCase; // Thêm này
  
  SearchCubit({
    required SearchUseCase searchUseCase,
    required GetSearchHistoryUseCase getSearchHistoryUseCase,
    required ClearSearchHistoryUseCase clearSearchHistoryUseCase,
    required SaveSearchQueryUseCase saveSearchQueryUseCase, // Thêm này
  }) : _searchUseCase = searchUseCase,
       _getSearchHistoryUseCase = getSearchHistoryUseCase,
       _clearSearchHistoryUseCase = clearSearchHistoryUseCase,
       _saveSearchQueryUseCase = saveSearchQueryUseCase, // Thêm này
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
      
      print('🔍 SearchCubit: UseCase call completed');
      
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
          
          // Check if any results found
          if (searchResult.songs.isEmpty && 
              searchResult.artists.isEmpty && 
              searchResult.albums.isEmpty && 
              searchResult.playlists.isEmpty) {
            emit(SearchEmpty());
          } else {
            emit(SearchSuccess(
              songs: searchResult.songs,        // ✅ Đúng type: List<SongEntity>
              artists: searchResult.artists,    // ✅ Đúng type: List<ArtistEntity>
              albums: searchResult.albums,      // ✅ Đúng type: List<AlbumEntity>
              playlists: searchResult.playlists, // ✅ Đúng type: List<PlaylistEntity>
            ));
          }
          
          print('✅ SearchCubit: Emitted SearchSuccess state');
        },
      );
    } catch (e) {
      print('❌ SearchCubit: Exception caught: $e');
      emit(SearchFailure(message: e.toString()));
    }
  }

  Future<void> loadSearchHistory() async {
    try {
      print('🔍 SearchCubit: Loading search history...');
      final result = await _getSearchHistoryUseCase.call();
      
      result.fold(
        (failure) {
          print('❌ Failed to load search history: $failure');
          emit(SearchHistoryLoaded(history: [])); // ✅ Đúng parameter name
        },
        (historyList) {
          print('✅ Search history loaded: ${historyList.length} items');
          emit(SearchHistoryLoaded(history: historyList)); // ✅ Đúng parameter name
        },
      );
    } catch (e) {
      print('❌ Exception loading search history: $e');
      emit(SearchHistoryLoaded(history: [])); // ✅ Đúng parameter name
    }
  }

  Future<void> saveSearchQuery(String query) async {
    try {
      print('🔍 SearchCubit: Saving search query: "$query"');
      final result = await _saveSearchQueryUseCase.call(params: query);
      
      result.fold(
        (failure) => print('❌ Failed to save search query: $failure'),
        (_) => print('✅ Search query saved successfully'),
      );
    } catch (e) {
      print('❌ Exception saving search query: $e');
    }
  }

  Future<void> removeSearchHistoryItem(String query) async {
    try {
      print('🔍 SearchCubit: Removing search history item: "$query"');
      
      // Get current history
      final historyResult = await _getSearchHistoryUseCase.call();
      
      historyResult.fold(
        (failure) => print('❌ Failed to get history for removal'),
        (currentHistory) async {
          // Remove the specific item
          final updatedHistory = currentHistory.where((item) => item != query).toList();
          
          // Clear all history first
          await _clearSearchHistoryUseCase.call();
          
          // Add back remaining items
          for (final item in updatedHistory.reversed) {
            await _saveSearchQueryUseCase.call(params: item);
          }
          
          // Reload history to update UI
          emit(SearchHistoryLoaded(history: updatedHistory)); // ✅ Đúng parameter name
          print('✅ Search history item removed and updated');
        },
      );
    } catch (e) {
      print('❌ Exception removing search history item: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      print('🔍 SearchCubit: Clearing all search history...');
      final result = await _clearSearchHistoryUseCase.call();
      
      result.fold(
        (failure) {
          print('❌ Failed to clear search history: $failure');
          emit(SearchFailure(message: failure)); // ✅ Đúng parameter name
        },
        (_) {
          print('✅ Search history cleared');
          emit(SearchHistoryLoaded(history: [])); // ✅ Đúng parameter name
        },
      );
    } catch (e) {
      print('❌ Exception clearing search history: $e');
      emit(SearchFailure(message: e.toString())); // ✅ Đúng parameter name
    }
  }

  void clearSearch() {
    print('🔍 SearchCubit: Clearing search, back to initial state');
    emit(SearchInitial());
  }
}