import 'package:app_nghenhac/data/sources/playlist/playlist_firebase_service.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:app_nghenhac/domain/repository/playlist/playlist.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistFirebaseService _playlistFirebaseService;

  PlaylistRepositoryImpl({required PlaylistFirebaseService playlistFirebaseService}) 
      : _playlistFirebaseService = playlistFirebaseService {
    print('🔧 PlaylistRepositoryImpl constructor called - USING DATA SOURCE');
  }

  @override
  Future<List<PlaylistEntity>> getPlaylists({int limit = 20}) async {
    try {
      print('🔍 [PlaylistRepository] Delegating to PlaylistFirebaseService with limit: $limit');
      
      final playlists = await _playlistFirebaseService.getPlaylists(limit: limit);
      
      print('� [PlaylistRepository] Received ${playlists.length} playlists from service');
      return playlists;
      
    } catch (e) {
      print('💥 [PlaylistRepository] Error fetching playlists: $e');
      return [];
    }
  }
}