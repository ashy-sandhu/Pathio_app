import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Navigate to home after animation completes (3 seconds) or minimum delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed('home');
      }
    });
  }

  TextStyle _getTitleStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineLarge;
    if (baseStyle == null) {
      return const TextStyle(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      );
    }
    return baseStyle.copyWith(
      color: AppColors.textOnPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    );
  }

  TextStyle _getSubtitleStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.titleMedium;
    if (baseStyle == null) {
      return TextStyle(
        color: AppColors.textOnPrimary.withOpacity(0.9),
        fontSize: 16,
      );
    }
    return baseStyle.copyWith(
      color: AppColors.textOnPrimary.withOpacity(0.9),
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation with error handling
              SizedBox(
                width: 300,
                height: 300,
                child: _hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.travel_explore,
                            size: 150,
                            color: AppColors.textOnPrimary,
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      )
                    : Lottie.asset(
                        'assets/animations/splash_screen.json',
                        fit: BoxFit.contain,
                        repeat: false,
                        animate: true,
                        width: 300,
                        height: 300,
                        errorBuilder: (context, error, stackTrace) {
                          // Log error for debugging
                          debugPrint('=== LOTTIE ANIMATION ERROR ===');
                          debugPrint('Error: $error');
                          debugPrint('Stack trace: $stackTrace');
                          debugPrint('Asset path: assets/animations/splash_screen.json');
                          debugPrint('===============================');
                          
                          // Set error flag on next frame
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _hasError = true;
                                _errorMessage = 'Failed to load animation:\n${error.toString()}';
                              });
                            }
                          });
                          // Return fallback icon
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.travel_explore,
                                size: 150,
                                color: AppColors.textOnPrimary,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Animation Error',
                                  style: TextStyle(
                                    color: AppColors.textOnPrimary,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        },
                        frameBuilder: (context, child, frame) {
                          if (frame == null) {
                            // Animation is still loading
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textOnPrimary,
                                ),
                              ),
                            );
                          }
                          return child;
                        },
                      ),
              ),
              const SizedBox(height: 40),
              // App Name
              Text(
                'Travel Guide',
                style: _getTitleStyle(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover amazing places',
                style: _getSubtitleStyle(context),
              ),
              const SizedBox(height: 60),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
