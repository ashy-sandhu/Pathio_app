import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
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
              // Lottie Animation with FutureBuilder to handle errors properly
              SizedBox(
                width: 300,
                height: 300,
                child: FutureBuilder<String>(
                  future: _loadAnimationAsset(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      debugPrint('=== ANIMATION LOAD ERROR ===');
                      debugPrint('Error: ${snapshot.error}');
                      debugPrint('===========================');
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.travel_explore,
                            size: 150,
                            color: AppColors.textOnPrimary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Pathio',
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }

                    final jsonString = snapshot.data;
                    if (jsonString == null || jsonString.isEmpty) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.travel_explore,
                            size: 150,
                            color: AppColors.textOnPrimary,
                          ),
                        ],
                      );
                    }

                    // Parse JSON to validate
                    try {
                      jsonDecode(jsonString);
                    } catch (e) {
                      debugPrint('=== INVALID JSON ===');
                      debugPrint('Error: $e');
                      debugPrint('====================');
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.travel_explore,
                            size: 150,
                            color: AppColors.textOnPrimary,
                          ),
                        ],
                      );
                    }

                    // Load Lottie from string - convert to bytes
                    final bytes = utf8.encode(jsonString);
                    return Lottie.memory(
                      bytes,
                      fit: BoxFit.contain,
                      repeat: false,
                      animate: true,
                      width: 300,
                      height: 300,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('=== LOTTIE MEMORY ERROR ===');
                        debugPrint('Error type: ${error.runtimeType}');
                        debugPrint('Error: $error');
                        debugPrint('Stack trace: $stackTrace');
                        debugPrint('==========================');
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.travel_explore,
                              size: 150,
                              color: AppColors.textOnPrimary,
                            ),
                          ],
                        );
                      },
                      frameBuilder: (context, child, frame) {
                        if (frame == null) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary,
                              ),
                            ),
                          );
                        }
                        return child ?? const SizedBox();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              // App Name
              const Text(
                'Pathio',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Path, Perfected.',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                ),
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

  Future<String> _loadAnimationAsset() async {
    try {
      debugPrint('Loading animation asset...');
      final data = await rootBundle.load('assets/animations/Travel is fun.json');
      debugPrint('Asset loaded. Size: ${data.lengthInBytes} bytes');
      
      // Convert ByteData to String
      final buffer = data.buffer;
      final jsonString = utf8.decode(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      debugPrint('JSON string length: ${jsonString.length} characters');
      debugPrint('First 100 chars: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}');
      
      return jsonString;
    } catch (e, stackTrace) {
      debugPrint('=== FAILED TO LOAD ANIMATION ASSET ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('======================================');
      rethrow;
    }
  }
}
