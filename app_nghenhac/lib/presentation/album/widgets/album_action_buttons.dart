import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumActionButtons extends StatefulWidget {
  final AlbumEntity album;
  final List<SongEntity> songs;
  final bool isDesktop;
  final bool isTablet;

  const AlbumActionButtons({
    super.key,
    required this.album,
    required this.songs,
    this.isDesktop = false,
    this.isTablet = false,
  });

  @override
  State<AlbumActionButtons> createState() => _AlbumActionButtonsState();
}

class _AlbumActionButtonsState extends State<AlbumActionButtons> {
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
        horizontal: widget.isDesktop ? 32 : (widget.isTablet ? 24 : 16),
        vertical: widget.isDesktop ? 32 : (widget.isTablet ? 24 : 20),
      ),
      child: widget.isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        _buildPlayButton(context, size: 64),
        const SizedBox(width: 24),
        _buildShuffleButton(context),
        const SizedBox(width: 16),
        _buildFavoriteButton(context),
        const SizedBox(width: 16),
        _buildMoreButton(context),
        const Spacer(),
        _buildDownloadButton(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildPlayButton(context, size: widget.isTablet ? 56 : 48),
            const SizedBox(width: 16),
            _buildShuffleButton(context),
            const SizedBox(width: 12),
            _buildFavoriteButton(context),
            const SizedBox(width: 12),
            _buildMoreButton(context),
            const Spacer(),
            _buildDownloadButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context, {required double size}) {
    return GestureDetector(
      onTap: () {
        if (widget.songs.isNotEmpty) {
          context.read<AlbumCubit>().playAll();
          _showSnackBar(context, '${LanguageService.getTextSync("start_playing_album", currentLanguage)} "${widget.album.title}"');
        } else {
          _showSnackBar(context, LanguageService.getTextSync("album_no_songs", currentLanguage));
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }

  Widget _buildShuffleButton(BuildContext context) {
    return _buildActionButton(
      context,
      icon: Icons.shuffle_rounded,
      onTap: () {
        if (widget.songs.isNotEmpty) {
          context.read<AlbumCubit>().shufflePlay();
          _showSnackBar(context, '${LanguageService.getTextSync("shuffle_play_album", currentLanguage)} "${widget.album.title}"');
        } else {
          _showSnackBar(context, LanguageService.getTextSync("album_no_songs", currentLanguage));
        }
      },
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return _buildActionButton(
      context,
      icon: widget.album.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      iconColor: widget.album.isFavorite ? Colors.red[400] : null,
      onTap: () {
        // TODO: Implement toggle favorite
        _showSnackBar(context, widget.album.isFavorite 
          ? LanguageService.getTextSync("removed_from_favorite", currentLanguage) 
          : LanguageService.getTextSync("added_to_favorite", currentLanguage));
      },
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return _buildActionButton(
      context,
      icon: Icons.more_horiz_rounded,
      onTap: () {
        _showMoreOptions(context);
      },
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return _buildActionButton(
      context,
      icon: Icons.download_rounded,
      onTap: () {
        // TODO: Implement download
        _showSnackBar(context, LanguageService.getTextSync("downloading_album", currentLanguage));
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final buttonSize = widget.isDesktop ? 48.0 : (widget.isTablet ? 44.0 : 40.0);
    final iconSize = widget.isDesktop ? 24.0 : (widget.isTablet ? 22.0 : 20.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: (context.isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? (context.isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
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
            ListTile(
              leading: Icon(
                Icons.playlist_add_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                LanguageService.getTextSync('add_to_playlist', currentLanguage),
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, LanguageService.getTextSync('feature_coming_soon', currentLanguage));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.share_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                LanguageService.getTextSync('share', currentLanguage),
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, LanguageService.getTextSync('feature_coming_soon', currentLanguage));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                LanguageService.getTextSync('album_info', currentLanguage),
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAlbumInfo(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.report_problem_rounded,
                color: context.isDarkMode ? Colors.orange[400] : Colors.orange[600],
              ),
              title: Text(
                'Báo cáo vấn đề',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Tính năng sẽ được cập nhật');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAlbumInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.album.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(LanguageService.getTextSync("artist", currentLanguage), widget.album.artist),
            if (widget.album.releaseDate != null)
              _buildInfoRow(LanguageService.getTextSync("release_year", currentLanguage), widget.album.releaseDate!.year.toString()),
            if (widget.album.trackCount != null)
              _buildInfoRow(LanguageService.getTextSync("track_count", currentLanguage), widget.album.trackCount.toString()),
            if (widget.album.genres != null && widget.album.genres!.isNotEmpty)
              _buildInfoRow(LanguageService.getTextSync("genre", currentLanguage), widget.album.genres!.join(', ')),
            _buildInfoRow(LanguageService.getTextSync("available_songs", currentLanguage), widget.songs.length.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageService.getTextSync('close', currentLanguage)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}