import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/domain/entities/song/song.dart';
import 'package:app_nghenhac/presentation/home/bloc/play_list_cubit.dart';
import 'package:app_nghenhac/presentation/home/bloc/play_list_state.dart';
import 'package:app_nghenhac/presentation/song_player/pages/song_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayList extends StatelessWidget {
  const PlayList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayListCubit()..getPlayList(),      
      child: BlocBuilder<PlayListCubit, PlayListState>(
        builder: (context, state) {
          if(state is PlayListLoading) {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }
          if(state is PlayListLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 40
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Playlist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
              
                      Text(
                        'See More',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: const Color(0xffC6C6C6)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  _songs(state.songs)
                ],
              ),
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (BuildContext context) 
                => SongPlayerPages(songEntity: songs[index],
                )
              )
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.isDarkMode ? AppColors.darkGrey : Color(0xffE6E6E6)
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: context.isDarkMode ? Color(0xff959595) : Color(0xff555555),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songs[index].title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        songs[index].artist,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11
                        ),
                      )
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    songs[index].duration.toString().replaceAll('.', ':')
                  ),
                  const SizedBox(width: 20,),
                  IconButton(
                    onPressed: () {}, 
                    icon: Icon(
                      Icons.favorite_outline_rounded,
                      size: 25,
                      color: AppColors.darkGrey,
                    )
                  )
                ],
              )
            ],
          ),
        );
      }, 
      separatorBuilder: (context, index) => const SizedBox(height: 20,), 
      itemCount: songs.length
    );
  }
}