import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:app_nghenhac/presentation/search_song_player/pages/search_song_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumMiniPlayer extends StatefulWidget {
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
  State<AlbumMiniPlayer> createState() => _AlbumMiniPlayerState();
}

class _AlbumMiniPlayerState extends State<AlbumMiniPlayer> {
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 20 : (widget.isTablet ? 16 : 12),
        vertical: widget.isDesktop ? 16 : (widget.isTablet ? 12 : 8),
      ),
      decoration: BoxDecoration(
        color: context.isDarkMode 
            ? Colors.grey[850]?.withOpacity(0.95) 
            : Colors.grey[50]?.withOpacity(0.95),
        borderRadius: BorderRadius.circular(widget.isDesktop ? 16 : 12),
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
              width: widget.isDesktop ? 56 : (widget.isTablet ? 48 : 40),
              height: widget.isDesktop ? 56 : (widget.isTablet ? 48 : 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(0.2),
              ),
              child: widget.currentSong.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.currentSong.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.music_note_rounded,
                            color: AppColors.primary,
                            size: widget.isDesktop ? 28 : (widget.isTablet ? 24 : 20),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.music_note_rounded,
                      color: AppColors.primary,
                      size: widget.isDesktop ? 28 : (widget.isTablet ? 24 : 20),
                    ),
            ),
          ),
          
          SizedBox(width: widget.isDesktop ? 16 : (widget.isTablet ? 12 : 8)),
          
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
                        size: widget.isDesktop ? 16 : (widget.isTablet ? 14 : 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        LanguageService.getTextSync('now_playing', currentLanguage),
                        style: TextStyle(
                          fontSize: widget.isDesktop ? 12 : (widget.isTablet ? 11 : 10),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.currentSong.title,
                    style: TextStyle(
                      fontSize: widget.isDesktop ? 16 : (widget.isTablet ? 14 : 12),
                      fontWeight: FontWeight.w600,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.currentSong.artist,
                    style: TextStyle(
                      fontSize: widget.isDesktop ? 14 : (widget.isTablet ? 12 : 10),
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
                  padding: EdgeInsets.all(widget.isDesktop ? 8 : 6),
                  decoration: BoxDecoration(
                    color: context.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.skip_previous_rounded,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    size: widget.isDesktop ? 24 : (widget.isTablet ? 20 : 16),
                  ),
                ),
              ),
              
              SizedBox(width: widget.isDesktop ? 12 : 8),
              
              // Play/Pause Button
              GestureDetector(
                onTap: () => context.read<AlbumCubit>().togglePlayPause(),
                child: Container(
                  padding: EdgeInsets.all(widget.isDesktop ? 12 : 10),
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
                    widget.isPlaying 
                        ? Icons.pause_rounded 
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: widget.isDesktop ? 28 : (widget.isTablet ? 24 : 20),
                  ),
                ),
              ),
              
              SizedBox(width: widget.isDesktop ? 12 : 8),
              
              // Next Button
              GestureDetector(
                onTap: () => context.read<AlbumCubit>().nextSong(),
                child: Container(
                  padding: EdgeInsets.all(widget.isDesktop ? 8 : 6),
                  decoration: BoxDecoration(
                    color: context.isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.skip_next_rounded,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    size: widget.isDesktop ? 24 : (widget.isTablet ? 20 : 16),
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
        builder: (context) => SearchSongPlayerPages(songEntity: widget.currentSong),
      ),
    );
  }
}