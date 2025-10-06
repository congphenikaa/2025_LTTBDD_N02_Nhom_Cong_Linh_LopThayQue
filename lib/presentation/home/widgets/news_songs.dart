import 'package:app_nghenhac/domain/entities/song/song.dart';
import 'package:app_nghenhac/presentation/home/bloc/news_songs_cubit.dart';
import 'package:app_nghenhac/presentation/home/bloc/news_songs_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewsSongs extends StatelessWidget {
  const NewsSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsSongsCubit(),
      child: SizedBox(
        height: 200,
        child: BlocBuilder<NewsSongsCubit, NewsSongsState>(
          builder: (context, state) {
            if (state is NewsSongsLoading) {
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator()
              );
            }

            if(state is NewsSongsLoaded) {
              return _songs(
                state.songs
              );
            }

            return Container();
          }
        )
        
      ),
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index){
        return Column(
          children: [

          ],
        );
      },
      separatorBuilder: (context, index) => SizedBox(width: 14,), 
      itemCount: songs.length
    );
  }
}