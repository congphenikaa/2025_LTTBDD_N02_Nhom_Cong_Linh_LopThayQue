import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
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
        children: [
          _profileInfo(context,)
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
}