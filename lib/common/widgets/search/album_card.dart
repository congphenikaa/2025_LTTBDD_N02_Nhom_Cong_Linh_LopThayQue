import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:flutter/material.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';

class AlbumCard extends StatelessWidget {
  final AlbumEntity album;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final bool isHorizontal;
  final double? width;

  const AlbumCard({
    Key? key,
    required this.album,
    this.onTap,
    this.onFavoritePressed,
    this.isHorizontal = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isHorizontal ? null : (width ?? 160),
        padding: const EdgeInsets.all(8),
        child: isHorizontal ? _buildHorizontalLayout(context) : _buildVerticalLayout(context),
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Album Cover
        Stack(
          children: [
            _buildAlbumCover(),
            Positioned(
              top: 8,
              right: 8,
              child: _buildFavoriteButton(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Album Title
        Text(
          album.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // Artist Name
        Text(
          album.artist,
          style: TextStyle(
            fontSize: 14,
            color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Release Year & Track Count
        if (album.releaseDate != null || album.trackCount != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              if (album.releaseDate != null) ...[
                Text(
                  album.releaseDate!.year.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
              if (album.releaseDate != null && album.trackCount != null)
                Text(
                  ' • ',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              if (album.trackCount != null)
                Text(
                  '${album.trackCount} tracks',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      children: [
        // Album Cover
        Stack(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: _buildAlbumCover(),
            ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Album Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              Text(
                album.artist,
                style: TextStyle(
                  fontSize: 14,
                  color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (album.releaseDate != null || album.trackCount != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (album.releaseDate != null) ...[
                      Text(
                        album.releaseDate!.year.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                    if (album.releaseDate != null && album.trackCount != null)
                      Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    if (album.trackCount != null)
                      Text(
                        '${album.trackCount} tracks',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Favorite Button
        _buildFavoriteButton(context),
      ],
    );
  }

  Widget _buildAlbumCover() {
    return Container(
      width: double.infinity,
      height: isHorizontal ? 80 : 144,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: album.coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                album.coverUrl!,
                width: double.infinity,
                height: isHorizontal ? 80 : 144,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
              ),
            )
          : _buildDefaultCover(),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: double.infinity,
      height: isHorizontal ? 80 : 144,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primary,
          ],
        ),
      ),
      child: Icon(
        Icons.album,
        color: Colors.white,
        size: isHorizontal ? 40 : 60,
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    if (onFavoritePressed == null) return const SizedBox.shrink();
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onFavoritePressed,
        icon: Icon(
          album.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: album.isFavorite ? Colors.red : Colors.white,
          size: 18,
        ),
      ),
    );
  }
}