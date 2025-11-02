import 'package:go_router/go_router.dart';
import 'package:travel_guide_app/view/screens/main_screen.dart';
import 'package:travel_guide_app/view/screens/splash_screen.dart';
import 'package:travel_guide_app/view/screens/explore_more_screen.dart';
import 'package:travel_guide_app/view/screens/login_screen.dart';
import 'package:travel_guide_app/view/screens/signup_screen.dart';
import 'package:travel_guide_app/view/screens/trips_screen.dart';
import 'package:travel_guide_app/view/screens/saved_places_screen.dart';
import 'package:travel_guide_app/view/screens/user_reviews_screen.dart';
import 'package:travel_guide_app/view/screens/settings_screen.dart';
import 'package:travel_guide_app/view/screens/create_trip_screen.dart';
import 'package:travel_guide_app/view/screens/trip_details_screen.dart';
import 'package:travel_guide_app/data/models/place_model.dart';
import 'package:travel_guide_app/data/models/trip_model.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/explore-more',
      name: 'explore-more',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ExploreMoreScreen(
          placeType: extra['placeType'] as String,
          initialPlaces: extra['initialPlaces'] as List<Place>,
          selectedCategory: extra['category'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/trips',
      name: 'trips',
      builder: (context, state) => const TripsScreen(),
    ),
    GoRoute(
      path: '/trips/create',
      name: 'create-trip',
      builder: (context, state) => const CreateTripScreen(),
    ),
    GoRoute(
      path: '/trips/edit/:tripId',
      name: 'edit-trip',
      builder: (context, state) {
        final trip = state.extra as Trip?;
        return CreateTripScreen(trip: trip);
      },
    ),
    GoRoute(
      path: '/trips/:tripId',
      name: 'trip-details',
      builder: (context, state) {
        final tripId = state.pathParameters['tripId']!;
        return TripDetailsScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/saved-places',
      name: 'saved-places',
      builder: (context, state) => const SavedPlacesScreen(),
    ),
    GoRoute(
      path: '/my-reviews',
      name: 'my-reviews',
      builder: (context, state) => const UserReviewsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
