import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/core/configs/assets/app_images.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/presentation/home/widgets/news_songs.dart';
import 'package:app_nghenhac/presentation/home/widgets/play_list.dart';
import 'package:app_nghenhac/presentation/profile/pages/profile.dart';
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
        leading: IconButton(
          onPressed: () {
            // TODO: Implement search functionality
          }, 
          icon: const Icon(
            Icons.search
          )
        ),
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
        action: IconButton(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (BuildContext context) => const ProfilePage())
            );
          }, 
          icon: const Icon(
            Icons.person
          )
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
            ),
            const PlayList()
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
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabButton('News', 0),
            _buildTabButton('Videos', 1),
            _buildTabButton('Artists', 2),
            _buildTabButton('Podcasts', 3),
          ],
        );
      },
    ),
  );
}

Widget _buildTabButton(String text, int index) {
  final isSelected = _tabController.index == index;
  return GestureDetector(
    onTap: () {
      _tabController.animateTo(index);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: isSelected 
          ? Border(bottom: BorderSide(color: AppColors.primary, width: 2))
          : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          fontSize: 14,
          color: isSelected 
            ? (context.isDarkMode ? Colors.white : Colors.black)
            : (context.isDarkMode ? Colors.white60 : Colors.black54),
        ),
      ),
    ),
  );
}
}