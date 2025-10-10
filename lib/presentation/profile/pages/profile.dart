import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/favorite_button/favorite_button.dart';
import 'package:app_nghenhac/core/constants/app_urls.dart';
import 'package:app_nghenhac/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:app_nghenhac/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:app_nghenhac/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:app_nghenhac/presentation/profile/bloc/profile_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        backgroundColor: Color(0xff2C2B2B),
        title: Text(
          'Profile'
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileInfo(context,),
          const SizedBox(height: 30,),
          _favoriteSongs(),
        ],
      ),
    );
  }
  Widget _profileInfo(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Container(
        height: MediaQuery.of(context).size.height / 3.5,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.isDarkMode ? Color(0xff2C2B2B) : Colors.white,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50),
            bottomLeft: Radius.circular(50)
          )
        ),
        child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
        builder: (context, state) {
          if(state is ProfileInfoLoading) {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator()
            );
          }
          if(state is ProfileInfoLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        state.userEntity.imageURl!
                      )
                    )
                  )
                ),
                const SizedBox(height: 15,),
                Text(
                  state.userEntity.email!
                ),
                const SizedBox(height: 15,),
                Text(
                  state.userEntity.fullName!,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            );
          }

          if(state is ProfileInfoFailure) {
            return Text(
              'Please try again'
            );
          }

          return Container();
        }
      ),
      ),
    );
  }

  Widget _favoriteSongs() {
    return BlocProvider(
      create: (context) => FavoriteSongsCubit()..getFavoriteSongs(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FAVORITE SONGS',
              ),
              SizedBox(height: 20,),
          
              BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
                builder: (context, state) {
                    if(state is FavoriteSongsLoading) {
                      return CircularProgressIndicator();
                    }
                    if(state is FavoriteSongsLoaded) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index){
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          '${AppURLs.coverFirestorage}${state.favoriteSongs[index].artist} - ${state.favoriteSongs[index].title}.jpg?${AppURLs.mediaAlt}'
                                        )
                                      )
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.favoriteSongs[index].title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Text(
                                        state.favoriteSongs[index].artist,
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
                                    state.favoriteSongs[index].duration.toString().replaceAll('.', ':')
                                  ),
                                  const SizedBox(width: 20,),
                                  FavoriteButton(
                                    songEntity: state.favoriteSongs[index],
                                    function: () {
                                      context.read<FavoriteSongsCubit>().removeSong(index);
                                    },
                                  )
                                ],
                              )
                            ],
                          );
                        }, 
                        separatorBuilder: (context, index) => SizedBox(height: 20,), 
                        itemCount: state.favoriteSongs.length
                      );
                    }
                    if (state is FavoriteSongsFailure) {
                      return Text('Please try again.');
                    }
                  return Container();
                  }
                )
              ]
          ),
        ),
    );
  }
}