import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './providers/user_prefs.dart';
import './providers/months.dart';
import './providers/theme.dart';

import './screens/settings_screen.dart';
import './screens/about_screen.dart';
import './screens/months_screen.dart';
import './screens/date_screen.dart';
import './screens/month_scripture_screen.dart';
// import 'package:intl/date_symbol_data_local.dart';

void main() {
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
          create: (ctx) => Months(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //Language code:
  Future<void> setupLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Function setLocale =
        Provider.of<ThemeModel>(context, listen: false).setLocale;

    //If there is no lang pref (i.e. first run), set lang to Wolof
    if (!prefs.containsKey('userLang')) {
      // fr_CH is our Flutter 2.x standin for Wolof
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
    super.initState();
    setupLang();
  }

  @override
  Widget build(BuildContext context) {
    //Don't show top status bar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    print('main.dart build');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arminaat Wolof',
      home: FutureBuilder(
        future: Provider.of<ThemeModel>(context, listen: false)
            .initialSetupAsync(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : MonthsScreen(),
      ),
      theme: Provider.of<ThemeModel>(context).currentTheme,
      routes: {
        MonthsScreen.routeName: (ctx) => MonthsScreen(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        AboutScreen.routeName: (ctx) => AboutScreen(),
        DateScreen.routeName: (ctx) => DateScreen(),
        MonthScriptureScreen.routeName: (ctx) => MonthScriptureScreen(),
      },
      //After importing flutter_localizations.dart, we add the localizationsDelegates and supportedLocales props to the MaterialApp constructor.
      //localizationsDelegates provide localizations to our app. The ones included above provide localizations for Flutter widgets, Material, and Cupertino, which have already been localized by the Flutter team.
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // WoMaterialLocalizations.delegate,
      ],

      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', 'FR'),
        // Unfortunately there is a ton of setup to add a new language
        // to Flutter post version 2.0 and intl 0.17.
        // The most doable way to stick with the official Flutter l10n method
        // is to use Swiss French as the main source for the translations
        // and add in the Wolof to the app_fr_ch.arb in the l10n folder.
        // So when we switch locale to fr_CH, that's Wolof.
        const Locale('fr', 'CH'),
      ],
      locale: Provider.of<ThemeModel>(context, listen: true).userLocale,
    );
  }
}
