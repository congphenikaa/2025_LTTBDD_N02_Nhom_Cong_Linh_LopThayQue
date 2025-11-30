import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/bottombar/bottom_bar.dart';
import 'package:app_nghenhac/common/widgets/drawer/app_drawer.dart';
import 'package:app_nghenhac/core/configs/assets/app_images.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/presentation/home/widgets/news_songs.dart';
import 'package:app_nghenhac/presentation/home/widgets/play_list.dart';
import 'package:app_nghenhac/presentation/home/widgets/artists_list.dart';
import 'package:app_nghenhac/presentation/home/widgets/videos_list.dart';
import 'package:app_nghenhac/presentation/home/widgets/podcasts_list.dart';
import 'package:app_nghenhac/presentation/home/widgets/albums_list.dart';
import 'package:app_nghenhac/presentation/home/widgets/playlists_list.dart';
import 'package:app_nghenhac/presentation/profile/pages/profile.dart';
import 'package:app_nghenhac/presentation/search/bloc/search_cubit.dart';
import 'package:app_nghenhac/presentation/search/pages/search_page.dart';
import 'package:app_nghenhac/presentation/language/pages/language_settings_page.dart';
import 'package:app_nghenhac/presentation/about/pages/about_page.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedBottomBarIndex = 0;
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLanguage();
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    // Hủy listener khi dispose
    LanguageService.languageNotifier.removeListener(_onLanguageChanged);
    _tabController.dispose();
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

  void _onBottomBarItemTapped(int index) {
    setState(() {
      _selectedBottomBarIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home, no action needed
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => sl<SearchCubit>(),
              child: const SearchPage(),
            ),
          ),
        ).then((_) {
          setState(() {
            _selectedBottomBarIndex = 0;
          });
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        ).then((_) {
          setState(() {
            _selectedBottomBarIndex = 0;
          });
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        ).then((_) {
          // Reset selected index when returning
          setState(() {
            _selectedBottomBarIndex = 0;
          });
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      appBar: BasicAppbar(
        hideBack: true,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const LanguageSettingsPage())
            );
            // Không cần gọi _loadLanguage() nữa vì đã có listener
          }, 
          icon: const Icon(
            Icons.language
          )
        ),
        title: SvgPicture.asset(
          AppVectors.logo,
          height: isDesktop ? 50 : 40,
          width: isDesktop ? 50 : 40,
        ),
        action: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _homeTopCard(isDesktop: isDesktop, isTablet: isTablet),
            _tabs(isDesktop: isDesktop, isTablet: isTablet),
            SizedBox(
              height: isDesktop ? 320 : (isTablet ? 280 : 260),
              child: TabBarView(
                controller: _tabController,
                children: [
                  const NewsSongs(),
                  const VideosList(),
                  const ArtistsList(),
                  const PodcastsList(),
                ],
              ),
            ),
            const PlayList(),
            const AlbumsList(),
            PlaylistsList(),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : AnimatedBottomBar(
              selectedIndex: _selectedBottomBarIndex,
              onItemTapped: _onBottomBarItemTapped,
            ),
    );
  }

  Widget _homeTopCard({bool isDesktop = false, bool isTablet = false}) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : double.infinity,
        ),
        child: SizedBox(
          height: isDesktop ? 180 : (isTablet ? 160 : 140),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(AppVectors.homeTopCard),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isDesktop ? 80 : (isTablet ? 70 : 60),
                  ),
                  child: Image.asset(
                    AppImages.homeArtist,
                    height: isDesktop ? 120 : (isTablet ? 110 : 100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs({bool isDesktop = false, bool isTablet = false}) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : double.infinity,
        ),
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 30 : (isTablet ? 25 : 20),
          horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        ),
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return isDesktop
                ? _buildDesktopTabs()
                : _buildMobileTabs(isTablet: isTablet);
          },
        ),
      ),
    );
  }

  Widget _buildDesktopTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton(
          LanguageService.getTextSync('News', _currentLanguage),
          0,
          isDesktop: true,
        ),
        const SizedBox(width: 40),
        _buildTabButton(
          LanguageService.getTextSync('Videos', _currentLanguage),
          1,
          isDesktop: true,
        ),
        const SizedBox(width: 40),
        _buildTabButton(
          LanguageService.getTextSync('Artists', _currentLanguage),
          2,
          isDesktop: true,
        ),
        const SizedBox(width: 40),
        _buildTabButton(
          LanguageService.getTextSync('Podcasts', _currentLanguage),
          3,
          isDesktop: true,
        ),
      ],
    );
  }

  Widget _buildMobileTabs({bool isTablet = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabButton(
          LanguageService.getTextSync('News', _currentLanguage),
          0,
          isTablet: isTablet,
        ),
        _buildTabButton(
          LanguageService.getTextSync('Videos', _currentLanguage),
          1,
          isTablet: isTablet,
        ),
        _buildTabButton(
          LanguageService.getTextSync('Artists', _currentLanguage),
          2,
          isTablet: isTablet,
        ),
        _buildTabButton(
          LanguageService.getTextSync('Podcasts', _currentLanguage),
          3,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildTabButton(
    String text,
    int index, {
    bool isDesktop = false,
    bool isTablet = false,
  }) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 12 : (isTablet ? 10 : 8),
          horizontal: isDesktop ? 20 : (isTablet ? 16 : 12),
        ),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.primary,
                    width: isDesktop ? 3 : 2,
                  ),
                )
              : null,
          borderRadius: isDesktop ? BorderRadius.circular(8) : null,
          color: isDesktop && isSelected
              ? AppColors.primary.withOpacity(0.1)
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
            color: isSelected
                ? (context.isDarkMode ? Colors.white : Colors.black)
                : (context.isDarkMode ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
