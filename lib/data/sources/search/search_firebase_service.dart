import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';
import 'package:app_nghenhac/data/models/search/album.dart';
import 'package:app_nghenhac/data/models/search/artist.dart';
import 'package:app_nghenhac/data/models/search/playlist.dart';
import 'package:app_nghenhac/data/models/search/search_result.dart';
import 'package:app_nghenhac/data/models/search/song.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SearchFirebaseService {
  Future<SearchResultModel> search(String query);
  Future<List<String>> getSearchSuggestions(String query);
}

class SearchFirebaseServiceImpl extends SearchFirebaseService {
  final FirebaseFirestore _firestore;

  SearchFirebaseServiceImpl({required FirebaseFirestore firestore}) 
      : _firestore = firestore;

  @override
  Future<SearchResultModel> search(String query) async {
    try {
      final String searchQuery = query.toLowerCase().trim();
      
      // Parallel search across all collections
      final results = await Future.wait([
        _searchSongs(searchQuery),
        _searchArtists(searchQuery),
        _searchAlbums(searchQuery),
        _searchPlaylists(searchQuery),
      ]);

      final songs = results[0] as List<SongModel>;
      final artists = results[1] as List<ArtistModel>;
      final albums = results[2] as List<AlbumModel>;
      final playlists = results[3] as List<PlaylistModel>;

      return SearchResultModel(
        songs: songs,
        artists: artists,
        albums: albums,
        playlists: playlists,
        query: query,
        totalResults: songs.length + artists.length + albums.length + playlists.length,
      );
    } catch (e) {
      throw Exception('Failed to search: ${e.toString()}');
    }
  }

