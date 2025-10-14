import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:flutter/material.dart';

import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';

class ArtistCard extends StatelessWidget {
  final ArtistEntity artist;
  final VoidCallback? onTap;
  final VoidCallback? onFollowPressed;
  final bool isHorizontal;

  const ArtistCard({
    Key? key,
    required this.artist,
    this.onTap,
    this.onFollowPressed,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isHorizontal ? null : 140,
        padding: const EdgeInsets.all(12),
        child: isHorizontal ? _buildHorizontalLayout(context) : _buildVerticalLayout(context),
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      children: [
        // Artist Image
        _buildArtistImage(),
        const SizedBox(height: 12),
        
        // Artist Name
        Text(
          artist.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        
        // Followers Count
        if (artist.followers != null) ...[
          Text(
            '${_formatFollowers(artist.followers!)} followers',
            style: TextStyle(
              fontSize: 12,
              color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        
        // Follow Button
        if (onFollowPressed != null) _buildFollowButton(context),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      children: [
        // Artist Image
        SizedBox(
          width: 60,
          height: 60,
          child: _buildArtistImage(),
        ),
        const SizedBox(width: 12),
        
        // Artist Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artist.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              if (artist.followers != null)
                Text(
                  '${_formatFollowers(artist.followers!)} followers',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              
              if (artist.genres != null && artist.genres!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  artist.genres!.take(2).join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        
        // Follow Button
        if (onFollowPressed != null) _buildFollowButton(context),
      ],
    );
  }

  Widget _buildArtistImage() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: isHorizontal ? 30 : 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: artist.imageUrl != null
            ? NetworkImage(artist.imageUrl!)
            : null,
        child: artist.imageUrl == null
            ? Icon(
                Icons.person,
                size: isHorizontal ? 30 : 50,
                color: Colors.grey[600],
              )
            : null,
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: artist.isFollowed ? Colors.transparent : AppColors.primary,
        border: Border.all(
          color: AppColors.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onFollowPressed,
        child: Center(
          child: Text(
            artist.isFollowed ? 'Following' : 'Follow',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: artist.isFollowed ? AppColors.primary : Colors.white,
            ),
          ),
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