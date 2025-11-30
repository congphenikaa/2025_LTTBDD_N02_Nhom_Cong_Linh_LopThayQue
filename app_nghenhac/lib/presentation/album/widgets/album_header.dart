import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:flutter/material.dart';

class AlbumHeader extends StatefulWidget {
  final AlbumEntity album;
  final bool isDesktop;
  final bool isTablet;

  const AlbumHeader({
    super.key,
    required this.album,
    this.isDesktop = false,
    this.isTablet = false,
  });

  @override
  State<AlbumHeader> createState() => _AlbumHeaderState();
}

class _AlbumHeaderState extends State<AlbumHeader> {
  String currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    
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
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.4; // Giới hạn 40% chiều cao màn hình
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: widget.isDesktop ? 300 : (widget.isTablet ? 250 : 200),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 32 : (widget.isTablet ? 24 : 16),
        vertical: widget.isDesktop ? 40 : (widget.isTablet ? 32 : 24),
      ),
      child: widget.isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAlbumCover(size: 280),
        const SizedBox(width: 32),
        Expanded(
          child: _buildAlbumInfo(
            context,
            titleSize: 48,
            artistSize: 24,
            detailsSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final albumCoverSize = widget.isTablet ? 180.0 : 140.0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 3,
          child: _buildAlbumCover(size: albumCoverSize),
        ),
        SizedBox(height: widget.isTablet ? 16 : 12),
        Flexible(
          flex: 2,
          child: _buildAlbumInfo(
            context,
            titleSize: widget.isTablet ? 24 : 20,
            artistSize: widget.isTablet ? 16 : 14,
            detailsSize: widget.isTablet ? 12 : 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumCover({required double size}) {
    return Hero(
      tag: 'album_cover_${widget.album.id}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isDesktop ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isDesktop ? 16 : 12),
          child: widget.album.coverUrl != null
              ? Image.network(
                  widget.album.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultCover(size);
                  },
                )
              : _buildDefaultCover(size),
        ),
      ),
    );
  }

  Widget _buildDefaultCover(double size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.library_music_rounded,
          size: size * 0.4,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildAlbumInfo(
    BuildContext context, {
    required double titleSize,
    required double artistSize,
    required double detailsSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        // Album Type Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.isDarkMode 
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: context.isDarkMode 
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            LanguageService.getTextSync('ALBUM', currentLanguage).toUpperCase(),
            style: TextStyle(
              fontSize: detailsSize - 1,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(height: widget.isDesktop ? 12 : 6),
        
        // Album Title
        Text(
          widget.album.title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
            height: 1.1,
            shadows: context.isDarkMode ? null : [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: widget.isDesktop ? 8 : 4),
        
        // Artist Name
        GestureDetector(
          onTap: () {
            // Navigate to artist page
            // TODO: Implement artist navigation
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: context.isDarkMode 
                  ? Colors.transparent 
                  : Colors.black.withOpacity(0.05),
            ),
            child: Text(
              widget.album.artist,
              style: TextStyle(
                fontSize: artistSize,
                fontWeight: FontWeight.w600,
                color: context.isDarkMode 
                    ? Colors.white.withOpacity(0.9)
                    : Colors.black87,
                decoration: TextDecoration.underline,
                decorationColor: context.isDarkMode 
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black54,
                decorationThickness: 1,
              ),
              textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(height: widget.isDesktop ? 12 : 6),
        
        // Album Details
        _buildAlbumDetails(context, detailsSize),
      ],
    );
  }

  Widget _buildAlbumDetails(BuildContext context, double fontSize) {
    final details = <String>[];
    
    if (widget.album.releaseDate != null) {
      details.add(_formatYear(widget.album.releaseDate!));
    }
    
    if (widget.album.trackCount != null) {
      details.add('${widget.album.trackCount} ${LanguageService.getTextSync("songs", currentLanguage)}');
    }
    
    if (widget.album.genres != null && widget.album.genres!.isNotEmpty) {
      details.add(widget.album.genres!.first);
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: context.isDarkMode 
              ? Colors.black.withOpacity(0.2)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.isDarkMode 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Wrap(
          alignment: widget.isDesktop ? WrapAlignment.start : WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: details.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getDetailIcon(detail),
                  size: fontSize + 2,
                  color: context.isDarkMode 
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: context.isDarkMode 
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (index < details.length - 1) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.isDarkMode 
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatYear(DateTime date) {
    return date.year.toString();
  }

  IconData _getDetailIcon(String detail) {
    if (detail.contains(LanguageService.getTextSync("songs", 'vi')) || 
        detail.contains(LanguageService.getTextSync("songs", 'en'))) {
      return Icons.queue_music_rounded;
    } else if (detail.length == 4 && int.tryParse(detail) != null) {
      // Year
      return Icons.calendar_today_rounded;
    } else {
      // Genre
      return Icons.music_note_rounded;
    }
  }
}