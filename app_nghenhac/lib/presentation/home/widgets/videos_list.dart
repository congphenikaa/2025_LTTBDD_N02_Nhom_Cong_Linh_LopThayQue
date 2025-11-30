import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:flutter/material.dart';

class VideosList extends StatefulWidget {
  const VideosList({super.key});

  @override
  State<VideosList> createState() => _VideosListState();
}

class _VideosListState extends State<VideosList> {
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
    
    // Mock video data
    final mockVideos = [
      {
        'id': '1',
        'title': 'Taylor Swift - Anti-Hero (Music Video)',
        'thumbnail': 'https://tse3.mm.bing.net/th/id/OIP.b1TRolI0thguNLqj1M2jaAHaE8?pid=Api&P=0&h=220',
        'duration': '4:02',
        'views': '123M',
      },
      {
        'id': '2',
        'title': 'Drake - God\'s Plan (Official Video)',
        'thumbnail': 'https://www.rollingstone.com/wp-content/uploads/2023/09/mtv-vma-nsync.jpg?w=1581&h=1054&crop=1',
        'duration': '5:34',
        'views': '98M',
      },
      {
        'id': '3',
        'title': 'Ariana Grande - Thank U, Next',
        'thumbnail': 'https://i.ytimg.com/vi/eVli-tstM5E/maxresdefault.jpg',
        'duration': '3:45',
        'views': '87M',
      },
      {
        'id': '4',
        'title': 'The Weeknd - Blinding Lights',
        'thumbnail': 'https://www.billboard.com/wp-content/uploads/2022/08/blackpink-2022-mtv-vmas-show-billboard-1548.jpg',
        'duration': '3:21',
        'views': '76M',
      },
      {
        'id': '5',
        'title': 'Billie Eilish - Bad Guy',
        'thumbnail': 'https://static.sky.it/images/skytg24/it/spettacolo/musica/2022/08/29/vincitori-mtv-video-music-awards-2022/maneskin-vma-ipa-2.jpg.transform/gallery-horizontal-tablet-2x/0495a4909c82854387a6f3f248e875387cee1713/img.jpg',
        'duration': '3:14',
        'views': '65M',
      },
    ];

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : double.infinity,
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : (isTablet ? 24 : 16)
          ),
          itemBuilder: (context, index) {
            return _videoCard(mockVideos[index], context,
              isDesktop: isDesktop, isTablet: isTablet);
          },
          separatorBuilder: (context, index) => SizedBox(
            width: isDesktop ? 20 : (isTablet ? 16 : 14)
          ),
          itemCount: mockVideos.length,
        ),
      ),
    );
  }

  Widget _videoCard(Map<String, String> video, BuildContext context,
      {bool isDesktop = false, bool isTablet = false}) {
    final cardWidth = isDesktop ? 200.0 : (isTablet ? 180.0 : 160.0);
    final cardHeight = isDesktop ? 150.0 : (isTablet ? 135.0 : 120.0);
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing: ${video['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: cardHeight,
                  width: cardWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(video['thumbnail']!),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: isDesktop ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 8 : 6, 
                      vertical: isDesktop ? 4 : 2
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['duration']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 13 : (isTablet ? 12 : 12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: isDesktop ? 50 : (isTablet ? 45 : 40),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              video['title']!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 15 : (isTablet ? 14 : 13),
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isDesktop ? 6 : 4),
            Text(
              '${video['views']} ${LanguageService.getTextSync('views', _currentLanguage)}',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: isDesktop ? 13 : (isTablet ? 12 : 12),
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}