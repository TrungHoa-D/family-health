import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/shared/utils/bloc_observer.dart';
import 'package:family_health/shared/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app.dart';
import 'di/di.dart';
import 'firebase_options.dart';

Future main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Google Sign-In (not supported on Windows/Linux/macOS desktop)
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      await GoogleSignIn.instance.initialize();
    }

    Bloc.observer = AppBlocObserver();
    EasyLocalization.logger.enableLevels = [
      LevelMessages.error,
      LevelMessages.warning,
    ];
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    await configureDependencies();

    // Persist login: check if user already authenticated
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final AppRouter appRouter = AppRouter();
    getIt.registerSingleton(appRouter);

    // Navigate to Home directly if already logged in
    if (isLoggedIn) {
      appRouter.replaceAll([const HomeRoute()]);
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await EasyLocalization.ensureInitialized();
    _startApp();
  }, (error, stackTrace) {
    logger.e('$error $stackTrace');
  });
}

Future _startApp() async {
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('vi'),
      fallbackLocale: const Locale('vi'),
      child: const MyApp(),
    ),
  );
}
