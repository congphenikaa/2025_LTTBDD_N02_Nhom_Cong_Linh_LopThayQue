import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumSongsList extends StatelessWidget {
  final List<SongEntity> songs;
  final AlbumEntity album;
  final int currentSongIndex;
  final bool isPlaying;
  final bool isDesktop;
  final bool isTablet;

  const AlbumSongsList({
    super.key,
    required this.songs,
    required this.album,
    this.currentSongIndex = -1,
    this.isPlaying = false,
    this.isDesktop = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        vertical: isDesktop ? 24 : (isTablet ? 20 : 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(height: isDesktop ? 20 : 16),
          _buildSongsList(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Danh sách bài hát',
          style: TextStyle(
            fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          '${songs.length} bài hát',
          style: TextStyle(
            fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSongsList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: (context.isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final song = songs[index];
        final isCurrentSong = index == currentSongIndex;
        final isCurrentlyPlaying = isCurrentSong && isPlaying;

        return _buildSongItem(
          context,
          song,
          index,
          isCurrentSong,
          isCurrentlyPlaying,
        );
      },
    );
  }

  Widget _buildSongItem(
    BuildContext context,
    SongEntity song,
    int index,
    bool isCurrentSong,
    bool isCurrentlyPlaying,
  ) {
    return InkWell(
      onTap: () {
        context.read<AlbumCubit>().playSong(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
          horizontal: isDesktop ? 16 : (isTablet ? 12 : 8),
        ),
        decoration: BoxDecoration(
          color: isCurrentSong
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Track Number or Play Icon
            SizedBox(
              width: isDesktop ? 40 : (isTablet ? 36 : 32),
              child: isCurrentlyPlaying
                  ? Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.primary,
                      size: isDesktop ? 24 : (isTablet ? 22 : 20),
                    )
                  : isCurrentSong
                      ? Icon(
                          Icons.pause_circle_rounded,
                          color: AppColors.primary,
                          size: isDesktop ? 24 : (isTablet ? 22 : 20),
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                            color: context.isDarkMode ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
            ),
            
            SizedBox(width: isDesktop ? 16 : (isTablet ? 12 : 8)),
            
            // Song Cover (only on desktop/tablet)
            if (isDesktop || isTablet) ...[
              Container(
                width: isDesktop ? 48 : 40,
                height: isDesktop ? 48 : 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.primary.withOpacity(0.2),
                ),
                child: song.coverUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          song.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.music_note_rounded,
                              color: AppColors.primary,
                              size: isDesktop ? 24 : 20,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.music_note_rounded,
                        color: AppColors.primary,
                        size: isDesktop ? 24 : 20,
                      ),
              ),
              SizedBox(width: isDesktop ? 16 : 12),
            ],
            
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                      fontWeight: isCurrentSong ? FontWeight.w600 : FontWeight.w500,
                      color: isCurrentSong
                          ? AppColors.primary
                          : (context.isDarkMode ? Colors.white : Colors.black),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (song.artist != album.artist) ...[
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                        color: context.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Duration
            if (song.duration != null) ...[
              Text(
                _formatDuration(song.duration!),
                style: TextStyle(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  color: context.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(width: isDesktop ? 16 : (isTablet ? 12 : 8)),
            ],
            
            // More Options Button
            GestureDetector(
              onTap: () => _showSongOptions(context, song, index),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: isDesktop ? 20 : (isTablet ? 18 : 16),
                  color: context.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 48 : 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.music_off_rounded,
              size: isDesktop ? 80 : 60,
              color: context.isDarkMode ? Colors.white38 : Colors.black38,
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.queue_music_rounded,
                  size: isDesktop ? 24 : 20,
                  color: context.isDarkMode ? Colors.white60 : Colors.black45,
                ),
                const SizedBox(width: 8),
                Text(
                  'Không có bài hát nào',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.w500,
                    color: context.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              'Album này hiện chưa có bài hát nào.',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: context.isDarkMode ? Colors.white60 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showSongOptions(BuildContext context, SongEntity song, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Song Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    child: song.coverUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              song.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.music_note_rounded,
                                  color: AppColors.primary,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.music_note_rounded,
                            color: AppColors.primary,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: context.isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: context.isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            
            // Options
            ListTile(
              leading: Icon(
                song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: song.isFavorite 
                    ? Colors.red[400] 
                    : (context.isDarkMode ? Colors.white : Colors.black87),
              ),
              title: Text(
                song.isFavorite ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement toggle favorite
              },
            ),
            ListTile(
              leading: Icon(
                Icons.playlist_add_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Thêm vào playlist',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add to playlist
              },
            ),
            ListTile(
              leading: Icon(
                Icons.share_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Chia sẻ',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: Icon(
                Icons.download_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Tải xuống',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement download
              },
            ),
          ],
        ),
      ),
    );
  }
}