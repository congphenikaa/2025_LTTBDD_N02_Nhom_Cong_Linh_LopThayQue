import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/usecases/album/get_albums.dart';
import 'package:app_nghenhac/presentation/album/bloc/album_cubit.dart';
import 'package:app_nghenhac/presentation/album/pages/album_detail_page.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllAlbumsPage extends StatefulWidget {
  const AllAlbumsPage({super.key});

  @override
  State<AllAlbumsPage> createState() => _AllAlbumsPageState();
}

class _AllAlbumsPageState extends State<AllAlbumsPage> {
  List<AlbumEntity> _albums = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreData = true;
  int _currentLimit = 20;
  String currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _loadAlbums();
    _scrollController.addListener(_onScroll);
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    // Hủy listener khi dispose
    LanguageService.languageNotifier.removeListener(_onLanguageChanged);
    _scrollController.dispose();
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

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreAlbums();
      }
    }
  }

  Future<void> _loadAlbums() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final getAlbumsUseCase = sl<GetAlbumsUseCase>();
      final albums = await getAlbumsUseCase.call(params: _currentLimit);
      
      setState(() {
        _albums = albums;
        _isLoading = false;
        _hasMoreData = albums.length >= _currentLimit;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAlbums() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final getAlbumsUseCase = sl<GetAlbumsUseCase>();
      final newLimit = _currentLimit + 20;
      final albums = await getAlbumsUseCase.call(params: newLimit);
      
      setState(() {
        _albums = albums;
        _currentLimit = newLimit;
        _isLoading = false;
        _hasMoreData = albums.length >= newLimit;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      appBar: BasicAppbar(
        title: Text(
          LanguageService.getTextSync('all_albums', currentLanguage),
          style: TextStyle(
            fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(isDesktop, isTablet),
    );
  }

  Widget _buildBody(bool isDesktop, bool isTablet) {
    if (_isLoading && _albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              LanguageService.getTextSync('loading_albums', currentLanguage),
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null && _albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isDesktop ? 64 : 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              LanguageService.getTextSync('cannot_load_albums', currentLanguage),
              style: TextStyle(
                fontSize: isDesktop ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAlbums,
              child: Text(LanguageService.getTextSync('try_again', currentLanguage)),
            ),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album,
              size: isDesktop ? 64 : 48,
              color: context.isDarkMode ? Colors.white38 : Colors.black38,
            ),
            SizedBox(height: 16),
            Text(
              LanguageService.getTextSync('no_albums_found', currentLanguage),
              style: TextStyle(
                fontSize: isDesktop ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return _buildAlbumsGrid(isDesktop, isTablet);
  }

  Widget _buildAlbumsGrid(bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 6 : (isTablet ? 4 : 2);
    final childAspectRatio = isDesktop ? 0.75 : (isTablet ? 0.8 : 0.85);

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isDesktop ? 20 : (isTablet ? 16 : 12),
              mainAxisSpacing: isDesktop ? 20 : (isTablet ? 16 : 12),
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _albums.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _albums.length) {
                return _buildLoadingItem(isDesktop, isTablet);
              }
              return _buildAlbumGridItem(_albums[index], isDesktop, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumGridItem(AlbumEntity album, bool isDesktop, bool isTablet) {
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
          color: (context.isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(isDesktop ? 12 : 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isDesktop ? 8 : 6),
                  child: album.coverUrl != null
                      ? Image.network(
                          album.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultCover(isDesktop, isTablet);
                          },
                        )
                      : _buildDefaultCover(isDesktop, isTablet),
                ),
              ),
            ),
            
            // Album Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 8,
                  vertical: isDesktop ? 8 : 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      album.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                        color: context.isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      album.artist,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                        color: context.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (album.trackCount != null) ...[
                      SizedBox(height: 1),
                      Text(
                        '${album.trackCount} bài hát',
                        style: TextStyle(
                          fontSize: isDesktop ? 10 : (isTablet ? 9 : 8),
                          color: context.isDarkMode ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCover(bool isDesktop, bool isTablet) {
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
          Icons.album,
          size: isDesktop ? 40 : (isTablet ? 32 : 24),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingItem(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        color: (context.isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}