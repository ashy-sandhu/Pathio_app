import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/providers/search_provider.dart';
import '../../data/models/place_model.dart';
import '../components/custom_app_bar.dart';
import '../components/error_widget.dart';
import 'place_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late SearchProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    // Get provider reference without triggering rebuild
    _searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchProvider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchProvider.searchPlaces(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Search Places',
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search places, cities, countries...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchProvider>().clearSearch();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isSearching) {
                  return _buildLoadingState();
                }

                if (searchProvider.hasError) {
                  return CustomErrorWidget(
                    message: searchProvider.searchError ?? 'Search failed',
                    onRetry: () =>
                        searchProvider.searchPlaces(_searchController.text),
                  );
                }

                if (searchProvider.hasSearched &&
                    searchProvider.searchResults.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No places found',
                    icon: Icons.search_off,
                  );
                }

                if (!searchProvider.hasSearched) {
                  return _buildSearchHistory();
                }

                return _buildSearchResults(searchProvider.searchResults);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching...'),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.searchHistory.isEmpty) {
          return const EmptyStateWidget(
            message: 'Start typing to search for places',
            icon: Icons.search,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => searchProvider.clearSearchHistory(),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchProvider.searchHistory.length,
                itemBuilder: (context, index) {
                  final query = searchProvider.searchHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(query),
                    onTap: () {
                      _searchController.text = query;
                      searchProvider.searchPlaces(query);
                    },
                    trailing: IconButton(
                      onPressed: () => searchProvider.removeFromHistory(query),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(List<Place> places) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlaceCard(
            place: place,
            width: double.infinity,
            height: 120,
            onTap: () => _navigateToDetails(place),
          ),
        );
      },
    );
  }

  void _navigateToDetails(Place place) {
    // TODO: Navigate to details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Details for ${place.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
