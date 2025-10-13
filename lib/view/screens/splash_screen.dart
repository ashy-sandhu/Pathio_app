import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // navigate to home after a short delay
    Future.microtask(() async {
      await Future.delayed(const Duration(seconds: 2));
      // navigate by name
      if (context.mounted) {
        context.goNamed('home');
      }
    });

    return const Scaffold(
      body: Center(
        child: Text(
          'Travel Guide\nLoading...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
