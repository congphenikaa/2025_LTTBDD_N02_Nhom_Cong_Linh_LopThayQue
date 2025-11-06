import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_state.dart';
import 'package:app_nghenhac/presentation/album/widgets/album_header.dart';
import 'package:app_nghenhac/presentation/album/widgets/album_songs_list.dart';
import 'package:app_nghenhac/presentation/album/widgets/album_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumDetailPage extends StatelessWidget {
  final AlbumEntity album;

  const AlbumDetailPage({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      body: BlocBuilder<AlbumCubit, AlbumState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isDesktop, isTablet),
              if (state is AlbumLoading) 
                _buildLoadingSliver(isDesktop, isTablet, context),
              if (state is AlbumLoadFailure) 
                _buildErrorSliver(state.message, context, isDesktop, isTablet),
              if (state is AlbumLoaded || state is AlbumSongPlaying) 
                ..._buildContentSlivers(state as AlbumLoaded, context, isDesktop, isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDesktop, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 400 : (isTablet ? 350 : 300),
      floating: false,
      pinned: true,
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary.withOpacity(0.6),
                (context.isDarkMode ? Colors.black : Colors.white).withOpacity(0.9),
              ],
            ),
          ),
          child: AlbumHeader(
            album: album,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            _showAlbumOptions(context);
          },
        ),
      ],
    );
  }

  List<Widget> _buildContentSlivers(AlbumLoaded state, BuildContext context, bool isDesktop, bool isTablet) {
    return [
      // Action Buttons
      SliverToBoxAdapter(
        child: AlbumActionButtons(
          album: state.album,
          songs: state.songs,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
      ),
      
      // Songs List
      SliverToBoxAdapter(
        child: AlbumSongsList(
          songs: state.songs,
          album: state.album,
          currentSongIndex: state is AlbumSongPlaying ? state.currentSongIndex : -1,
          isPlaying: state is AlbumSongPlaying ? state.isPlaying : false,
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),
      ),
    ];
  }

  Widget _buildLoadingSliver(bool isDesktop, bool isTablet, BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.album_rounded,
                  color: AppColors.primary.withOpacity(0.7),
                  size: isDesktop ? 20 : 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang tải thông tin album...',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSliver(String message, BuildContext context, bool isDesktop, bool isTablet) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: isDesktop ? 80 : 60,
                color: context.isDarkMode ? Colors.red[400] : Colors.red[600],
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: context.isDarkMode ? Colors.amber[400] : Colors.amber[600],
                    size: isDesktop ? 24 : 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đã xảy ra lỗi',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 16 : 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              SizedBox(height: isDesktop ? 32 : 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AlbumCubit>().loadAlbumDetails(album.id);
                },
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: isDesktop ? 16 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlbumOptions(BuildContext context) {
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
                Icons.favorite_border_rounded,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Thêm vào yêu thích',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle favorite action
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
                // Handle share action
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
                // Handle download action
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
            Text('Nghệ sĩ: ${album.artist}'),
            if (album.releaseDate != null)
              Text('Ngày phát hành: ${_formatDate(album.releaseDate!)}'),
            if (album.trackCount != null)
              Text('Số bài hát: ${album.trackCount}'),
            if (album.genres != null && album.genres!.isNotEmpty)
              Text('Thể loại: ${album.genres!.join(', ')}'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}