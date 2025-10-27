import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:flutter/material.dart';

// Mock Artists List Widget  
class ArtistsList extends StatelessWidget {
  const ArtistsList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    
    // Mock data for demonstration
    final mockArtists = [
      ArtistEntity(
        id: '1',
        name: 'Taylor Swift',
        imageUrl: 'http://images4.fanpop.com/image/photos/15900000/taylor-swift-taylor-swift-15913910-1600-1200.jpg',
        followers: 87654321,
      ),
      ArtistEntity(
        id: '2', 
        name: 'Drake',
        imageUrl: 'https://citizenside.com/wp-content/uploads/2024/02/drakes-take-care-album-nearing-diamond-certification-says-producer-chase-n-cashe-1708573017.jpg',
        followers: 76543210,
      ),
      ArtistEntity(
        id: '3',
        name: 'Ariana Grande',
        imageUrl: 'https://d.musictimes.com/en/full/92446/ariana-grande.jpg',
        followers: 65432109,
      ),
      ArtistEntity(
        id: '4',
        name: 'The Weeknd',
        imageUrl: 'https://wallpapers.com/images/hd/the-weeknd-headshot-quwd94h55usagnpg.jpg',
        followers: 54321098,
      ),
      ArtistEntity(
        id: '5',
        name: 'Billie Eilish',
        imageUrl: 'https://wallpapers.com/images/hd/billie-eilish-jmnrb3mq3alp1o8f.jpg',
        followers: 43210987,
      ),
      ArtistEntity(
        id: '6',
        name: 'Ed Sheeran',
        imageUrl: 'https://www.euphoriazine.com/wp-content/uploads/2020/12/Photo-credit-Mark-Surridge-HIGH-RES-scaled-e1608593526642.jpg',
        followers: 32109876,
      ),
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
            return _artistCard(mockArtists[index], context, 
              isDesktop: isDesktop, isTablet: isTablet);
          },
          separatorBuilder: (context, index) => SizedBox(
            width: isDesktop ? 20 : (isTablet ? 16 : 14)
          ),
          itemCount: mockArtists.length,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped on ${artist.name}'),
            duration: const Duration(seconds: 1),
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
                  image: NetworkImage(artist.imageUrl ?? 'https://via.placeholder.com/120x120/CCCCCC/FFFFFF?text=?'),
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
            SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
            Text(
              artist.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isDesktop ? 6 : 4),
            if (artist.followers != null)
              Text(
                '${_formatFollowers(artist.followers!)} followers',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: isDesktop ? 13 : (isTablet ? 12 : 12),
                  color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
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