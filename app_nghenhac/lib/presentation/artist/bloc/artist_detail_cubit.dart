import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artist_details.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artist_albums.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artist_songs.dart';
import 'package:app_nghenhac/presentation/artist/bloc/artist_detail_state.dart';

class ArtistDetailCubit extends Cubit<ArtistDetailState> {
  final GetArtistDetailsUseCase getArtistDetailsUseCase;
  final GetArtistAlbumsUseCase getArtistAlbumsUseCase;
  final GetArtistSongsUseCase getArtistSongsUseCase;

  ArtistDetailCubit({
    required this.getArtistDetailsUseCase,
    required this.getArtistAlbumsUseCase,
    required this.getArtistSongsUseCase,
  }) : super(ArtistDetailLoading());

  Future<void> loadArtistDetail(String artistId) async {
    print('🎯 ArtistDetailCubit: Starting to load artist detail for: $artistId');
    
    try {
      emit(ArtistDetailLoading());
      
      // First get artist details to get the name
      final artist = await getArtistDetailsUseCase.call(artistId);
      
      if (artist != null) {
        print('🎤 Found artist: ${artist.name} with ID: ${artist.id}');
        
        // Use artist ID for albums and songs queries (foreign key relationship)
        final results = await Future.wait([
          getArtistAlbumsUseCase.call(artist.id),
          getArtistSongsUseCase.call(artist.id),
        ]);
        
        final albums = results[0] as List<AlbumEntity>;
        final songs = results[1] as List<SongEntity>;
        
        print('📊 ArtistDetailCubit: Successfully loaded - Artist: ${artist.name}, Albums: ${albums.length}, Songs: ${songs.length}');
        emit(ArtistDetailLoaded(
          artist: artist,
          albums: albums,
          songs: songs,
        ));
      } else {
        print('❌ ArtistDetailCubit: Artist not found');
        emit(ArtistDetailFailure(errorMessage: 'Artist not found'));
      }
      
    } catch (e) {
      print('💥 ArtistDetailCubit: Error occurred: $e');
      emit(ArtistDetailFailure(errorMessage: e.toString()));
    }
  }
}