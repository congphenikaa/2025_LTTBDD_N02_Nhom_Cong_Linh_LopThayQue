import 'package:app_nghenhac/common/helpers/firebase_storage_service.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/data/repository/auth/auth_repository_impl.dart';
import 'package:app_nghenhac/data/repository/search/search_repository_impl.dart';
import 'package:app_nghenhac/data/repository/song/song_repository_impl.dart';
import 'package:app_nghenhac/data/sources/auth/auth_firebase_service.dart';
import 'package:app_nghenhac/data/sources/search/search_firebase_service.dart';
import 'package:app_nghenhac/data/sources/search/search_local_service.dart';
import 'package:app_nghenhac/data/sources/song/song_firebase_service.dart';
import 'package:app_nghenhac/data/sources/album/album_firebase_service.dart';
import 'package:app_nghenhac/data/sources/playlist/playlist_firebase_service.dart';
import 'package:app_nghenhac/data/sources/artist/artist_firebase_service.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/domain/repository/search/search.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';
import 'package:app_nghenhac/domain/usecases/auth/get_user.dart';
import 'package:app_nghenhac/domain/usecases/auth/signin.dart';
import 'package:app_nghenhac/domain/usecases/auth/signup.dart';
import 'package:app_nghenhac/domain/usecases/auth/syncGoogleUser.dart';
import 'package:app_nghenhac/domain/usecases/search/clear_search_history.dart';
import 'package:app_nghenhac/domain/usecases/search/get_search_history.dart';
import 'package:app_nghenhac/domain/usecases/search/get_search_suggestion.dart';
import 'package:app_nghenhac/domain/usecases/search/save_search_query_usecase.dart';
import 'package:app_nghenhac/domain/usecases/search/search.dart';
import 'package:app_nghenhac/domain/usecases/song/add_or_remove_favorite_song.dart';
import 'package:app_nghenhac/domain/usecases/song/get_favorite_songs.dart';
import 'package:app_nghenhac/domain/usecases/song/get_news_songs.dart';
import 'package:app_nghenhac/domain/usecases/song/get_play_list.dart';
import 'package:app_nghenhac/domain/usecases/song/get_playlist_songs.dart';
import 'package:app_nghenhac/domain/usecases/song/is_favorite_song.dart';
import 'package:app_nghenhac/domain/usecases/album/get_albums.dart';
import 'package:app_nghenhac/domain/usecases/album/get_album_details.dart';
import 'package:app_nghenhac/domain/usecases/album/get_songs_by_album.dart';
import 'package:app_nghenhac/domain/usecases/playlist/get_playlists.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artists.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artist_details.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artist_albums.dart';
import 'package:app_nghenhac/domain/usecases/artist/get_artist_songs.dart';
import 'package:app_nghenhac/domain/repository/album/album.dart';
import 'package:app_nghenhac/domain/repository/playlist/playlist.dart';
import 'package:app_nghenhac/domain/repository/artist/artist.dart';
import 'package:app_nghenhac/data/repository/album/album_repository_impl.dart';
import 'package:app_nghenhac/data/repository/playlist/playlist_repository_impl.dart';
import 'package:app_nghenhac/data/repository/artist/artist_repository_impl.dart';
import 'package:app_nghenhac/data/sources/song/song_search_service.dart';
import 'package:app_nghenhac/presentation/search/bloc/search_cubit.dart';
import 'package:app_nghenhac/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:app_nghenhac/presentation/home/bloc/artists_cubit.dart';
import 'package:app_nghenhac/presentation/artist/bloc/artist_detail_cubit.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:app_nghenhac/presentation/playlist/bloc/playlist_detail_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Firebase
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Google Sign-In Service
  sl.registerSingleton<GoogleSignInService>(GoogleSignInService());

  // Data sources
  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl()
  );

  sl.registerSingleton<SongFirebaseService>(
    SongFirebaseServiceImpl()
  );

  sl.registerSingleton<SearchFirebaseService>(
    SearchFirebaseServiceImpl(firestore: sl<FirebaseFirestore>())
  );
  
  sl.registerSingleton<SearchLocalService>(
    SearchLocalServiceImpl()
  );

  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageServiceImpl()
  );

  // Album & Playlist Firebase Services
  sl.registerSingleton<AlbumFirebaseService>(
    AlbumFirebaseServiceImpl(
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    )
  );

  sl.registerSingleton<PlaylistFirebaseService>(
    PlaylistFirebaseServiceImpl(
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    )
  );

  sl.registerSingleton<ArtistFirebaseService>(
    ArtistFirebaseServiceImpl(
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    )
  );

  // Song Search Service for Artist Detail
  sl.registerSingleton<SongSearchService>(
    SongSearchServiceImpl(
      firestore: sl<FirebaseFirestore>(),
      storageService: sl<FirebaseStorageService>(),
    )
  );

  // Repositories - Đăng ký cả interface và implementation
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl()
  );

  // Sửa: Đăng ký SongRepositoryImpl
  sl.registerSingleton<SongRepositoryImpl>(
    SongRepositoryImpl()
  );
  
  // Đăng ký interface SongsRepository trỏ đến implementation
  sl.registerSingleton<SongsRepository>(
    sl<SongRepositoryImpl>()
  );

  sl.registerSingleton<SearchRepository>(
    SearchRepositoryImpl(
      firebaseService: sl<SearchFirebaseService>(),
      localService: sl<SearchLocalService>(),
    )
  );

  // Album & Playlist Repositories
  sl.registerSingleton<AlbumRepository>(
    AlbumRepositoryImpl(albumFirebaseService: sl<AlbumFirebaseService>())
  );

  sl.registerSingleton<PlaylistRepository>(
    PlaylistRepositoryImpl(playlistFirebaseService: sl<PlaylistFirebaseService>())
  );

  sl.registerSingleton<ArtistRepository>(
    ArtistRepositoryImpl(artistFirebaseService: sl<ArtistFirebaseService>())
  );

  // Use cases - Auth
  sl.registerSingleton<SignupUseCase>(
    SignupUseCase()
  );

  sl.registerSingleton<SigninUseCase>(
    SigninUseCase()
  );

  sl.registerSingleton<SyncGoogleUserUseCase>(
    SyncGoogleUserUseCase()
  );

  sl.registerSingleton<GetUserUseCase>(
    GetUserUseCase()
  );

  // Use cases - Song
  sl.registerSingleton<GetNewsSongsUseCase>(
    GetNewsSongsUseCase()
  );

  sl.registerSingleton<GetPlayListUseCase>(
    GetPlayListUseCase()
  );

  sl.registerSingleton<GetPlaylistSongsUseCase>(
    GetPlaylistSongsUseCase()
  );

  sl.registerSingleton<AddOrRemoveFavoriteSongUseCase>(
    AddOrRemoveFavoriteSongUseCase()
  );

  sl.registerSingleton<IsFavoriteSongUseCase>(
    IsFavoriteSongUseCase()
  );

  sl.registerSingleton<GetFavoriteSongsUseCase>(
    GetFavoriteSongsUseCase()
  );

  // Use cases - Album & Playlist
  sl.registerSingleton<GetAlbumsUseCase>(
    GetAlbumsUseCase(repository: sl<AlbumRepository>())
  );

  sl.registerSingleton<GetAlbumDetailsUseCase>(
    GetAlbumDetailsUseCase(repository: sl<AlbumRepository>())
  );

  sl.registerSingleton<GetSongsByAlbumUseCase>(
    GetSongsByAlbumUseCase(repository: sl<SongsRepository>())
  );

  sl.registerSingleton<GetPlaylistsUseCase>(
    GetPlaylistsUseCase(repository: sl<PlaylistRepository>())
  );

  sl.registerSingleton<GetArtistsUseCase>(
    GetArtistsUseCase(repository: sl<ArtistRepository>())
  );

  // Artist Detail Use Cases
  sl.registerSingleton<GetArtistDetailsUseCase>(
    GetArtistDetailsUseCase(repository: sl<ArtistRepository>())
  );

  sl.registerSingleton<GetArtistAlbumsUseCase>(
    GetArtistAlbumsUseCase(repository: sl<AlbumRepository>())
  );

  sl.registerSingleton<GetArtistSongsUseCase>(
    GetArtistSongsUseCase(repository: sl<SongsRepository>())
  );

  // Use cases - Search
  sl.registerSingleton<SearchUseCase>(
    SearchUseCase(searchRepository: sl<SearchRepository>())
  );
  
  sl.registerSingleton<GetSearchHistoryUseCase>(
    GetSearchHistoryUseCase(searchRepository: sl<SearchRepository>())
  );
  
  sl.registerSingleton<ClearSearchHistoryUseCase>(
    ClearSearchHistoryUseCase(searchRepository: sl<SearchRepository>())
  );
  
  sl.registerSingleton<GetSearchSuggestionsUseCase>(
    GetSearchSuggestionsUseCase(searchRepository: sl<SearchRepository>())
  );

  sl.registerSingleton<SaveSearchQueryUseCase>(
    SaveSearchQueryUseCase(repository: sl<SearchRepository>())
  );

  // Cubits
  sl.registerSingleton<SongPlayerCubit>(
    SongPlayerCubit()
  );

  sl.registerFactory<SearchCubit>(() => SearchCubit(
    searchUseCase: sl<SearchUseCase>(),
    getSearchHistoryUseCase: sl<GetSearchHistoryUseCase>(),
    clearSearchHistoryUseCase: sl<ClearSearchHistoryUseCase>(),
    saveSearchQueryUseCase: sl<SaveSearchQueryUseCase>(),
  ));

  sl.registerFactory<ArtistsCubit>(
    () => ArtistsCubit(getArtistsUseCase: sl<GetArtistsUseCase>())
  );

  sl.registerFactory<ArtistDetailCubit>(
    () => ArtistDetailCubit(
      getArtistDetailsUseCase: sl<GetArtistDetailsUseCase>(),
      getArtistAlbumsUseCase: sl<GetArtistAlbumsUseCase>(),
      getArtistSongsUseCase: sl<GetArtistSongsUseCase>(),
    )
  );

  sl.registerFactory<AlbumCubit>(
    () => AlbumCubit(
      getAlbumDetailsUseCase: sl<GetAlbumDetailsUseCase>(),
      getSongsByAlbumUseCase: sl<GetSongsByAlbumUseCase>(),
    )
  );

  sl.registerFactory<PlaylistDetailCubit>(
    () => PlaylistDetailCubit()
  );
}