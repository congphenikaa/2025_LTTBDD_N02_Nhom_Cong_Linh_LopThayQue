import 'package:app_nghenhac/presentation/search/widgets/album_card.dart';
import 'package:app_nghenhac/presentation/search/widgets/artist_card.dart';
import 'package:app_nghenhac/presentation/search/widgets/play_list_card.dart';
import 'package:app_nghenhac/presentation/search/widgets/song_list_title.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/service_locator.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late SearchCubit _searchCubit;
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
    _searchCubit = sl<SearchCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      // Load search history when page opens
      _searchCubit.loadSearchHistory();

    });
  }

  @override
  void dispose() {
    // Hủy listener khi dispose
    LanguageService.languageNotifier.removeListener(_onLanguageChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchCubit.close();
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
    print('🎯 SearchPage build called'); // DEBUG
    
    return BlocProvider<SearchCubit>.value(
      value: _searchCubit,
      child: Scaffold(
        appBar: BasicAppbar(
          title: Text(LanguageService.getTextSync('Search', _currentLanguage)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                bloc: _searchCubit,
                builder: (context, state) {
                  print('🎯 BlocBuilder received state: ${state.runtimeType}');
                  
                  if (state is SearchSuccess) {
                    print('🎯 SearchSuccess in UI:');
                    print('   Songs: ${state.songs.length}');
                    print('   Artists: ${state.artists.length}');
                    print('   Albums: ${state.albums.length}');
                    print('   Playlists: ${state.playlists.length}');
                    
                    // ✅ Gọi method hiển thị widgets thật
                    return _buildSearchResults(state);
                  }
                  
                  if (state is SearchLoading) {
                    print('🎯 SearchLoading in UI');
                    return _buildLoadingView();
                  }
                  
                  if (state is SearchInitial || state is SearchHistoryLoaded) {
                    print('🎯 SearchInitial/HistoryLoaded in UI');
                    return _buildInitialView();
                  }
                  
                  if (state is SearchEmpty) {
                    print('🎯 SearchEmpty in UI');
                    return _buildEmptyView();
                  }
                  
                  if (state is SearchFailure) {
                    print('🎯 SearchFailure in UI: ${state.message}');
                    return _buildErrorView(state.message);
                  }
                  
                  return _buildInitialView(); // Default view
                },
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'What do you want to listen to?',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchCubit.clearSearch();
                  _searchCubit.loadSearchHistory(); // Reload history
                  setState(() {});
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
            print('🔍 Search submitted: "$value"');
            _searchCubit.saveSearchQuery(value.trim());
            _searchCubit.search(value.trim());
          }
      },
      onChanged: (value) {
      setState(() {}); // update suffixIcon
      
      if (value.trim().isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          if (_searchController.text == value) {
            _searchCubit.search(value); // ✅ Use SAME instance
            _searchCubit.saveSearchQuery(value.trim()); // ✅ Use SAME instance
          }
        });
      } else {
        _searchCubit.clearSearch(); // ✅ Use SAME instance
        _searchCubit.loadSearchHistory(); // ✅ Use SAME instance
      }
    },
    ),
  );
}

  Widget _buildInitialView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBrowseCategories(),
          const SizedBox(height: 20),
          _buildRecentSearches(),
        ],
      ),
    );
  }

  Widget _buildBrowseCategories() {
    final categories = [
      {'title': 'Pop', 'color': Colors.red},
      {'title': 'Hip-Hop', 'color': Colors.green},
      {'title': 'Rock', 'color': Colors.blue},
      {'title': 'Jazz', 'color': Colors.purple},
      {'title': 'Classical', 'color': Colors.orange},
      {'title': 'Electronic', 'color': Colors.teal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Browse all',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                _searchController.text = category['title'] as String;
                _searchCubit.search(category['title'] as String); // ✅ Dùng _searchCubit
              },
              child: Container(
                decoration: BoxDecoration(
                  color: category['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    category['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchHistoryLoaded) {
          if (state.history.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'No recent searches',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent searches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                         _searchCubit.clearSearchHistory();
                      },
                      child: Text(LanguageService.getTextSync('Clear All', _currentLanguage)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Show history items with individual delete buttons
                ...state.history.map((query) => _buildHistoryItem(query)).toList(),
              ],
            ),
          );
        }

        // If not SearchHistoryLoaded state, return empty container
        return Container();
      },
    );
  }

  Widget _buildHistoryItem(String query) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(
        query,
        style: TextStyle(
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
        onPressed: () {
          // Remove individual item
          _searchCubit.removeSearchHistoryItem(query);
        },
      ),
      onTap: () {
        _searchController.text = query;
        _searchCubit.search(query); // ✅ Dùng _searchCubit thay vì context.read
      },
    );
  }

  Widget _buildHistoryView(List<String> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No recent searches',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: history.length,
      itemBuilder: (context, index) {
        final query = history[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(query),
          onTap: () {
            _searchController.text = query;
            _searchCubit.search(query);
          },
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSearchResults(SearchSuccess state) {
    return CustomScrollView(
      slivers: [
        // ✅ Sử dụng CustomScrollView để layout linh hoạt
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              
              if (state.songs.isNotEmpty) 
                _buildSongsSection(state.songs),
              
              if (state.albums.isNotEmpty) 
                _buildAlbumsSection(state.albums),
              
              if (state.artists.isNotEmpty) 
                _buildArtistsSection(state.artists),
              
              if (state.playlists.isNotEmpty) 
                _buildPlaylistsSection(state.playlists),
              
              if (state.songs.isEmpty && 
                  state.artists.isEmpty && 
                  state.albums.isEmpty && 
                  state.playlists.isEmpty) 
                _buildNoResultsView(),
              
              const SizedBox(height: 100), // Safe area bottom
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSongsSection(List<SongEntity> songs) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Songs',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SongListTitle(
                song: song,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildArtistsSection(List<ArtistEntity> artists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artists',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ArtistCard(
                  artist: artist,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAlbumsSection(List<AlbumEntity> albums) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Albums',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AlbumCard(
                  album: album,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPlaylistsSection(List<PlaylistEntity> playlists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Playlists',
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        
        // ✅ Sử dụng LayoutBuilder để tính toán space available
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 240, // ✅ Tăng height để đẹp hơn
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: PlaylistCard(
                      playlist: playlist,
                      width: 150, // ✅ Giữ kích thước đẹp
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _searchCubit.search(_searchController.text); // ✅ Dùng _searchCubit
              }
            },
            child: Text(LanguageService.getTextSync('Try Again', _currentLanguage)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off, 
            size: 64, 
            color: context.isDarkMode ? Colors.grey[400] : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Start typing to search',
            style: TextStyle(
              fontSize: 18, 
              color: context.isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off, 
            size: 64, 
            color: context.isDarkMode ? Colors.grey[400] : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: TextStyle(
              color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
}