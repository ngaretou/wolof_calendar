import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'locale/app_localization.dart';

import './providers/card_prefs.dart';
import './providers/names.dart';
import './providers/theme.dart';

import './screens/settings_screen.dart';
import './screens/about_screen.dart';
import './screens/cards_screen.dart';
import './screens/onboarding_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CardPrefs(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DivineNames(),
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
  final AppLocalizationDelegate _localeOverrideDelegate =
      AppLocalizationDelegate(Locale('fr', ''));

  @override
  Widget build(BuildContext context) {
    //Don't show top status bar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    print('main.dart build');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '99',
      home: FutureBuilder(
        future: Provider.of<ThemeModel>(context, listen: false)
            .initialSetupAsync(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : Provider.of<CardPrefs>(context, listen: false)
                        .cardPrefs
                        .showOnboarding
                    ? OnboardingScreen()
                    : CardsScreen(),
      ),
      theme: Provider.of<ThemeModel>(context).currentTheme != null
          ? Provider.of<ThemeModel>(context).currentTheme
          : ThemeData.dark(),
      routes: {
        CardsScreen.routeName: (ctx) => CardsScreen(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        AboutScreen.routeName: (ctx) => AboutScreen(),
        OnboardingScreen.routeName: (ctx) => OnboardingScreen(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        _localeOverrideDelegate
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', ''),
        const Locale('wo', '')
      ],
    );
  }
}
