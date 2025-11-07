import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/drawer/app_drawer.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/presentation/playlist/bloc/playlist_detail_cubit.dart';
import 'package:app_nghenhac/presentation/playlist/bloc/playlist_detail_state.dart';
import 'package:app_nghenhac/presentation/search_song_player/pages/search_song_player.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaylistDetailPage extends StatelessWidget {
  final PlaylistEntity playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        backgroundColor: context.isDarkMode ? const Color(0xff2C2B2B) : Colors.white,
        title: Text(playlist.name),
        action: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            }, 
            icon: const Icon(
              Icons.menu
            )
          ),
        ),
      ),
      endDrawer: const AppDrawer(),
      body: BlocProvider(
        create: (context) => sl<PlaylistDetailCubit>()..loadPlaylistSongs(playlist.id),
        child: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _playlistInfo(context),
                  const SizedBox(height: 30),
                  _playlistSongs(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _playlistInfo(BuildContext context) {
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
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty
                    ? NetworkImage(playlist.coverUrl!)
                    : const AssetImage('assets/images/artist.png') as ImageProvider,
                onError: (error, stackTrace) {
                  print('🖼️ Error loading playlist image: $error');
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
            playlist.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold
            ),
          ),
          if (playlist.description != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                playlist.description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
          if (playlist.trackCount != null) ...[
            const SizedBox(height: 10),
            Text(
              '${playlist.trackCount} songs',
              style: TextStyle(
                fontSize: 16,
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _playlistSongs(BuildContext context, PlaylistDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SONGS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          
          if (state is PlaylistDetailLoading)
            Container(
              height: 200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (state is PlaylistDetailFailure)
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (state is PlaylistDetailLoaded)
            state.songs.isEmpty
                ? Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_play,
                            size: 64,
                            color: context.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Playlist is empty',
                            style: TextStyle(
                              fontSize: 16,
                              color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.songs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final song = state.songs[index];
                      return _songItem(context, song);
                    },
                  )
          else
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.playlist_play,
                      size: 64,
                      color: context.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Playlist is empty',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _songItem(BuildContext context, SongEntity song) {
    print('🎵 Building song item: ${song.title}');
    print('🖼️ Song cover URL: ${song.coverUrl}');
    
    return GestureDetector(
      onTap: () {
        try {
          // Navigate to SearchSongPlayerPages
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchSongPlayerPages(songEntity: song),
            ),
          );
        } catch (e) {
          print('Error navigating to SearchSongPlayerPages: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open song: $e')),
          );
        }
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

  String _formatDuration(int durationInSeconds) {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}