import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'state/providers/places_provider.dart';
import 'state/providers/location_provider.dart';
import 'state/providers/filter_provider.dart';
import 'state/providers/search_provider.dart';
import 'state/providers/auth_provider.dart';
import 'state/providers/user_profile_provider.dart';
import 'state/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TravelGuideApp());
}

class TravelGuideApp extends StatefulWidget {
  const TravelGuideApp({super.key});

  @override
  State<TravelGuideApp> createState() => _TravelGuideAppState();
}

class _TravelGuideAppState extends State<TravelGuideApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes
    // IndexedStack in MainScreen already preserves state, but we ensure providers maintain state
    if (state == AppLifecycleState.paused) {
      // App is in background - state is automatically preserved by IndexedStack
    } else if (state == AppLifecycleState.resumed) {
      // App is back in foreground - state should be restored automatically
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => PlacesProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => FilterProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Travel Guide',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
