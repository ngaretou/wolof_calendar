// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:wolof_calendar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './providers/user_prefs.dart';
import './providers/months.dart';
import './providers/theme.dart';
import './providers/play_action.dart';
import './providers/locale.dart';

import './screens/settings_screen.dart';
import './screens/about_screen.dart';

import './screens/date_screen.dart';

void main() {
  if (kIsWeb) {
    //This is to preserve the splash screen til loading is done
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  //now run app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserPrefs(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocaleProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Months(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PlayAction(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Future init;

  //Language code:
  Future<void> setupLang() async {
    // print('setupLang');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Function setLocale =
        Provider.of<LocaleProvider>(context, listen: false).setLocale;

    //If there is no lang pref (i.e. first run), set lang to Wolof
    if (!prefs.containsKey('userLang')) {
      // fr_CH is our Flutter 2.x stand-in for Wolof
      setLocale('fr_CH');
    } else {
      //otherwise grab the saved setting
      String? savedUserLang =
          json.decode(prefs.getString('userLang')!) as String?;
      if (savedUserLang != null) {
        setLocale(savedUserLang);
      }
    }
  }
  //end language code

  @override
  void initState() {
    init = Provider.of<ThemeModel>(context, listen: false)
        .initialSetupAsync(context);
    // Call the intitialization of the locale
    setupLang();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('main.dart build');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arminaatu Wolof',
      home: FutureBuilder(
          future: init,
          builder: (ctx, snapshot) {
            // late Widget returnMe;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return kIsWeb
                  ? const Center(
                      child: SizedBox(
                      width: 10,
                    ))
                  : const Center(child: CircularProgressIndicator());
            } else {
              //remove the loading spinner for web
              if (kIsWeb) FlutterNativeSplash.remove();
              return const DateScreen();
            }
          }),
      theme: Provider.of<ThemeModel>(context).currentTheme,
      routes: {
        SettingsScreen.routeName: (ctx) => const SettingsScreen(),
        AboutScreen.routeName: (ctx) => const AboutScreen(),
        DateScreen.routeName: (ctx) => const DateScreen(),
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', 'FR'),
        // Unfortunately there is a ton of setup to add a new language
        // to Flutter post version 2.0 and intl 0.17.
        // The most doable way to stick with the official Flutter l10n method
        // is to use Swiss French as the main source for the translations
        // and add in the Wolof to the app_fr_ch.arb in the l10n folder.
        // So when we switch locale to fr_CH, that's Wolof. Sorry everyone.
        Locale('fr', 'CH'),
      ],
      locale: Provider.of<LocaleProvider>(context, listen: true).userLocale,
    );
  }
}
