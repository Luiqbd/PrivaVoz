import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/splash_page.dart';

/// PrivaVoz App Configuration
class PrivaVozApp extends StatelessWidget {
  const PrivaVozApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0A0A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'PrivaVoz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      builder: (context, child) {
        // Apply glassmorphism overlay to entire app
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF0F0F0F),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}