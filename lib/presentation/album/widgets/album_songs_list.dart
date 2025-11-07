import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumSongsList extends StatefulWidget {
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
  State<AlbumSongsList> createState() => _AlbumSongsListState();
}

class _AlbumSongsListState extends State<AlbumSongsList> {
  String currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    // Hủy listener khi dispose
    LanguageService.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        currentLanguage = LanguageService.languageNotifier.value;
      });
    }
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LanguageService.getCurrentLanguage();
    setState(() {
      currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.songs.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 32 : (widget.isTablet ? 24 : 16),
        vertical: widget.isDesktop ? 24 : (widget.isTablet ? 20 : 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(height: widget.isDesktop ? 20 : 16),
          _buildSongsList(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          LanguageService.getTextSync('song_list', currentLanguage),
          style: TextStyle(
            fontSize: widget.isDesktop ? 24 : (widget.isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          '${widget.songs.length} ${LanguageService.getTextSync("songs", currentLanguage)}',
          style: TextStyle(
            fontSize: widget.isDesktop ? 16 : (widget.isTablet ? 14 : 12),
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
      itemCount: widget.songs.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: (context.isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final song = widget.songs[index];
        final isCurrentSong = index == widget.currentSongIndex;
        final isCurrentlyPlaying = isCurrentSong && widget.isPlaying;

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
          vertical: widget.isDesktop ? 16 : (widget.isTablet ? 14 : 12),
          horizontal: widget.isDesktop ? 16 : (widget.isTablet ? 12 : 8),
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
              width: widget.isDesktop ? 40 : (widget.isTablet ? 36 : 32),
              child: isCurrentlyPlaying
                  ? Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.primary,
                      size: widget.isDesktop ? 24 : (widget.isTablet ? 22 : 20),
                    )
                  : isCurrentSong
                      ? Icon(
                          Icons.pause_circle_rounded,
                          color: AppColors.primary,
                          size: widget.isDesktop ? 24 : (widget.isTablet ? 22 : 20),
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: widget.isDesktop ? 16 : (widget.isTablet ? 14 : 12),
                            color: context.isDarkMode ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
            ),
            
            SizedBox(width: widget.isDesktop ? 16 : (widget.isTablet ? 12 : 8)),
            
            // Song Cover (only on desktop/tablet)
            if (widget.isDesktop || widget.isTablet) ...[
              Container(
                width: widget.isDesktop ? 48 : 40,
                height: widget.isDesktop ? 48 : 40,
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
                              size: widget.isDesktop ? 24 : 20,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.music_note_rounded,
                        color: AppColors.primary,
                        size: widget.isDesktop ? 24 : 20,
                      ),
              ),
              SizedBox(width: widget.isDesktop ? 16 : 12),
            ],
            
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: widget.isDesktop ? 16 : (widget.isTablet ? 15 : 14),
                      fontWeight: isCurrentSong ? FontWeight.w600 : FontWeight.w500,
                      color: isCurrentSong
                          ? AppColors.primary
                          : (context.isDarkMode ? Colors.white : Colors.black),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (song.artist != widget.album.artist) ...[
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: TextStyle(
                        fontSize: widget.isDesktop ? 14 : (widget.isTablet ? 13 : 12),
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
                  fontSize: widget.isDesktop ? 14 : (widget.isTablet ? 13 : 12),
                  color: context.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(width: widget.isDesktop ? 16 : (widget.isTablet ? 12 : 8)),
            ],
            
            // More Options Button
            GestureDetector(
              onTap: () => _showSongOptions(context, song, index),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: widget.isDesktop ? 20 : (widget.isTablet ? 18 : 16),
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
      padding: EdgeInsets.all(widget.isDesktop ? 48 : 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.music_off_rounded,
              size: widget.isDesktop ? 80 : 60,
              color: context.isDarkMode ? Colors.white38 : Colors.black38,
            ),
            SizedBox(height: widget.isDesktop ? 24 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.queue_music_rounded,
                  size: widget.isDesktop ? 24 : 20,
                  color: context.isDarkMode ? Colors.white60 : Colors.black45,
                ),
                const SizedBox(width: 8),
                Text(
                  LanguageService.getTextSync('Không có bài hát nào', currentLanguage),
                  style: TextStyle(
                    fontSize: widget.isDesktop ? 20 : 16,
                    fontWeight: FontWeight.w500,
                    color: context.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.isDesktop ? 12 : 8),
            Text(
              LanguageService.getTextSync('no songs in album', currentLanguage),
              style: TextStyle(
                fontSize: widget.isDesktop ? 16 : 14,
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
                song.isFavorite 
                  ? LanguageService.getTextSync('Xóa khỏi yêu thích', currentLanguage)
                  : LanguageService.getTextSync('Thêm vào yêu thích', currentLanguage),
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
                LanguageService.getTextSync('Thêm vào playlist', currentLanguage),
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
                LanguageService.getTextSync('Tải về', currentLanguage),
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