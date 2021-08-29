import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'providers/user_prefs.dart';
import 'providers/months.dart';
import './providers/theme.dart';

import './screens/settings_screen.dart';
import './screens/about_screen.dart';
import './screens/months_screen.dart';
import './screens/onboarding_screen.dart';
import './screens/date_screen.dart';
import './screens/month_scripture_screen.dart';

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
  // final AppLocalizationsDelegate _localeOverrideDelegate =
  //     AppLocalizationsDelegate(Locale('fr', ''));

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
        OnboardingScreen.routeName: (ctx) => OnboardingScreen(),
        DateScreen.routeName: (ctx) => DateScreen(),
        MonthScriptureScreen.routeName: (ctx) => MonthScriptureScreen(),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', ''),
        const Locale('wo', ''),
      ],
    );
  }
}
