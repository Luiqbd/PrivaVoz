import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/services/service_locator.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/recording/recording_bloc.dart';
import 'presentation/blocs/subscription/subscription_bloc.dart';
import 'presentation/blocs/subscription/subscription_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  await ServiceLocator.init();
  
  // Run app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(const CheckAuthStatus()),
        ),
        BlocProvider<RecordingBloc>(
          create: (_) => RecordingBloc(),
        ),
        BlocProvider<SubscriptionBloc>(
          create: (_) => SubscriptionBloc()..add(const CheckSubscriptionStatus()),
        ),
      ],
      child: const PrivaVozApp(),
    ),
  );
}