  Future<List<SongModel>> _searchSongs(String query) async {
    try {
      print('🎵 Searching songs with query: "$query"');
      
      // Search queries
      final titleQuery = await _firestore
          .collection('songs')
          .where('title_lowercase', isGreaterThanOrEqualTo: query)
          .where('title_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      final artistQuery = await _firestore
          .collection('songs')
          .where('artist_lowercase', isGreaterThanOrEqualTo: query) 
          .where('artist_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      // Process results
      final Set<String> seenIds = {};
      final List<SongModel> songsWithoutUrls = [];

      for (final doc in [...titleQuery.docs, ...artistQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          try {
            final songData = {
              'id': doc.id,
              ...doc.data(),
            };
            
            songsWithoutUrls.add(SongModel.fromJson(songData));
          } catch (e) {
            print('❌ Error creating SongModel: $e');
          }
        }
      }

      // Load URLs for all songs
      final songsWithUrls = await _loadUrlsForSongs(songsWithoutUrls);
      
      print('🎵 Final songs count: ${songsWithUrls.length}');
      return songsWithUrls;
    } catch (e) {
      print('❌ Error searching songs: $e');
      return [];
    }
  }

  Future<List<SongModel>> _loadUrlsForSongs(List<SongModel> songs) async {
    if (songs.isEmpty) return songs;
    
    try {
      final storageService = sl<FirebaseStorageService>();
      
      // Collect all storage paths
      final List<String> allPaths = [];
      for (final song in songs) {
        if (song.coverStoragePath != null) allPaths.add(song.coverStoragePath!);
        if (song.audioStoragePath != null) allPaths.add(song.audioStoragePath!);
      }
      
      if (allPaths.isEmpty) return songs;
      
      print('📁 Loading ${allPaths.length} URLs...');
      
      // Get all URLs at once
      final urlMap = await storageService.getDownloadUrls(allPaths);
      
      // Update songs with URLs
      final List<SongModel> updatedSongs = [];
      for (final song in songs) {
        updatedSongs.add(song.copyWith(
          coverUrl: song.coverStoragePath != null 
              ? urlMap[song.coverStoragePath!] 
              : null,
          audioUrl: song.audioStoragePath != null 
              ? urlMap[song.audioStoragePath!] 
              : null,
        ));
      }
      
      print('✅ URLs loaded successfully');
      return updatedSongs;
    } catch (e) {
      print('❌ Error loading URLs: $e');
      return songs; // Return without URLs if error
    }
  }

  Future<List<ArtistModel>> _searchArtists(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('artists')
          .where('name_lowercase', isGreaterThanOrEqualTo: query)
          .where('name_lowercase', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) => ArtistModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error searching artists: ${e.toString()}');
      return [];
    }
  }

  Future<List<AlbumModel>> _searchAlbums(String query) async {
  try {
    print('🎵 Searching albums with query: "$query"');
    
    // Search by album title
    final titleQuery = await _firestore
        .collection('albums')
        .where('title_lowercase', isGreaterThanOrEqualTo: query)
        .where('title_lowercase', isLessThan: query + '\uf8ff')
        .limit(10)
        .get();

    // Search by artist name
    final artistQuery = await _firestore
        .collection('albums')
        .where('artist_lowercase', isGreaterThanOrEqualTo: query)
        .where('artist_lowercase', isLessThan: query + '\uf8ff')
        .limit(10)
        .get();

    // Combine and remove duplicates
    final Set<String> seenIds = {};
    final List<AlbumModel> albums = [];

    for (final doc in [...titleQuery.docs, ...artistQuery.docs]) {
      if (!seenIds.contains(doc.id)) {
        seenIds.add(doc.id);
        try {
          final albumData = {
            'id': doc.id,
            ...doc.data(),
          };
          albums.add(AlbumModel.fromJson(albumData));
          print('✅ Successfully created AlbumModel for: ${albumData['title']}');
        } catch (e) {
          print('❌ Error creating AlbumModel: $e');
          print('❌ Raw album data: ${doc.data()}');
          // Continue với albums khác thay vì crash
        }
      }
    }

    print('🎵 Final albums count: ${albums.length}');
    return albums;
  } catch (e) {
    print('❌ Error searching albums: $e');
    return [];
  }
}

Future<List<PlaylistModel>> _searchPlaylists(String query) async {
  try {
    print('🎵 Searching playlists with query: "$query"');
    
    final String lowerQuery = query.toLowerCase();
    final List<String> searchTerms = lowerQuery.split(' ').where((term) => term.isNotEmpty).toList();
    
    final querySnapshot = await _firestore
        .collection('playlists')
        .where('is_public', isEqualTo: true)
        .limit(50)
        .get();

    final List<PlaylistModel> playlists = [];
    
    for (final doc in querySnapshot.docs) {
      try {
        final data = doc.data();
        final nameLowercase = data['name_lowercase'] as String? ?? '';
        final description = (data['description'] as String? ?? '').toLowerCase();
        final creatorName = (data['creator_name'] as String? ?? '').toLowerCase();
        
        // ✅ Tìm kiếm từng term trong query
        bool matches = searchTerms.any((term) => 
          nameLowercase.contains(term) || 
          description.contains(term) || 
          creatorName.contains(term)
        );
        
        if (matches) {
          final playlistData = {
            'id': doc.id,
            ...data,
          };
          playlists.add(PlaylistModel.fromJson(playlistData));
          print('✅ Found playlist: ${data['name']}');
          
          if (playlists.length >= 10) break;
        }
      } catch (e) {
        print('❌ Error processing playlist: $e');
      }
    }

    print('🎵 Final playlists count: ${playlists.length}');
    return playlists;
  } catch (e) {
    print('❌ Error searching playlists: $e');
    return [];
  }
}

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final String searchQuery = query.toLowerCase().trim();
      
      if (searchQuery.isEmpty) return [];

      // Get suggestions from popular searches or recent queries
      final querySnapshot = await _firestore
          .collection('search_suggestions')
          .where('term', isGreaterThanOrEqualTo: searchQuery)
          .where('term', isLessThan: searchQuery + '\uf8ff')
          .orderBy('term')
          .orderBy('popularity', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['term'] as String)
          .toList();
    } catch (e) {
      print('Error getting suggestions: ${e.toString()}');
      // Return empty list on error for suggestions
      return [];
    }
  }
} // Đóng class ở đây