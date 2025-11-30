import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class SearchLocalService {
  Future<List<String>> getSearchHistory();
  Future<void> saveSearchQuery(String query);
  Future<void> clearSearchHistory();
}

class SearchLocalServiceImpl extends SearchLocalService {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 20;

  @override
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_searchHistoryKey);
      
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.cast<String>();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get search history: ${e.toString()}');
    }
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHistory = await getSearchHistory();
      
      // Remove query if it already exists
      currentHistory.remove(query);
      
      // Add query to the beginning
      currentHistory.insert(0, query);
      
      // Limit history size
      if (currentHistory.length > _maxHistoryItems) {
        currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
      }
      
      // Save updated history
      final historyJson = json.encode(currentHistory);
      await prefs.setString(_searchHistoryKey, historyJson);
    } catch (e) {
      throw Exception('Failed to save search query: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      throw Exception('Failed to clear search history: ${e.toString()}');
    }
  }
}