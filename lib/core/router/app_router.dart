import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:travel_guide_app/view/screens/main_screen.dart';
import 'package:travel_guide_app/view/screens/splash_screen.dart';
import 'package:travel_guide_app/view/screens/explore_more_screen.dart';
import 'package:travel_guide_app/data/models/place_model.dart';

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
  ],
);
