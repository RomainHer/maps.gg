import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maps_gg/firebase_options.dart';
import 'map_smash.dart';

void main() async {
  if (!kDebugMode) {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  } else {
    debugPrint('Firebase not initialized in debug mode');
  }
  await EasyLocalization.ensureInitialized();
  initializeDateFormatting("fr", null).then(
    (_) => runApp(EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: Locale('fr'),
      child: MapGGApp(),
    )),
  );
}

class MapGGApp extends StatelessWidget {
  const MapGGApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps.gg',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.heeboTextTheme(
          Theme.of(context).textTheme,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF3F7FFD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            textStyle: GoogleFonts.heebo(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: MapSmash(),
    );
  }
}
