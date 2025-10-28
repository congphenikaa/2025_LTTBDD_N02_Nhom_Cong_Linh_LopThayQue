import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart' as SearchSong;
import 'package:app_nghenhac/presentation/artist/bloc/artist_detail_cubit.dart';
import 'package:app_nghenhac/presentation/artist/bloc/artist_detail_state.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistDetailPage extends StatelessWidget {
  final ArtistEntity artist;

  const ArtistDetailPage({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        backgroundColor: context.isDarkMode ? const Color(0xff2C2B2B) : Colors.white,
        title: Text(artist.name),
      ),
      body: BlocProvider(
        create: (context) => sl<ArtistDetailCubit>()..loadArtistDetail(artist.id),
        child: BlocBuilder<ArtistDetailCubit, ArtistDetailState>(
          builder: (context, state) {
            if (state is ArtistDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ArtistDetailFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải thông tin nghệ sĩ',
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ArtistDetailCubit>().loadArtistDetail(artist.id);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is ArtistDetailLoaded) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _artistInfo(context, state.artist),
                    const SizedBox(height: 30),
                    _albumsSection(context, state.albums),
                    const SizedBox(height: 30),
                    _songsSection(context, state.songs),
                  ],
                ),
              );
            }
            
            return Container();
          },
        ),
      ),
    );
  }

  Widget _artistInfo(BuildContext context, ArtistEntity artist) {
    return Container(
      height: MediaQuery.of(context).size.height / 3.5,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xff2C2B2B) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(50),
          bottomLeft: Radius.circular(50)
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: artist.imageUrl != null && artist.imageUrl!.isNotEmpty
                    ? NetworkImage(artist.imageUrl!)
                    : const AssetImage('assets/images/artist.png') as ImageProvider,
                onError: (error, stackTrace) {
                  print('🖼️ Error loading artist image: $error');
                },
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            )
          ),
          const SizedBox(height: 20),
          Text(
            artist.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold
            ),
          ),
          if (artist.followers != null) ...[
            const SizedBox(height: 10),
            Text(
              '${_formatFollowers(artist.followers!)} người theo dõi',
              style: TextStyle(
                fontSize: 16,
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
          if (artist.bio != null) ...[
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                artist.bio!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _albumsSection(BuildContext context, List<AlbumEntity> albums) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALBUMS (${albums.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          if (albums.isEmpty)
            Container(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.album_outlined,
                      size: 48,
                      color: context.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có album nào',
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: albums.length,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return _albumCard(context, album);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _albumCard(BuildContext context, AlbumEntity album) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to album detail page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on album: ${album.title}')),
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: album.coverUrl != null && album.coverUrl!.isNotEmpty
                      ? NetworkImage(album.coverUrl!)
                      : const AssetImage('assets/images/artist.png') as ImageProvider,
                  onError: (error, stackTrace) {
                    print('🖼️ Error loading album cover: $error');
                  },
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              album.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (album.releaseDate != null)
              Text(
                '${album.releaseDate!.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _songsSection(BuildContext context, List<SearchSong.SongEntity> songs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BÀI HÁT (${songs.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          if (songs.isEmpty)
            Container(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note_outlined,
                      size: 48,
                      color: context.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có bài hát nào',
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final song = songs[index];
                return _songItem(context, song);
              },
            ),
        ],
      ),
    );
  }

  Widget _songItem(BuildContext context, SearchSong.SongEntity song) {
    print('🎵 Building song item: ${song.title}');
    print('🖼️ Song cover URL: ${song.coverUrl}');
    
    return GestureDetector(
      onTap: () {
        // TODO: Convert SearchSong.SongEntity to PlayerSong.SongEntity
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on song: ${song.title}')),
        );
      },
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: song.coverUrl != null && song.coverUrl!.isNotEmpty
                    ? NetworkImage(song.coverUrl!)
                    : const AssetImage('assets/images/artist.png') as ImageProvider,
                onError: (error, stackTrace) {
                  print('🖼️ Error loading song cover: $error');
                },
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  song.artist,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (song.duration != null)
            Text(
              _formatDuration(song.duration!),
              style: TextStyle(
                fontSize: 12,
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  String _formatDuration(int durationInSeconds) {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}