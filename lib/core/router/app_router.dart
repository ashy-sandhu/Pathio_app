import 'package:go_router/go_router.dart';
import 'package:travel_guide_app/view/screens/main_screen.dart';
import 'package:travel_guide_app/view/screens/splash_screen.dart';
import 'package:travel_guide_app/view/screens/explore_more_screen.dart';
import 'package:travel_guide_app/view/screens/login_screen.dart';
import 'package:travel_guide_app/view/screens/signup_screen.dart';
import 'package:travel_guide_app/view/screens/email_verification_screen.dart';
import 'package:travel_guide_app/view/screens/trips_screen.dart';
import 'package:travel_guide_app/view/screens/saved_places_screen.dart';
import 'package:travel_guide_app/view/screens/user_reviews_screen.dart';
import 'package:travel_guide_app/view/screens/settings_screen.dart';
import 'package:travel_guide_app/view/screens/create_trip_screen.dart';
import 'package:travel_guide_app/view/screens/trip_details_screen.dart';
import 'package:travel_guide_app/view/screens/privacy_policy_screen.dart';
import 'package:travel_guide_app/view/screens/help_support_screen.dart';
import 'package:travel_guide_app/view/screens/edit_profile_screen.dart';
import 'package:travel_guide_app/view/screens/security_screen.dart';
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
      builder: (context, state) {
        // Get tab index from query parameter
        final tabParam = state.uri.queryParameters['tab'];
        final tabIndex = tabParam != null ? int.tryParse(tabParam) : null;
        return MainScreen(initialTabIndex: tabIndex);
      },
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
      path: '/email-verification',
      name: 'email-verification',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return EmailVerificationScreen(email: email);
      },
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
    GoRoute(
      path: '/privacy-policy',
      name: 'privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/help-support',
      name: 'help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/security',
      name: 'security',
      builder: (context, state) => const SecurityScreen(),
    ),
  ],
);
