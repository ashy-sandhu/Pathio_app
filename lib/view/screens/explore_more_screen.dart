import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/place_model.dart';
import '../../state/providers/places_provider.dart';
import '../../state/providers/filter_provider.dart';
import '../../state/providers/location_provider.dart';
import '../components/loading_shimmer.dart';
import '../components/error_widget.dart';
import '../components/place_details_sheet.dart';
import 'place_card.dart';

class ExploreMoreScreen extends StatefulWidget {
  final String placeType; // 'popular' or 'nearby'
  final List<Place> initialPlaces;
  final String? selectedCategory;

  const ExploreMoreScreen({
    super.key,
    required this.placeType,
    required this.initialPlaces,
    this.selectedCategory,
  });

  @override
  State<ExploreMoreScreen> createState() => _ExploreMoreScreenState();
}

class _ExploreMoreScreenState extends State<ExploreMoreScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize with the places passed from home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filterProvider = context.read<FilterProvider>();

      // Set the initial category if provided
      if (widget.selectedCategory != null) {
        filterProvider.setSelectedCategory(widget.selectedCategory!);
      }

      // Load places based on type and category
      _loadPlaces();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePlaces();
    }
  }

  Future<void> _loadPlaces() async {
    final placesProvider = context.read<PlacesProvider>();
    final filterProvider = context.read<FilterProvider>();

    if (widget.placeType == 'popular') {
      await placesProvider.loadPopularPlaces(
        category: filterProvider.selectedCategory,
      );
    } else if (widget.placeType == 'nearby') {
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.hasLocation) {
        await placesProvider.loadNearbyPlaces(
          lat: locationProvider.currentLocation!.latitude,
          lon: locationProvider.currentLocation!.longitude,
        );
      }
    }
  }

  Future<void> _loadMorePlaces() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final placesProvider = context.read<PlacesProvider>();

    if (widget.placeType == 'popular') {
      await placesProvider.loadMorePopularPlaces();
    } else if (widget.placeType == 'nearby') {
      await placesProvider.loadMoreNearbyPlaces();
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _onCategoryChanged(String category) async {
    final filterProvider = context.read<FilterProvider>();
    final placesProvider = context.read<PlacesProvider>();

    filterProvider.setSelectedCategory(category);

    if (widget.placeType == 'popular') {
      await placesProvider.loadPopularPlaces(category: category);
    }
    // For nearby places, we don't filter by category as it's location-based
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.placeType == 'popular' ? 'Popular Places' : 'Nearby Places',
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category Filter Section
          _buildCategoryFilter(),

          // Places Grid
          Expanded(
            child: Consumer2<PlacesProvider, FilterProvider>(
              builder: (context, placesProvider, filterProvider, child) {
                final places = widget.placeType == 'popular'
                    ? placesProvider.popularPlaces
                    : placesProvider.nearbyPlaces;

                final isLoading = widget.placeType == 'popular'
                    ? placesProvider.isLoadingPopular
                    : placesProvider.isLoadingNearby;

                final error = widget.placeType == 'popular'
                    ? placesProvider.popularError
                    : placesProvider.nearbyError;

                // Show loading state only when initially loading and no places exist
                if (isLoading && places.isEmpty) {
                  return _buildLoadingGrid();
                }

                // Show error state
                if (error != null) {
                  return CustomErrorWidget(
                    message: 'Failed to load places',
                    onRetry: _loadPlaces,
                  );
                }

                // Show empty state - this must come before GridView to prevent rendering errors
                if (places.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No places found for this category',
                    icon: Icons.explore_off,
                    action: ElevatedButton(
                      onPressed: _loadPlaces,
                      child: const Text('Refresh'),
                    ),
                  );
                }

                // Only render GridView when we have places to display
                return RefreshIndicator(
                  onRefresh: _loadPlaces,
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: places.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the end if loading more
                      if (index >= places.length) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      final place = places[index];
                      return PlaceCard(
                        place: place,
                        onTap: () => _navigateToDetails(place),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // All filter
              _buildFilterChip(
                'All',
                filterProvider.selectedCategory == 'All',
                () => _onCategoryChanged('All'),
              ),

              const SizedBox(width: 8),

              // Category filters
              ...FilterProvider.categories
                  .where((category) => category != 'All')
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        category,
                        filterProvider.selectedCategory == category,
                        () => _onCategoryChanged(category),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const PlaceCardShimmer(
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  void _navigateToDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(place: place),
    );
  }
}
