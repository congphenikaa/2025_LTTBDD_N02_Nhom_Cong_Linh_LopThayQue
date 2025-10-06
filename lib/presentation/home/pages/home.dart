import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/core/configs/assets/app_images.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/presentation/home/widgets/news_songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        hideBack: true,
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _homeTopCard(),
            _tabs(),
            SizedBox(
              height: 260,
              child: TabBarView(
                controller: _tabController,
                children: [
                  const NewsSongs(),
                  Container(),
                  Container(),
                  Container(),
                ],
                
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _homeTopCard(){
    return Center(
      child: SizedBox(
        height: 140,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                AppVectors.homeTopCard
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 60
                ),
                child: Image.asset(
                  AppImages.homeArtist,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
  return TabBar(
    controller: _tabController,
    labelColor: context.isDarkMode ? Colors.white : Colors.black,
    unselectedLabelColor: context.isDarkMode ? Colors.white60 : Colors.black54,
    indicatorColor: AppColors.primary,
    indicatorWeight: 2,
    dividerColor: Colors.transparent,
    labelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14
    ),
    padding: const EdgeInsets.symmetric(
      vertical: 40,
      horizontal: 16
    ),
    tabs: const [
      Tab(text: 'News'),
      Tab(text: 'Videos'),
      Tab(text: 'Artists'),
      Tab(text: 'Podcasts'),
    ],
  );
}
}