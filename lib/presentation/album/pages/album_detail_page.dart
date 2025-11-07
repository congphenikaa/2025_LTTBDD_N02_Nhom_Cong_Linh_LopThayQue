import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_state.dart';
import 'package:app_nghenhac/presentation/album/widgets/album_header.dart';
import 'package:app_nghenhac/presentation/album/widgets/album_songs_list.dart';
import 'package:app_nghenhac/presentation/album/widgets/album_action_buttons.dart';
import 'package:app_nghenhac/presentation/album/widgets/album_mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumDetailPage extends StatefulWidget {
  final AlbumEntity album;

  const AlbumDetailPage({
    super.key,
    required this.album,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  String currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
    _loadCurrentLanguage();
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
      // Add mini player when song is playing
      bottomNavigationBar: BlocBuilder<AlbumCubit, AlbumState>(
        builder: (context, state) {
          if (state is AlbumSongPlaying) {
            final currentSong = state.songs[state.currentSongIndex];
            return Container(
              padding: EdgeInsets.only(
                left: isDesktop ? 24 : (isTablet ? 20 : 16),
                right: isDesktop ? 24 : (isTablet ? 20 : 16),
                bottom: isDesktop ? 24 : (isTablet ? 20 : 16),
                top: isDesktop ? 16 : (isTablet ? 12 : 8),
              ),
              decoration: BoxDecoration(
                color: context.isDarkMode 
                    ? Colors.black.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: AlbumMiniPlayer(
                  currentSong: currentSong,
                  isPlaying: state.isPlaying,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
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
            album: widget.album,
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
                  LanguageService.getTextSync('loading_album_info', currentLanguage),
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
                    LanguageService.getTextSync('error_occurred', currentLanguage),
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
                  context.read<AlbumCubit>().loadAlbumDetails(widget.album.id);
                },
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(LanguageService.getTextSync('try_again', currentLanguage)),
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
                LanguageService.getTextSync('add_to_favorite', currentLanguage),
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
                LanguageService.getTextSync('share_album', currentLanguage),
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
                LanguageService.getTextSync('download', currentLanguage),
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
            Text('${LanguageService.getTextSync("artist", currentLanguage)}: ${widget.album.artist}'),
            if (widget.album.releaseDate != null)
              Text('${LanguageService.getTextSync("release_date", currentLanguage)}: ${_formatDate(widget.album.releaseDate!)}'),
            if (widget.album.trackCount != null)
              Text('${LanguageService.getTextSync("track_count", currentLanguage)}: ${widget.album.trackCount}'),
            if (widget.album.genres != null && widget.album.genres!.isNotEmpty)
              Text('${LanguageService.getTextSync("genre", currentLanguage)}: ${widget.album.genres!.join(', ')}'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}