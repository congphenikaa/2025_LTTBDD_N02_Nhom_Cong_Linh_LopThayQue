import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:app_nghenhac/presentation/search_song_player/pages/search_song_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumMiniPlayer extends StatelessWidget {
  final SongEntity currentSong;
  final bool isPlaying;
  final bool isDesktop;
  final bool isTablet;

  const AlbumMiniPlayer({
    super.key,
    required this.currentSong,
    required this.isPlaying,
    this.isDesktop = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : (isTablet ? 16 : 12),
        vertical: isDesktop ? 16 : (isTablet ? 12 : 8),
      ),
      decoration: BoxDecoration(
        color: context.isDarkMode 
            ? Colors.grey[850]?.withOpacity(0.95) 
            : Colors.grey[50]?.withOpacity(0.95),
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Song Cover
          GestureDetector(
            onTap: () => _openFullPlayer(context),
            child: Container(
              width: isDesktop ? 56 : (isTablet ? 48 : 40),
              height: isDesktop ? 56 : (isTablet ? 48 : 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(0.2),
              ),
              child: currentSong.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentSong.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.music_note_rounded,
                            color: AppColors.primary,
                            size: isDesktop ? 28 : (isTablet ? 24 : 20),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.music_note_rounded,
                      color: AppColors.primary,
                      size: isDesktop ? 28 : (isTablet ? 24 : 20),
                    ),
            ),
          ),
          
          SizedBox(width: isDesktop ? 16 : (isTablet ? 12 : 8)),
          
          // Song Info
          Expanded(
            child: GestureDetector(
              onTap: () => _openFullPlayer(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        color: AppColors.primary,
                        size: isDesktop ? 16 : (isTablet ? 14 : 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đang phát',
                        style: TextStyle(
                          fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentSong.title,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                      fontWeight: FontWeight.w600,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    currentSong.artist,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : (isTablet ? 12 : 10),
                      color: context.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Control Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous Button
              GestureDetector(
                onTap: () => context.read<AlbumCubit>().previousSong(),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 8 : 6),
                  decoration: BoxDecoration(
                    color: context.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.skip_previous_rounded,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    size: isDesktop ? 24 : (isTablet ? 20 : 16),
                  ),
                ),
              ),
              
              SizedBox(width: isDesktop ? 12 : 8),
              
              // Play/Pause Button
              GestureDetector(
                onTap: () => context.read<AlbumCubit>().togglePlayPause(),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying 
                        ? Icons.pause_rounded 
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: isDesktop ? 28 : (isTablet ? 24 : 20),
                  ),
                ),
              ),
              
              SizedBox(width: isDesktop ? 12 : 8),
              
              // Next Button
              GestureDetector(
                onTap: () => context.read<AlbumCubit>().nextSong(),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 8 : 6),
                  decoration: BoxDecoration(
                    color: context.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.skip_next_rounded,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    size: isDesktop ? 24 : (isTablet ? 20 : 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFullPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchSongPlayerPages(songEntity: currentSong),
      ),
    );
  }
}