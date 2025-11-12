// ignore_for_file: sized_box_for_whitespace
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wolof_calendar/l10n/app_localizations.dart';
import 'package:wolof_calendar/widgets/glass_app_bar.dart';

import '../providers/theme.dart';
import '../providers/locale.dart';
import '../providers/user_prefs.dart';

import '../helpers/color_suggestion.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings-screen';

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    final userThemeName = Provider.of<ThemeModel>(
      context,
      listen: false,
    ).userThemeName;
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final Locale? userLocale = localeProvider.userLocale;
    final UserPrefs prefsProvider = Provider.of<UserPrefs>(
      context,
      listen: true,
    );

    final wolof = prefsProvider.userPrefs.wolofVerseEnabled;
    final wolofal = prefsProvider.userPrefs.wolofalVerseEnabled;
    final glassEffects = prefsProvider.userPrefs.glassEffects;
    final backgroundImage = prefsProvider.userPrefs.backgroundImage;
    final changeThemeColorWithBackground =
        prefsProvider.userPrefs.changeThemeColorWithBackground;

    final darkMode = userThemeName == 'darkTheme';

    //Widgets
    //Main template for all setting titles
    Widget settingTitle(String title, IconData icon, Function? tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: Container(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 27,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
                const SizedBox(width: 25),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
      );
    }

    //Main section layout types
    Widget settingRow(title, setting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          title,
          const VerticalDivider(width: 10, color: Colors.white),
          Expanded(child: setting),
          // setting,
        ],
      );
    }

    Widget settingColumn(title, setting) {
      return Column(
        //This aligns titles to the left
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, setting, const Divider()],
      );
    }

    //Now individual implementations of it
    Widget themeTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsTheme,
        Icons.settings_brightness,
        null,
      );
    }

    // Widget backgroundTitle() {
    //   return settingTitle(AppLocalizations.of(context).settingsCardBackground,
    //       Icons.image, null);
    // }

    // Widget directionTitle() {
    //   return settingTitle(AppLocalizations.of(context).settingsCardDirection,
    //       Icons.compare_arrows, null);
    // }

    Widget scriptPickerTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsVerseDisplay,
        Icons.format_quote,
        null,
      );
    }

    Widget languageTitle() {
      return settingTitle(
        AppLocalizations.of(context)!.settingsLanguage,
        Icons.translate,
        null,
      );
    }

    // Original two circle style
    // Widget themeSettings() {
    //   ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    //     padding: const EdgeInsets.all(0),
    //     shape: const CircleBorder(),
    //     //this one must be white
    //     // primary: Colors.white
    //   );

    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //     children: [
    //       ElevatedButton(
    //         style: raisedButtonStyle.copyWith(
    //           backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
    //         ),
    //         child: userThemeName == 'lightTheme'
    //             ? const Icon(
    //                 Icons.check,
    //                 color: Colors.black,
    //               )
    //             : null,
    //         onPressed: () {
    //           themeProvider.setLightTheme();
    //         },
    //       ),
    //       ElevatedButton(
    //         style: raisedButtonStyle.copyWith(
    //           backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
    //         ),
    //         child: userThemeName == 'darkTheme'
    //             ? const Icon(Icons.check, color: Colors.white)
    //             : null,
    //         //must be black
    //         // color: Colors.black,
    //         onPressed: () {
    //           themeProvider.setDarkTheme();
    //         },
    //       ),
    //     ],
    //   );
    // }

    Widget settingPicker(String kind) {
      late Text labelText;
      late bool switchValue;

      if (kind == 'brightness') {
        labelText = Text(
          AppLocalizations.of(context)!.darkMode,
          style: Theme.of(context).textTheme.titleMedium,
        );
        switchValue = darkMode;
      } else if (kind == 'glassEffects') {
        labelText = Text(
          AppLocalizations.of(context)!.glassEffects,
          style: Theme.of(context).textTheme.titleMedium,
        );
        switchValue = glassEffects!;
      } else if (kind == 'backgroundImage') {
        labelText = Text(
          AppLocalizations.of(context)!.backgroundImage,
          style: Theme.of(context).textTheme.titleMedium,
        );
        switchValue = backgroundImage!;
      } else if (kind == 'changeThemeColorWithBackground') {
        labelText = Text(
          AppLocalizations.of(context)!.changeThemeColorWithBackground,
          style: Theme.of(context).textTheme.titleMedium,
        );
        switchValue = changeThemeColorWithBackground!;
      }
      // else if (kind == 'changeThemeColorWithBackground') {
      //   labelText = Text(AppLocalizations.of(context)!.backgroundImage,
      //       style: Theme.of(context).textTheme.titleMedium);
      //   switchValue = backgroundImage!;
      // }
      else if (kind == 'roman') {
        labelText = Text(
          AppLocalizations.of(context)!.settingsVerseinWolof,
          style: Theme.of(context).textTheme.titleMedium,
        );
        switchValue = wolof!;
      } else if (kind == 'arabic') {
        labelText = Text(
          AppLocalizations.of(context)!.settingsVerseinWolofal,
          style: Theme.of(context).textTheme.titleMedium,
        );
        switchValue = wolofal!;
      }

      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 75, end: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // width: 250,
            Expanded(child: labelText),

            // const Expanded(
            //     child: SizedBox(
            //   width: 1,
            // )),
            Switch(
              value: switchValue,
              onChanged: (_) {
                if (kind == 'brightness') {
                  if (!switchValue) {
                    themeProvider.setDarkTheme();
                  } else {
                    themeProvider.setLightTheme();
                  }
                } else if (kind == 'glassEffects') {
                  prefsProvider.savePref('glassEffects', !switchValue);
                } else if (kind == 'backgroundImage') {
                  prefsProvider.savePref('backgroundImage', !switchValue);
                  if (prefsProvider.userPrefs.changeThemeColorWithBackground ==
                      true) {
                    prefsProvider.savePref(
                      'changeThemeColorWithBackground',
                      false,
                    );
                  }
                } else if (kind == 'changeThemeColorWithBackground') {
                  if (prefsProvider.userPrefs.backgroundImage == true) {
                    prefsProvider.savePref(
                      'changeThemeColorWithBackground',
                      !switchValue,
                    );
                  }
                } else if (kind == 'arabic') {
                  //if wolof/roman is on, then go ahead and switch it on or off.
                  if (wolof!) {
                    prefsProvider.savePref('wolofalVerseEnabled', !wolofal!);
                    //but if wolof is not on and you're trying to turn of wolofal, turn on wolof.
                  } else if (!wolof && wolofal!) {
                    prefsProvider.savePref('wolofalVerseEnabled', false);
                    prefsProvider.savePref('wolofVerseEnabled', true);
                  }
                } else if (kind == 'roman') {
                  if (wolofal!) {
                    prefsProvider.savePref('wolofVerseEnabled', !wolof!);
                    //but if wolof is not on and you're trying to turn of wolofal, turn on wolof.
                  } else if (!wolofal && wolof!) {
                    prefsProvider.savePref('wolofVerseEnabled', false);
                    prefsProvider.savePref('wolofalVerseEnabled', true);
                  }
                }
              },
            ),
          ],
        ),
      );
    }

    // Widget scriptPickerOld(String script) {
    //   late Text labelText;
    //   late bool switchValue;

    //   if (script == 'roman') {
    //     labelText = Text(AppLocalizations.of(context)!.settingsVerseinWolof,
    //         style: Theme.of(context).textTheme.titleMedium);
    //     switchValue = wolof!;
    //   } else if (script == 'arabic') {
    //     labelText = Text(AppLocalizations.of(context)!.settingsVerseinWolofal,
    //         style: Theme.of(context).textTheme.titleMedium);
    //     switchValue = wolofal!;
    //   }

    //   return Padding(
    //     padding: const EdgeInsets.only(right: 18.0),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Container(
    //           width: 210,
    //           child: Padding(
    //             padding: const EdgeInsetsDirectional.only(start: 80),
    //             child: Row(
    //               children: [
    //                 labelText,
    //               ],
    //             ),
    //           ),
    //         ),
    //         Switch(
    //           value: switchValue,
    //           onChanged: (_) {
    //             if (script == 'arabic') {
    //               setState(() {
    //                 userPrefs.savePref('wolofalVerseEnabled', !wolofal!);
    //               });
    //             } else if (script == 'roman') {
    //               setState(() {
    //                 userPrefs.savePref('wolofVerseEnabled', !wolof!);
    //               });
    //             }
    //           },
    //         ),
    //       ],
    //     ),
    //   );
    // }

    Widget languageSetting() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            direction: Axis.horizontal,
            spacing: 15,
            children: [
              ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr_CH' ? true : false,
                label: Text(
                  "Wolof",
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                // backgroundColor: Theme.of(context).primaryColor,
                onSelected: (bool selected) {
                  localeProvider.setLocale('fr_CH');
                },
              ),
              ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr' ||
                        userLocale.toString() == 'fr_'
                    ? true
                    : false,

                label: Text(
                  "Français",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // backgroundColor: Theme.of(context).primaryColor,
                // selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  localeProvider.setLocale('fr');
                },
              ),
              ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 10),

                selected: (userLocale.toString() == 'en' ||
                        userLocale.toString() == 'en_')
                    ? true
                    : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // backgroundColor: Theme.of(context).primaryColor,
                // selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  localeProvider.setLocale('en');
                },
              ),
            ],
          ),
        ],
      );
    }

    ///////////////////////////////
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: prefsProvider.userPrefs.glassEffects!
          ? Colors.transparent
          : Theme.of(context).canvasColor,

      appBar: glassAppBar(
        context: context,
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        actions: [],
      ),

      //If the width of the screen is greater or equal to 730 (whether or not is Phone is true)
      //show the wide view
      body: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white12
            : Colors.black12,
        child: BackdropFilter(
          filter: prefsProvider.userPrefs.glassEffects!
              ? ImageFilter.blur(sigmaX: 75, sigmaY: 75)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: prefsProvider.userPrefs.glassEffects!
                ? Colors.transparent
                : Theme.of(context).canvasColor,
            child: MediaQuery.of(context).size.width >= 730
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ListView(
                      children: [
                        themeTitle(),

                        settingPicker('brightness'),
                        settingPicker('glassEffects'),
                        settingPicker('backgroundImage'),
                        // settingPicker('changeThemeColorWithBackground'),
                        const Divider(),
                        // settingRow(backgroundTitle(), backgroundSettings()),
                        // Divider(),
                        // settingRow(directionTitle(), directionSettings()),
                        // Divider(),
                        scriptPickerTitle(),
                        settingPicker('arabic'),
                        settingPicker('roman'),
                        const Divider(),
                        settingRow(languageTitle(), languageSetting()),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      // Container(
                      //   height: 50,
                      //   color: Theme.of(context).colorScheme.primary,
                      // ),
                      themeTitle(),
                      if (kDebugMode)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              suggestColors(context);
                            },
                            child: Text('Theme suggestion to console'),
                          ),
                        ),
                      settingPicker('brightness'),
                      settingPicker('glassEffects'),
                      settingPicker('backgroundImage'),
                      // settingPicker('changeThemeColorWithBackground'),
                      const Divider(),
                      // settingColumn(backgroundTitle(), backgroundSettings()),
                      // settingColumn(directionTitle(), directionSettings()),
                      scriptPickerTitle(),
                      settingPicker('arabic'),
                      settingPicker('roman'),
                      const Divider(),
                      settingColumn(languageTitle(), languageSetting()),
                    ],
                  ),
          ),
        ),
      ),
      // ),
    );
  }
}
