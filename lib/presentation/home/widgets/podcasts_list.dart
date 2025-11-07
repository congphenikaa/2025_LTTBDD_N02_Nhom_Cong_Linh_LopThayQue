import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:flutter/material.dart';

class PodcastsList extends StatefulWidget {
  const PodcastsList({super.key});

  @override
  State<PodcastsList> createState() => _PodcastsListState();
}

class _PodcastsListState extends State<PodcastsList> {
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
    
    // Mock podcast data
    final mockPodcasts = [
      {
        'id': '1',
        'title': 'The Joe Rogan Experience',
        'description': 'Deep conversations with interesting people',
        'thumbnail': 'https://tse1.mm.bing.net/th/id/OIP.S_Sf7fy0jFdqpeTeXGcSugHaEo?pid=Api&P=0&h=220',
        'episodes': '2000+',
        'category': 'Talk',
      },
      {
        'id': '2',
        'title': 'Serial',
        'description': 'Investigative journalism podcast',
        'thumbnail': 'http://www.pixelstalk.net/wp-content/uploads/2016/05/Colorful-music-wallpaper-HD.jpg',
        'episodes': '50+',
        'category': 'True Crime',
      },
      {
        'id': '3',
        'title': 'TED Talks Daily',
        'description': 'Ideas worth spreading',
        'thumbnail': 'https://static.vecteezy.com/system/resources/previews/037/044/052/non_2x/ai-generated-studio-shot-of-black-headphones-over-music-note-explosion-background-with-empty-space-for-text-photo.jpg',
        'episodes': '1500+',
        'category': 'Education',
      },
      {
        'id': '4',
        'title': 'The Daily',
        'description': 'This is what the news should sound like',
        'thumbnail': 'http://clipart-library.com/images/6Ty5GE6ac.jpg',
        'episodes': '1000+',
        'category': 'News',
      },
      {
        'id': '5',
        'title': 'Song Exploder',
        'description': 'Musicians take apart their songs',
        'thumbnail': 'https://tse2.mm.bing.net/th/id/OIP.xlZLuwTlZYAy4wLe5GpueAHaEo?pid=Api&P=0&h=220',
        'episodes': '300+',
        'category': 'Music',
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
            return _podcastCard(mockPodcasts[index], context,
              isDesktop: isDesktop, isTablet: isTablet);
          },
          separatorBuilder: (context, index) => SizedBox(
            width: isDesktop ? 20 : (isTablet ? 16 : 14)
          ),
          itemCount: mockPodcasts.length,
        ),
      ),
    );
  }

  Widget _podcastCard(Map<String, String> podcast, BuildContext context,
      {bool isDesktop = false, bool isTablet = false}) {
    final cardWidth = isDesktop ? 160.0 : (isTablet ? 150.0 : 140.0);
    final cardHeight = isDesktop ? 160.0 : (isTablet ? 150.0 : 140.0);
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LanguageService.getTextSync('Opening', _currentLanguage)}: ${podcast['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: cardHeight,
              width: cardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(podcast['thumbnail']!),
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
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              podcast['title']!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 15 : (isTablet ? 14 : 14),
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isDesktop ? 6 : 4),
            Text(
              podcast['description']!,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: isDesktop ? 13 : (isTablet ? 12 : 12),
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isDesktop ? 6 : 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 8 : 6, 
                    vertical: isDesktop ? 3 : 2
                  ),
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    podcast['category']!,
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 10,
                      fontWeight: FontWeight.w500,
                      color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    podcast['episodes']!,
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 10,
                      color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}