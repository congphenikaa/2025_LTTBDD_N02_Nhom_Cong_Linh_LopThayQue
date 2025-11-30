
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseStorageService {
  Future<String?> getDownloadUrl(String storagePath);
  Future<Map<String, String?>> getDownloadUrls(List<String> paths);
}

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      print('📁 Getting download URL for: $storagePath');
      final ref = _storage.ref(storagePath);
      final url = await ref.getDownloadURL();
      print('✅ Got URL: ${url.substring(0, 50)}...');
      return url;
    } catch (e) {
      print('❌ Error getting download URL for $storagePath: $e');
      return null;
    }
  }

  @override
  Future<Map<String, String?>> getDownloadUrls(List<String> paths) async {
    final Map<String, String?> results = {};
    
    print('📁 Getting ${paths.length} download URLs...');
    
    await Future.wait(paths.map((path) async {
      results[path] = await getDownloadUrl(path);
    }));
    
    return results;
  }
}