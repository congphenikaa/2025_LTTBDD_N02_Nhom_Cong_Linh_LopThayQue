import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artists.dart';
import 'package:app_nghenhac/presentation/home/bloc/artists_state.dart';

class ArtistsCubit extends Cubit<ArtistsState> {
  final GetArtistsUseCase getArtistsUseCase;

  ArtistsCubit({required this.getArtistsUseCase}) : super(ArtistsLoading());

  Future<void> getArtists({int limit = 20}) async {
    print('🎯 ArtistsCubit: Starting to fetch artists with limit: $limit');
    
    try {
      emit(ArtistsLoading());
      
      var artists = await getArtistsUseCase.call(limit: limit);
      
      print('📊 ArtistsCubit: Successfully received ${artists.length} artists');
      emit(ArtistsLoaded(artists: artists));
      
    } catch (e) {
      print('💥 ArtistsCubit: Error occurred: $e');
      emit(ArtistsLoadFailure(errorMessage: e.toString()));
    }
  }
}