import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../data/models/place_model.dart';
import '../../state/providers/location_provider.dart';
import '../../core/theme/app_colors.dart';
import '../components/place_details_sheet.dart';

class PlacesMapCard extends StatefulWidget {
  final List<Place> nearbyPlaces;
  final Function(Place)? onPlaceTap;

  const PlacesMapCard({super.key, required this.nearbyPlaces, this.onPlaceTap});

  @override
  State<PlacesMapCard> createState() => _PlacesMapCardState();
}

class _PlacesMapCardState extends State<PlacesMapCard> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _userLocation;
  LatLng? _mapCenter;

  // Map style to hide POI labels
  static const String _mapStyle = '''
    [
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      }
    ]
  ''';

  @override
  void initState() {
    super.initState();
    // Don't initialize here - wait for location to be available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize when dependencies change (location becomes available)
    // Use addPostFrameCallback to avoid blocking the build process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeMap();
      }
    });
  }

  void _initializeMap() {
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.hasLocation && _userLocation == null) {
      _userLocation = LatLng(
        locationProvider.currentLocation!.latitude,
        locationProvider.currentLocation!.longitude,
      );
      _mapCenter = _userLocation;
      _createMarkers();

      if (kDebugMode) {
        print('🗺️ Map initialized with ${widget.nearbyPlaces.length} markers');
      }
    }
  }

  void _createMarkers() {
    if (_userLocation == null) return;

    _markers.clear();

    // Add user location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current position',
        ),
      ),
    );

    // Limit markers to prevent memory issues (max 20 markers)
    final limitedPlaces = widget.nearbyPlaces.take(20).toList();

    for (int i = 0; i < limitedPlaces.length; i++) {
      final place = limitedPlaces[i];
      _markers.add(
        Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.lat, place.lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: place.name, snippet: place.category),
          onTap: () => _onMarkerTapped(place),
        ),
      );
    }

    if (kDebugMode) {
      print(
        '🗺️ Created ${_markers.length} markers (${limitedPlaces.length} places)',
      );
    }

    setState(() {});
  }

  void _onMarkerTapped(Place place) {
    if (widget.onPlaceTap != null) {
      widget.onPlaceTap!(place);
    } else {
      // Default behavior - show place details sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PlaceDetailsSheet(place: place),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (_userLocation == null) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Location not available',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.map, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore on Map',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Tap markers to view place details',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Center map on user location with ~3km radius
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_userLocation!, 15),
                    );
                  },
                  icon: Icon(Icons.my_location, color: AppColors.primary),
                  tooltip: 'Center on my location',
                ),
              ],
            ),
          ),
          // Map
          Container(
            height: 250,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _mapCenter!,
                  zoom: 15, // Zoomed out to show ~3km radius
                ),
                style: _mapStyle,
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // We have custom button
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                mapType: MapType.normal,
                // Enable all gestures including pinch-to-zoom
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                  Factory<ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer(),
                  ),
                  Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                  Factory<LongPressGestureRecognizer>(
                    () => LongPressGestureRecognizer(),
                  ),
                },
                onTap: (LatLng position) {
                  // Hide any open info windows by recreating markers
                  setState(() {
                    _createMarkers();
                  });
                },
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildLegendItem(
                  icon: Icons.location_on,
                  color: Colors.blue,
                  label: 'Your Location',
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  icon: Icons.location_on,
                  color: Colors.red,
                  label: 'Nearby Places',
                ),
                const Spacer(),
                Text(
                  '${widget.nearbyPlaces.length} places',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
