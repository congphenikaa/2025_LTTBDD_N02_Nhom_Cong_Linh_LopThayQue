import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/usecases/album/get_albums.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:app_nghenhac/presentation/album/pages/album_detail_page.dart';
import 'package:app_nghenhac/presentation/album/pages/all_albums_page.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumsList extends StatefulWidget {
  const AlbumsList({super.key});

  @override
  State<AlbumsList> createState() => _AlbumsListState();
}

class _AlbumsListState extends State<AlbumsList> {
  List<AlbumEntity> _albums = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      print('🔍 AlbumsList: Starting to load albums...');
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final getAlbumsUseCase = sl<GetAlbumsUseCase>();
      print('🔍 AlbumsList: Got GetAlbumsUseCase, calling to fetch albums');
      
      // Fetch albums directly from Firestore - get 10 albums
      final albums = await getAlbumsUseCase.call(params: 10);
      
      print('🔍 AlbumsList: Albums received');
      print('📊 AlbumsList: Total albums found: ${albums.length}');
      
      // Print each album for debugging
      for (int i = 0; i < albums.length; i++) {
        final album = albums[i];
        print('💿 Album $i: [ID: ${album.id}] ${album.title} by ${album.artist}');
      }
      
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
      
      print('🏁 AlbumsList: setState completed. Albums count: ${_albums.length}');
    } catch (e) {
      print('💥 AlbumsList: Exception caught: $e');
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
              'Albums Mới Nhất',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllAlbumsPage(),
                  ),
                );
              },
              child: Text(
                'Xem tất cả',
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
        height: isDesktop ? 280 : (isTablet ? 240 : 200),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: isDesktop ? 280 : (isTablet ? 240 : 200),
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
                'Không thể tải albums',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: context.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: _loadAlbums,
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_albums.isEmpty) {
      return Container(
        height: isDesktop ? 280 : (isTablet ? 240 : 200),
        child: Center(
          child: Text(
            'Không có albums nào',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    return Container(
      height: isDesktop ? 320 : (isTablet ? 280 : 240), // Increased height to fix overflow
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
            itemCount: _albums.length,
            separatorBuilder: (context, index) => SizedBox(
              width: isDesktop ? 20 : (isTablet ? 16 : 12),
            ),
            itemBuilder: (context, index) {
              return _buildAlbumCard(_albums[index], isDesktop, isTablet);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumCard(AlbumEntity album, bool isDesktop, bool isTablet) {
    final cardWidth = isDesktop ? 180.0 : (isTablet ? 160.0 : 140.0);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => sl<AlbumCubit>()..loadAlbumDetails(album.id),
              child: AlbumDetailPage(album: album),
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
          children: [
            // Album Cover
            Container(
              width: cardWidth,
              height: cardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary.withOpacity(0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: isDesktop ? 12 : 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: album.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                      child: Image.network(
                        album.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAlbumCover(isDesktop, isTablet);
                        },
                      ),
                    )
                  : _buildDefaultAlbumCover(isDesktop, isTablet),
            ),
            
            SizedBox(height: isDesktop ? 8 : 6), // Reduced spacing
            
            // Album Title
            Text(
              album.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 15 : (isTablet ? 14 : 13), // Slightly smaller
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 2), // Reduced spacing
            
            // Artist Name
            Text(
              album.artist,
              style: TextStyle(
                fontSize: isDesktop ? 13 : (isTablet ? 12 : 11), // Slightly smaller
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (album.trackCount != null) ...[
              SizedBox(height: 1), // Reduced spacing
              Text(
                '${album.trackCount} bài hát',
                style: TextStyle(
                  fontSize: isDesktop ? 11 : (isTablet ? 10 : 9), // Smaller
                  color: context.isDarkMode ? Colors.white60 : Colors.black45,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAlbumCover(bool isDesktop, bool isTablet) {
    return Center(
      child: Icon(
        Icons.album,
        size: isDesktop ? 60 : (isTablet ? 50 : 40),
        color: Colors.white,
      ),
    );
  }
}