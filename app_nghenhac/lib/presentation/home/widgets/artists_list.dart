import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/presentation/home/bloc/artists_cubit.dart';
import 'package:app_nghenhac/presentation/home/bloc/artists_state.dart';
import 'package:app_nghenhac/presentation/artist/pages/artist_detail.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Artists List Widget with Firebase Integration
class ArtistsList extends StatelessWidget {
  const ArtistsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ArtistsCubit>()..getArtists(limit: 20),
      child: const _ArtistsContent(),
    );
  }
}

class _ArtistsContent extends StatefulWidget {
  const _ArtistsContent();

  @override
  State<_ArtistsContent> createState() => _ArtistsContentState();
}

class _ArtistsContentState extends State<_ArtistsContent> {
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    
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
        _currentLanguage = LanguageService.languageNotifier.value;
      });
    }
  }

  Future<void> _loadLanguage() async {
    final language = await LanguageService.getCurrentLanguage();
    if (mounted) {
      setState(() {
        _currentLanguage = language;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : double.infinity,
        ),
        child: BlocBuilder<ArtistsCubit, ArtistsState>(
          builder: (context, state) {
            if (state is ArtistsLoading) {
              return SizedBox(
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.isDarkMode ? AppColors.primary : AppColors.primary,
                    ),
                  ),
                ),
              );
            }
            
            if (state is ArtistsLoadFailure) {
              return SizedBox(
                height: 150,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không thể tải danh sách nghệ sĩ',
                        style: TextStyle(
                          color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ArtistsCubit>().getArtists(limit: 20);
                        },
                        child: Text(LanguageService.getTextSync('Try Again', _currentLanguage)),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (state is ArtistsLoaded) {
              final artists = state.artists;
              
              if (artists.isEmpty) {
                return SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(
                      'Không có nghệ sĩ nào',
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : (isTablet ? 24 : 16)
                ),
                itemBuilder: (context, index) {
                  return _artistCard(artists[index], context, 
                    isDesktop: isDesktop, isTablet: isTablet);
                },
                separatorBuilder: (context, index) => SizedBox(
                  width: isDesktop ? 20 : (isTablet ? 16 : 14)
                ),
                itemCount: artists.length,
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _artistCard(ArtistEntity artist, BuildContext context, 
      {bool isDesktop = false, bool isTablet = false}) {
    final cardWidth = isDesktop ? 140.0 : (isTablet ? 130.0 : 120.0);
    final imageSize = isDesktop ? 140.0 : (isTablet ? 130.0 : 120.0);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailPage(artist: artist),
          ),
        );
      },
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: imageSize,
              width: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: artist.imageUrl != null && artist.imageUrl!.isNotEmpty
                      ? NetworkImage(artist.imageUrl!)
                      : const AssetImage('assets/images/artist.png') as ImageProvider,
                  onError: (error, stackTrace) {
                    print('🖼️ Error loading artist image: $error');
                  },
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isDarkMode 
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: isDesktop ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
            Text(
              artist.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isDesktop ? 6 : 4),
            if (artist.followers != null)
              Text(
                '${_formatFollowers(artist.followers!)} ${LanguageService.getTextSync('Followers', _currentLanguage)}',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: isDesktop ? 13 : (isTablet ? 12 : 12),
                  color: context.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
}