import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/data/models/search/song.dart';
import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';

abstract class SongSearchService {
  Future<List<SongEntity>> getSongsByArtist(String artistId);
}

class SongSearchServiceImpl implements SongSearchService {
  final FirebaseFirestore _firestore;
  final FirebaseStorageService _storageService;

  SongSearchServiceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorageService storageService,
  }) : _firestore = firestore,
       _storageService = storageService;

  @override
  Future<List<SongEntity>> getSongsByArtist(String artistId) async {
    try {
      print('🔍 SongSearchService: Fetching songs for artistId: $artistId');
      
      // Query songs by artistId (more efficient than name)
      final querySnapshot = await _firestore
          .collection('songs')
          .where('artist_id', isEqualTo: artistId)
          .get();

      print('📊 SongSearchService: Found ${querySnapshot.docs.length} songs for artist');

      final List<SongEntity> songs = [];
      
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          print('🎵 Processing song: ${data['title'] ?? 'Unknown'}');
          
          // Determine which field contains the storage path
          String? storagePath;
          if (data['cover_storage_path'] != null && data['cover_storage_path'].toString().isNotEmpty) {
            storagePath = data['cover_storage_path'];
          } else if (data['cover_url'] != null && 
                     data['cover_url'].toString().isNotEmpty && 
                     !data['cover_url'].toString().startsWith('http')) {
            storagePath = data['cover_url'];
          }
          
          // Convert Firebase Storage path to download URL if needed
          String? finalCoverUrl = data['cover_url'];
          if (storagePath != null) {
            print('🔄 Converting storage path to download URL: $storagePath');
            finalCoverUrl = await _storageService.getDownloadUrl(storagePath);
            print('✅ Final Cover URL: ${finalCoverUrl?.substring(0, 50)}...');
          }
          
          final songData = {
            'id': doc.id,
            ...data,
            'cover_url': finalCoverUrl,
          };
          
          final songModel = SongModel.fromJson(songData);
          final songEntity = songModel.toEntity();
          songs.add(songEntity);
          
          print('✅ Successfully added song: ${songEntity.title}');
        } catch (e) {
          print('❌ Error processing song ${doc.id}: $e');
          continue;
        }
      }

      print('🏁 SongSearchService: Successfully loaded ${songs.length} songs for artist');
      
      // Sort by release date in memory
      songs.sort((a, b) {
        if (a.releaseDate == null && b.releaseDate == null) return 0;
        if (a.releaseDate == null) return 1;
        if (b.releaseDate == null) return -1;
        return b.releaseDate!.compareTo(a.releaseDate!);
      });
      
      return songs;
      
    } catch (e) {
      print('💥 SongSearchService: Error fetching songs for artist: $e');
      return [];
    }
  }
}