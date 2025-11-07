import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:app_nghenhac/domain/usecases/playlist/get_playlists.dart';
import 'package:app_nghenhac/presentation/playlist/pages/playlist_detail_page.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';

class PlaylistsList extends StatefulWidget {
  const PlaylistsList({super.key});

  @override
  State<PlaylistsList> createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> {
  List<PlaylistEntity> _playlists = [];
  bool _isLoading = true;
  String? _error;
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    
    print('🚀 PlaylistsList: initState called');
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService trước
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
    print('👂 PlaylistsList: Added language listener');
    
    // Khởi tạo ngôn ngữ hiện tại
    _currentLanguage = LanguageService.languageNotifier.value;
    print('🌍 PlaylistsList: Initial language set to: $_currentLanguage');
    
    _loadPlaylists();
  }

  @override
  void dispose() {
    print('💀 PlaylistsList: dispose called');
    // Hủy listener khi dispose
    LanguageService.languageNotifier.removeListener(_onLanguageChanged);
    print('🔇 PlaylistsList: Removed language listener');
    super.dispose();
  }

  void _onLanguageChanged() {
    print('🔄 PlaylistsList: Language changed to ${LanguageService.languageNotifier.value}');
    if (mounted) {
      setState(() {
        _currentLanguage = LanguageService.languageNotifier.value;
        print('✅ PlaylistsList: setState completed with language: $_currentLanguage');
      });
    } else {
      print('⚠️ PlaylistsList: Widget not mounted, skipping setState');
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      print('🔍 PlaylistsList: Starting to load playlists...');
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final getPlaylistsUseCase = sl<GetPlaylistsUseCase>();
      print('🔍 PlaylistsList: Got GetPlaylistsUseCase, calling to fetch playlists');
      
      // Fetch playlists directly from Firestore - get 8 playlists
      final playlists = await getPlaylistsUseCase.call(params: 8);
      
      print('🔍 PlaylistsList: Playlists received');
      print('📊 PlaylistsList: Total playlists found: ${playlists.length}');
      
      // Print each playlist for debugging
      for (int i = 0; i < playlists.length; i++) {
        final playlist = playlists[i];
        print('🎵 Playlist $i: ${playlist.name} by ${playlist.creatorName}');
      }
      
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
      
      print('🏁 PlaylistsList: setState completed. Playlists count: ${_playlists.length}');
    } catch (e) {
      print('💥 PlaylistsList: Exception caught: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isDesktop ? 40 : (isTablet ? 30 : 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(isDesktop: isDesktop, isTablet: isTablet),
          SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),
          _buildContent(isDesktop: isDesktop, isTablet: isTablet),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({bool isDesktop = false, bool isTablet = false}) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : double.infinity,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LanguageService.getTextSync('Featured Playlists', _currentLanguage),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all playlists page
              },
              child: Text(
                LanguageService.getTextSync('See More', _currentLanguage),
                style: TextStyle(
                  fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                  color: context.isDarkMode ? Colors.white70 : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({bool isDesktop = false, bool isTablet = false}) {
    if (_isLoading) {
      return Container(
        height: isDesktop ? 260 : (isTablet ? 220 : 180),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: isDesktop ? 260 : (isTablet ? 220 : 180),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isDesktop ? 48 : 36,
                color: Colors.red,
              ),
              SizedBox(height: 8),
              Text(
                LanguageService.getTextSync('Cannot load playlists', _currentLanguage),
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: context.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: _loadPlaylists,
                child: Text(LanguageService.getTextSync('Try Again', _currentLanguage)),
              ),
            ],
          ),
        ),
      );
    }

    if (_playlists.isEmpty) {
      return Container(
        height: isDesktop ? 260 : (isTablet ? 220 : 180),
        child: Center(
          child: Text(
            LanguageService.getTextSync('No Playlists Found', _currentLanguage),
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    return Container(
      height: isDesktop ? 260 : (isTablet ? 220 : 180),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : double.infinity,
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
            ),
            itemCount: _playlists.length,
            separatorBuilder: (context, index) => SizedBox(
              width: isDesktop ? 20 : (isTablet ? 16 : 12),
            ),
            itemBuilder: (context, index) {
              return _buildPlaylistCard(_playlists[index], isDesktop, isTablet);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(PlaylistEntity playlist, bool isDesktop, bool isTablet) {
    final cardWidth = isDesktop ? 200.0 : (isTablet ? 180.0 : 160.0);
    final cardHeight = isDesktop ? 120.0 : (isTablet ? 110.0 : 100.0);
    
    return GestureDetector(
      onTap: () {
        // Navigate to PlaylistDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.primary.withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: isDesktop ? 16 : 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                  child: playlist.coverUrl != null
                      ? Image.network(
                          playlist.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultPlaylistCover(isDesktop, isTablet);
                          },
                        )
                      : _buildDefaultPlaylistCover(isDesktop, isTablet),
                ),
              ),
            ),
            
            // Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(isDesktop ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    playlist.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  Row(
                    children: [
                      if (playlist.creatorName != null) ...[
                        Expanded(
                          child: Text(
                            '${LanguageService.getTextSync('By', _currentLanguage)} ${playlist.creatorName}',
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      
                      if (playlist.trackCount != null) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${playlist.trackCount}',
                            style: TextStyle(
                              fontSize: isDesktop ? 10 : 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPlaylistCover(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.4),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.queue_music,
          size: isDesktop ? 40 : (isTablet ? 32 : 28),
          color: Colors.white,
        ),
      ),
    );
  }
}