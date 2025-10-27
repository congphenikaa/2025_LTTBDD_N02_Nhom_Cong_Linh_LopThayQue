import 'package:app_nghenhac/domain/entities/search/playlist.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistEntity>> getPlaylists({int limit = 20});
}