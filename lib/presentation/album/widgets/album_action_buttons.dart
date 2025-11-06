import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumActionButtons extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        vertical: isDesktop ? 32 : (isTablet ? 24 : 20),
      ),
      child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
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
            _buildPlayButton(context, size: isTablet ? 56 : 48),
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
        if (songs.isNotEmpty) {
          context.read<AlbumCubit>().playAll();
          _showSnackBar(context, 'Bắt đầu phát album "${album.title}"');
        } else {
          _showSnackBar(context, 'Album không có bài hát nào');
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
        if (songs.isNotEmpty) {
          context.read<AlbumCubit>().shufflePlay();
          _showSnackBar(context, 'Phát ngẫu nhiên album "${album.title}"');
        } else {
          _showSnackBar(context, 'Album không có bài hát nào');
        }
      },
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return _buildActionButton(
      context,
      icon: album.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      iconColor: album.isFavorite ? Colors.red[400] : null,
      onTap: () {
        // TODO: Implement toggle favorite
        _showSnackBar(context, album.isFavorite ? 'Đã xóa khỏi yêu thích' : 'Đã thêm vào yêu thích');
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
        _showSnackBar(context, 'Đang tải xuống album...');
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final buttonSize = isDesktop ? 48.0 : (isTablet ? 44.0 : 40.0);
    final iconSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);

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
                'Thêm vào playlist',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Tính năng sẽ được cập nhật');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.share_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Chia sẻ album',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Tính năng sẽ được cập nhật');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Thông tin album',
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
        title: Text(album.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nghệ sĩ', album.artist),
            if (album.releaseDate != null)
              _buildInfoRow('Năm phát hành', album.releaseDate!.year.toString()),
            if (album.trackCount != null)
              _buildInfoRow('Số bài hát', album.trackCount.toString()),
            if (album.genres != null && album.genres!.isNotEmpty)
              _buildInfoRow('Thể loại', album.genres!.join(', ')),
            _buildInfoRow('Số bài hát có sẵn', songs.length.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
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