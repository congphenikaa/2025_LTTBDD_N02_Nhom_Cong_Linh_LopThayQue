import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/favorite_button/favorite_button.dart';
import 'package:app_nghenhac/core/constants/app_urls.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:app_nghenhac/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:app_nghenhac/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:app_nghenhac/presentation/profile/bloc/profile_info_state.dart';
import 'package:app_nghenhac/presentation/song_player/pages/song_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String currentLanguage = 'vi';

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
        currentLanguage = LanguageService.languageNotifier.value;
      });
    }
  }

  void _loadLanguage() async {
    final language = await LanguageService.getCurrentLanguage();
    setState(() {
      currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        backgroundColor: context.isDarkMode ? Color(0xff2C2B2B) : Colors.white,
        title: Text(
          LanguageService.getTextSync('Profile', currentLanguage)
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
              LanguageService.getTextSync('Try Again', currentLanguage)
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
              Text(
                LanguageService.getTextSync('Favorite Songs', currentLanguage),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                          return GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => SongPlayerPages(songEntity: state.favoriteSongs[index])
                                )
                              );
                            },
                            child: Row(
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
                                      key: UniqueKey(),
                                      function: () {
                                        context.read<FavoriteSongsCubit>().removeSong(index);
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        }, 
                        separatorBuilder: (context, index) => SizedBox(height: 20,), 
                        itemCount: state.favoriteSongs.length
                      );
                    }
                    if (state is FavoriteSongsFailure) {
                      return Text(
                        LanguageService.getTextSync('Try Again', currentLanguage)
                      );
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