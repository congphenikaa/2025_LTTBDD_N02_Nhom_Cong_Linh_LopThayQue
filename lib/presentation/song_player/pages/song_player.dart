import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/drawer/app_drawer.dart';
import 'package:app_nghenhac/common/widgets/favorite_button/favorite_button.dart';
import 'package:app_nghenhac/core/constants/app_urls.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/domain/entities/song/song.dart';
import 'package:app_nghenhac/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:app_nghenhac/presentation/song_player/bloc/song_player_state.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongPlayerPages extends StatefulWidget {
  final SongEntity songEntity;
  const SongPlayerPages({
    super.key,
    required this.songEntity
    });

  @override
  State<SongPlayerPages> createState() => _SongPlayerPagesState();
}

class _SongPlayerPagesState extends State<SongPlayerPages> {
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
    return Scaffold(
      appBar: BasicAppbar(
        title: Text(
          LanguageService.getTextSync('now_playing', _currentLanguage),
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
      body: BlocProvider(
        create: (_) => sl<SongPlayerCubit>()..loadSong(
          '${AppURLs.songFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.mp3?${AppURLs.mediaAlt}'
        ),
        child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _songCover(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            '${AppURLs.coverFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.jpg?${AppURLs.mediaAlt}'
          )
        )
      ),
    );
  }

  Widget _songDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.songEntity.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 5,),
            Text(
              widget.songEntity.artist,
              style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14
              ),
            )
          ],
        ),
        FavoriteButton(
          songEntity: widget.songEntity,
        )
      ],
    );
  }

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state){
        if(state is SongPlayerLoading) {
          return const CircularProgressIndicator();
        }
        if(state is SongPlayerLoaded) {
          return Column(
            children: [
              // Slider với khả năng tương tác
              Slider(
                value: context.read<SongPlayerCubit>().songPosition.inSeconds.toDouble(), 
                min: 0.0,
                max: context.read<SongPlayerCubit>().songDuration.inSeconds.toDouble(),
                onChanged: (value) {
                  final newPosition = Duration(seconds: value.toInt());
                  context.read<SongPlayerCubit>().seekToPosition(newPosition);
                }
              ),
              const SizedBox(height: 20),
              
              // Display time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(
                      context.read<SongPlayerCubit>().songPosition
                    )
                  ),
                  Text(
                    formatDuration(
                      context.read<SongPlayerCubit>().songDuration
                    )
                  )
                ],
              ),
              const SizedBox(height: 30),

              // Các nút điều khiển
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Nút bài trước
                  GestureDetector(
                    onTap: () {
                      context.read<SongPlayerCubit>().previousSong();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode ? Colors.grey[800] : Colors.black45,
                      ),
                      child: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  
                  // Nút tua lùi 5 giây
                  GestureDetector(
                    onTap: () {
                      context.read<SongPlayerCubit>().seekBackward5Seconds();
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode ? Colors.grey[800] : Colors.black45,
                      ),
                      child: const Icon(
                        Icons.replay_5,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Nút play/pause chính
                  GestureDetector(
                    onTap: (){
                      context.read<SongPlayerCubit>().playOrPauseSong();
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode ? Colors.grey[800] : Colors.black45,
                      ),
                      child: Icon(
                        context.read<SongPlayerCubit>().audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  
                  // Nút tua tiến 5 giây
                  GestureDetector(
                    onTap: () {
                      context.read<SongPlayerCubit>().seekForward5Seconds();
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode ? Colors.grey[800] : Colors.black45,
                      ),
                      child: const Icon(
                        Icons.forward_5,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Nút bài tiếp theo
                  GestureDetector(
                    onTap: () {
                      context.read<SongPlayerCubit>().nextSong();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode ? Colors.grey[800] : Colors.black45,
                      ),
                      child: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }

        return Container();
      },
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}';
  }
}