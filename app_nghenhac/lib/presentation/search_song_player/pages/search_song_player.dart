import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/drawer/app_drawer.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SearchSongPlayerPages extends StatefulWidget {
  final SongEntity songEntity;
  const SearchSongPlayerPages({
    super.key,
    required this.songEntity
  });

  @override
  State<SearchSongPlayerPages> createState() => _SearchSongPlayerPagesState();
}

class _SearchSongPlayerPagesState extends State<SearchSongPlayerPages> {
  late AudioPlayer _audioPlayer;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
    
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      if (widget.songEntity.audioUrl != null && widget.songEntity.audioUrl!.isNotEmpty) {
        await _audioPlayer.setUrl(widget.songEntity.audioUrl!);
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = LanguageService.getTextSync('No audio URL available', _currentLanguage);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '${LanguageService.getTextSync('Error loading song', _currentLanguage)}: $e';
      });
    }
  }

  @override
  void dispose() {
    // Hủy listener khi dispose
    LanguageService.languageNotifier.removeListener(_onLanguageChanged);
    _audioPlayer.dispose();
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
    return Scaffold(
      appBar: BasicAppbar(
        title: Text(
          LanguageService.getTextSync('Now Playing', _currentLanguage),
          style: TextStyle(
            fontSize: 18
          ),
        ),
        action: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            }, 
            icon: const Icon(
              Icons.menu
            )
          ),
        ),
      ),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child: Column(
          children: [
            _songCover(context),
            const SizedBox(height: 20,),
            _songDetail(),
            const SizedBox(height: 30,),
            _songPlayer(context)
          ],
        ),
      ),
    );
  }

  Widget _songCover(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.primary.withOpacity(0.1),
        image: widget.songEntity.coverUrl != null 
          ? DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.songEntity.coverUrl!)
            )
          : null,
      ),
      child: widget.songEntity.coverUrl == null 
        ? Center(
            child: Icon(
              Icons.music_note_rounded,
              size: 80,
              color: AppColors.primary,
            ),
          )
        : null,
    );
  }

  Widget _songDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.songEntity.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5,),
              Text(
                widget.songEntity.artist,
                style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.songEntity.album != null) ...[
                const SizedBox(height: 3,),
                Text(
                  widget.songEntity.album!,
                  style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.grey
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Add to favorites
          },
          icon: Icon(
            widget.songEntity.isFavorite 
              ? Icons.favorite
              : Icons.favorite_border,
            color: widget.songEntity.isFavorite 
              ? AppColors.primary 
              : Colors.grey,
            size: 28,
          ),
        )
      ],
    );
  }

  Widget _songPlayer(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Column(
        children: [
          const Icon(
            Icons.error,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            LanguageService.getTextSync('Cannot play music', _currentLanguage),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      children: [
        // Progress Bar
        Slider(
          value: _position.inSeconds.toDouble(),
          max: _duration.inSeconds.toDouble(),
          activeColor: AppColors.primary,
          onChanged: (value) async {
            await _audioPlayer.seek(Duration(seconds: value.toInt()));
          },
        ),
        const SizedBox(height: 20,),
        
        // Time Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatDuration(_position),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              formatDuration(_duration),
              style: const TextStyle(fontSize: 12),
            )
          ],
        ),
        const SizedBox(height: 30,),
        
        // Control Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Previous (placeholder)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_previous),
              iconSize: 40,
              color: Colors.grey,
            ),
            
            // Play/Pause
            GestureDetector(
              onTap: () async {
                if (_isPlaying) {
                  await _audioPlayer.pause();
                } else {
                  await _audioPlayer.play();
                }
              },
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying 
                      ? Icons.pause 
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
            
            // Next (placeholder)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_next),
              iconSize: 40,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}