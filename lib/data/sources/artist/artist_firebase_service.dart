import 'package:app_nghenhac/data/models/search/artist.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ArtistFirebaseService {
  Future<List<ArtistEntity>> getArtists({int limit = 20});
}

class ArtistFirebaseServiceImpl implements ArtistFirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorageService _storageService;

  ArtistFirebaseServiceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorageService storageService,
  }) : _firestore = firestore,
       _storageService = storageService {
    print('🔧 ArtistFirebaseServiceImpl constructor called');
  }

  @override
  Future<List<ArtistEntity>> getArtists({int limit = 20}) async {
    try {
      print('🔍 ArtistFirebaseService: Fetching $limit artists from Firestore...');
      
      final querySnapshot = await _firestore
          .collection('artists')
          .orderBy('followers', descending: true) // Sắp xếp theo followers
          .limit(limit)
          .get();

      print('📊 ArtistFirebaseService: Found ${querySnapshot.docs.length} documents');

      final List<ArtistEntity> artists = [];
      
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          print('🎤 Processing artist: ${data['name'] ?? 'Unknown'}');
          print('🖼️ Image URL: ${data['image_url']}');
          print('📁 Image Storage Path: ${data['image_storage_path']}');
          
          // Determine which field contains the storage path (like in search service)
          String? storagePath;
          if (data['image_storage_path'] != null && data['image_storage_path'].toString().isNotEmpty) {
            storagePath = data['image_storage_path'];
          } else if (data['image_url'] != null && 
                     data['image_url'].toString().isNotEmpty && 
                     !data['image_url'].toString().startsWith('http') && 
                     !data['image_url'].toString().startsWith('https')) {
            storagePath = data['image_url'];
          }
          
          // Convert Firebase Storage path to download URL if needed
          String? finalImageUrl = data['image_url'];
          if (storagePath != null) {
            print('🔄 Converting storage path to download URL: $storagePath');
            finalImageUrl = await _storageService.getDownloadUrl(storagePath);
            print('✅ Final Image URL: ${finalImageUrl?.substring(0, 50)}...');
          }
          
          final artistData = {
            'id': doc.id,
            ...data,
            'image_url': finalImageUrl, // Use converted URL
          };
          
          final artistModel = ArtistModel.fromJson(artistData);
          final artistEntity = artistModel.toEntity();
          artists.add(artistEntity);
          
          print('✅ Successfully added artist: ${artistEntity.name}');
        } catch (e) {
          print('❌ Error processing artist ${doc.id}: $e');
          continue;
        }
      }

      print('🏁 ArtistFirebaseService: Successfully loaded ${artists.length} artists');
      return artists;
      
    } catch (e) {
      print('💥 ArtistFirebaseService: Error fetching artists: $e');
      return [];
    }
  }
}