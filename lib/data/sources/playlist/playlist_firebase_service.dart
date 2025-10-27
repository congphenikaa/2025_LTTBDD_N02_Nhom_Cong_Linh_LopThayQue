import 'package:app_nghenhac/data/models/search/playlist.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PlaylistFirebaseService {
  Future<List<PlaylistEntity>> getPlaylists({int limit = 20});
}

class PlaylistFirebaseServiceImpl implements PlaylistFirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorageService _storageService;

  PlaylistFirebaseServiceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorageService storageService,
  }) : _firestore = firestore,
       _storageService = storageService {
    print('🔧 PlaylistFirebaseServiceImpl constructor called - NEW IMPLEMENTATION');
  }

  @override
  Future<List<PlaylistEntity>> getPlaylists({int limit = 20}) async {
    try {
      print('🔍 PlaylistFirebaseService: Fetching $limit playlists from Firestore...');
      
      // Tạm thời bỏ orderBy để tránh lỗi index, chỉ filter is_public
      final querySnapshot = await _firestore
          .collection('playlists')
          .where('is_public', isEqualTo: true)
          .limit(limit)
          .get();

      print('📊 PlaylistFirebaseService: Found ${querySnapshot.docs.length} documents');

      final List<PlaylistEntity> playlists = [];
      
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          print('🎵 Processing playlist: ${data['name'] ?? 'Unknown'}');
          print('🖼️ Cover URL: ${data['cover_url']}');
          print('📁 Cover Storage Path: ${data['cover_storage_path']}');
          
          // Determine which field contains the storage path (like in search service)
          String? storagePath;
          if (data['cover_storage_path'] != null && data['cover_storage_path'].toString().isNotEmpty) {
            storagePath = data['cover_storage_path'];
          } else if (data['cover_url'] != null && 
                     data['cover_url'].toString().isNotEmpty && 
                     !data['cover_url'].toString().startsWith('http') && 
                     !data['cover_url'].toString().startsWith('https')) {
            storagePath = data['cover_url'];
          }
          
          // Convert Firebase Storage path to download URL if needed
          String? finalCoverUrl = data['cover_url'];
          if (storagePath != null) {
            print('🔄 Converting storage path to download URL: $storagePath');
            finalCoverUrl = await _storageService.getDownloadUrl(storagePath);
            print('✅ Final Cover URL: ${finalCoverUrl?.substring(0, 50)}...');
          }
          
          final playlistData = {
            'id': doc.id,
            ...data,
            'cover_url': finalCoverUrl, // Use converted URL
          };
          
          final playlistModel = PlaylistModel.fromJson(playlistData);
          final playlistEntity = playlistModel.toEntity();
          playlists.add(playlistEntity);
          
          print('✅ Successfully added playlist: ${playlistEntity.name}');
        } catch (e) {
          print('❌ Error processing playlist ${doc.id}: $e');
          continue;
        }
      }

      // Sắp xếp trong code thay vì Firestore query để tránh cần index
      playlists.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return 0;
      });

      print('🏁 PlaylistFirebaseService: Successfully loaded ${playlists.length} playlists');
      return playlists;
      
    } catch (e) {
      print('💥 PlaylistFirebaseService: Error loading playlists: $e');
      throw Exception('Failed to load playlists: ${e.toString()}');
    }
  }
}