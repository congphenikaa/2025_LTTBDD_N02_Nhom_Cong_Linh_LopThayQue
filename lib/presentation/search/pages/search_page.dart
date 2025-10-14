import 'package:app_nghenhac/common/widgets/search/album_card.dart';
import 'package:app_nghenhac/common/widgets/search/artist_card.dart';
import 'package:app_nghenhac/common/widgets/search/play_list_card.dart';
import 'package:app_nghenhac/common/widgets/search/song_list_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SearchCubit>(),
      child: Scaffold(
        appBar: BasicAppbar(
          title: const Text('Search'),
        ),
        body: Column(
          children: [
            _buildSearchField(),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return _buildInitialView();
                  } else if (state is SearchLoading) {
                    return _buildLoadingView();
                  } else if (state is SearchSuccess) {
                    return _buildSearchResults(state);
                  } else if (state is SearchFailure) {
                    return _buildErrorView(state.message);
                  } else if (state is SearchEmpty) {
                    return _buildEmptyView();
                  } else if (state is SearchHistoryLoaded) {
                    return _buildHistoryView(state.history);
                  }
                  return Container();
                },
              ),
            ),
          ],
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
                    context.read<SearchCubit>().clearSearch();
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
        onChanged: (value) {
          setState(() {}); // update suffixIcon
          final cubit = context.read<SearchCubit>(); // capture ngay
          if (value.trim().isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              if (_searchController.text == value) {
                cubit.search(value);
              }
            });
          } else {
            cubit.clearSearch();
          }
        },
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        _buildBrowseCategories(),
        const SizedBox(height: 20),
        _buildRecentSearches(),
      ],
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
                context.read<SearchCubit>().search(category['title'] as String);
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                      context.read<SearchCubit>().clearSearchHistory();
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Load search history when widget builds
            FutureBuilder(
              future: context.read<SearchCubit>().getSearchHistory(),
              builder: (context, snapshot) {
                return Container(); // History will be shown via BlocBuilder
              },
            ),
          ],
        );
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
            context.read<SearchCubit>().search(query);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.songs.isNotEmpty) _buildSongsSection(state.songs),
          if (state.artists.isNotEmpty) _buildArtistsSection(state.artists),
          if (state.albums.isNotEmpty) _buildAlbumsSection(state.albums),
          if (state.playlists.isNotEmpty) _buildPlaylistsSection(state.playlists),
          if (state.songs.isEmpty && 
              state.artists.isEmpty && 
              state.albums.isEmpty && 
              state.playlists.isEmpty)
            _buildNoResultsView(),
        ],
      ),
    );
  }

  Widget _buildSongsSection(List<dynamic> songs) {
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
            final song = songs[index]; // This is SongEntity from Firebase
            return SongListTitle( // Sử dụng widget hiện có
              song: song,     // Đúng parameter name
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildArtistsSection(List<dynamic> artists) {
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
              final artist = artists[index]; // This is ArtistEntity
              return ArtistCard(
                artist: artist, // Đúng parameter name
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAlbumsSection(List<dynamic> albums) {
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
              final album = albums[index]; // This is AlbumEntity
              return AlbumCard(
                album: album, // Đúng parameter name
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPlaylistsSection(List<dynamic> playlists) {
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
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index]; // This is PlaylistEntity
              return PlaylistCard(
                playlist: playlist, // Đúng parameter name
              );
            },
          ),
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
                context.read<SearchCubit>().search(_searchController.text);
              }
            },
            child: const Text('Try again'),
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