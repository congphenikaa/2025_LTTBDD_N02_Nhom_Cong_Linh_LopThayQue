import 'package:app_nghenhac/data/models/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AlbumFirebaseService {
  Future<List<AlbumEntity>> getAlbums({int limit = 20});
}

class AlbumFirebaseServiceImpl implements AlbumFirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorageService _storageService;

  AlbumFirebaseServiceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorageService storageService,
  }) : _firestore = firestore,
       _storageService = storageService;

  @override
  Future<List<AlbumEntity>> getAlbums({int limit = 20}) async {
    try {
      print('🔍 AlbumFirebaseService: Fetching $limit albums from Firestore...');
      
      final querySnapshot = await _firestore
          .collection('albums')
          .orderBy('release_date', descending: true)
          .limit(limit)
          .get();

      print('📊 AlbumFirebaseService: Found ${querySnapshot.docs.length} documents');

      final List<AlbumEntity> albums = [];
      
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          print('💿 Processing album: ${data['title'] ?? 'Unknown'}');
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
          
          final albumData = {
            'id': doc.id,
            ...data,
            'cover_url': finalCoverUrl, // Use converted URL
          };
          
          final albumModel = AlbumModel.fromJson(albumData);
          final albumEntity = albumModel.toEntity();
          albums.add(albumEntity);
          
          print('✅ Successfully added album: ${albumEntity.title}');
        } catch (e) {
          print('❌ Error processing album ${doc.id}: $e');
          continue;
        }
      }

      print('🏁 AlbumFirebaseService: Successfully loaded ${albums.length} albums');
      return albums;
      
    } catch (e) {
      print('💥 AlbumFirebaseService: Error loading albums: $e');
      throw Exception('Failed to load albums: ${e.toString()}');
    }
  }
}