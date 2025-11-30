import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/data/models/search/song.dart';
import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';

abstract class SongSearchService {
  Future<List<SongEntity>> getSongsByArtist(String artistId);
  Future<List<SongEntity>> getSongsByAlbum(String albumId);
  Future<List<SongEntity>> getSongsByPlaylist(String playlistId);
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
          
          // Determine which field contains the cover storage path
          String? coverStoragePath;
          if (data['cover_storage_path'] != null && data['cover_storage_path'].toString().isNotEmpty) {
            coverStoragePath = data['cover_storage_path'];
          } else if (data['cover_url'] != null && 
                     data['cover_url'].toString().isNotEmpty && 
                     !data['cover_url'].toString().startsWith('http')) {
            coverStoragePath = data['cover_url'];
          }
          
          // Determine which field contains the audio storage path
          String? audioStoragePath;
          if (data['audio_storage_path'] != null && data['audio_storage_path'].toString().isNotEmpty) {
            audioStoragePath = data['audio_storage_path'];
          } else if (data['audio_url'] != null && 
                     data['audio_url'].toString().isNotEmpty && 
                     !data['audio_url'].toString().startsWith('http')) {
            audioStoragePath = data['audio_url'];
          }
          
          // Convert Firebase Storage path to download URL if needed
          String? finalCoverUrl = data['cover_url'];
          if (coverStoragePath != null) {
            print('🔄 Converting cover storage path to download URL: $coverStoragePath');
            finalCoverUrl = await _storageService.getDownloadUrl(coverStoragePath);
            print('✅ Final Cover URL: ${finalCoverUrl?.substring(0, 50)}...');
          }
          
          String? finalAudioUrl = data['audio_url'];
          if (audioStoragePath != null) {
            print('🔄 Converting audio storage path to download URL: $audioStoragePath');
            finalAudioUrl = await _storageService.getDownloadUrl(audioStoragePath);
            print('✅ Final Audio URL: ${finalAudioUrl?.substring(0, 50)}...');
          }
          
          final songData = {
            'id': doc.id,
            ...data,
            'cover_url': finalCoverUrl,
            'audio_url': finalAudioUrl,
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

  @override
  Future<List<SongEntity>> getSongsByAlbum(String albumId) async {
    try {
      print('🔍 SongSearchService: Fetching songs for albumId: $albumId');
      
      // Query songs by albumId
      final querySnapshot = await _firestore
          .collection('songs')
          .where('album_id', isEqualTo: albumId)
          .get();

      print('📊 SongSearchService: Found ${querySnapshot.docs.length} songs for album');

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
          
          // Handle audio URL similarly
          String? audioStoragePath;
          if (data['audio_storage_path'] != null && data['audio_storage_path'].toString().isNotEmpty) {
            audioStoragePath = data['audio_storage_path'];
          } else if (data['audio_url'] != null && 
                     data['audio_url'].toString().isNotEmpty && 
                     !data['audio_url'].toString().startsWith('http')) {
            audioStoragePath = data['audio_url'];
          }
          
          String? finalAudioUrl = data['audio_url'];
          if (audioStoragePath != null) {
            print('🔄 Converting audio storage path to download URL: $audioStoragePath');
            finalAudioUrl = await _storageService.getDownloadUrl(audioStoragePath);
            print('✅ Final Audio URL: ${finalAudioUrl?.substring(0, 50)}...');
          }
          
          final songData = {
            'id': doc.id,
            ...data,
            'cover_url': finalCoverUrl,
            'audio_url': finalAudioUrl,
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

      print('🏁 SongSearchService: Successfully loaded ${songs.length} songs for album');
      
      // Sort by track number if available, otherwise by title
      songs.sort((a, b) {
        // If we had track numbers, we'd use them here
        // For now, sort alphabetically by title
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
      
      return songs;
      
    } catch (e) {
      print('💥 SongSearchService: Error fetching songs for album: $e');
      return [];
    }
  }

  @override
  Future<List<SongEntity>> getSongsByPlaylist(String playlistId) async {
    try {
      print('🔍 SongSearchService: Fetching all songs for playlist display');
      
      // Query all songs from songs collection (since we don't have playlist_songs collection)
      final querySnapshot = await _firestore
          .collection('songs')
          .get();

      print('📊 SongSearchService: Found ${querySnapshot.docs.length} songs in database');

      final List<SongEntity> songs = [];
      
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          print('🎵 Processing song: ${data['title'] ?? 'Unknown'}');
          
          // Determine which field contains the cover storage path
          String? coverStoragePath;
          if (data['cover_storage_path'] != null && data['cover_storage_path'].toString().isNotEmpty) {
            coverStoragePath = data['cover_storage_path'];
          } else if (data['cover_url'] != null && 
                     data['cover_url'].toString().isNotEmpty && 
                     !data['cover_url'].toString().startsWith('http')) {
            coverStoragePath = data['cover_url'];
          }
          
          // Determine which field contains the audio storage path
          String? audioStoragePath;
          if (data['audio_storage_path'] != null && data['audio_storage_path'].toString().isNotEmpty) {
            audioStoragePath = data['audio_storage_path'];
          } else if (data['audio_url'] != null && 
                     data['audio_url'].toString().isNotEmpty && 
                     !data['audio_url'].toString().startsWith('http')) {
            audioStoragePath = data['audio_url'];
          }
          
          // Convert Firebase Storage path to download URL if needed
          String? finalCoverUrl = data['cover_url'];
          if (coverStoragePath != null) {
            print('🔄 Converting cover storage path to download URL: $coverStoragePath');
            finalCoverUrl = await _storageService.getDownloadUrl(coverStoragePath);
            print('✅ Final Cover URL: ${finalCoverUrl?.substring(0, 50)}...');
          }
          
          String? finalAudioUrl = data['audio_url'];
          if (audioStoragePath != null) {
            print('🔄 Converting audio storage path to download URL: $audioStoragePath');
            finalAudioUrl = await _storageService.getDownloadUrl(audioStoragePath);
            print('✅ Final Audio URL: ${finalAudioUrl?.substring(0, 50)}...');
          }
          
          final songData = {
            'id': doc.id,
            ...data,
            'cover_url': finalCoverUrl,
            'audio_url': finalAudioUrl,
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

      print('🏁 SongSearchService: Successfully loaded ${songs.length} songs for playlist');
      
      // Sort by title alphabetically
      songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      
      return songs;
      
    } catch (e) {
      print('💥 SongSearchService: Error fetching songs for playlist: $e');
      return [];
    }
  }
}