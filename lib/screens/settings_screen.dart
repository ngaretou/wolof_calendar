// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme.dart';
import '../providers/user_prefs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '/settings-screen';

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    final userThemeName =
        Provider.of<ThemeModel>(context, listen: false).userThemeName;
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    Locale? userLocale =
        Provider.of<ThemeModel>(context, listen: false).userLocale;
    final userPrefs = Provider.of<UserPrefs>(context, listen: false);
    final wolof = userPrefs.userPrefs.wolofVerseEnabled;
    final wolofal = userPrefs.userPrefs.wolofalVerseEnabled;

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
                      color: Theme.of(context).textTheme.headline6!.color,
                    ),
                    const SizedBox(width: 25),
                    Text(title, style: Theme.of(context).textTheme.headline6),
                  ],
                ))),
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
          Expanded(
            child: setting,
          )
          // setting,
        ],
      );
    }

    Widget settingColumn(title, setting) {
      return Column(
        //This aligns titles to the left
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          setting,
          const Divider(),
        ],
      );
    }

    //Now individual implementations of it
    Widget themeTitle() {
      return settingTitle(AppLocalizations.of(context)!.settingsTheme,
          Icons.settings_brightness, null);
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
      return settingTitle(AppLocalizations.of(context)!.settingsVerseDisplay,
          Icons.format_quote, null);
    }

    Widget languageTitle() {
      return settingTitle(AppLocalizations.of(context)!.settingsLanguage,
          Icons.translate, null);
    }

    Widget themeSettings() {
      ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        shape: const CircleBorder(),
        //this one must be white
        // primary: Colors.white
      );

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: raisedButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: userThemeName == 'lightTheme'
                ? const Icon(
                    Icons.check,
                    color: Colors.black,
                  )
                : null,
            onPressed: () {
              themeProvider.setLightTheme();
            },
          ),
          ElevatedButton(
            style: raisedButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            child:
                userThemeName == 'blueTheme' ? const Icon(Icons.check) : null,
            //must be blue
            // color: Colors.blue,
            onPressed: () {
              themeProvider.setBlueTheme();
            },
          ),
          ElevatedButton(
              style: raisedButtonStyle.copyWith(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
              ),
              child:
                  userThemeName == 'tealTheme' ? const Icon(Icons.check) : null,
              //must be teal
              // color: Colors.teal,
              onPressed: () {
                themeProvider.setTealTheme();
              }),
          ElevatedButton(
            style: raisedButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
            child: userThemeName == 'darkTheme'
                ? const Icon(Icons.check, color: Colors.white)
                : null,
            //must be black
            // color: Colors.black,
            onPressed: () {
              setState(() {
                themeProvider.setDarkTheme();
              });
            },
          ),
        ],
      );
    }

    Widget scriptPicker(String script) {
      late Text labelText;
      late bool switchValue;

      if (script == 'roman') {
        labelText = Text(AppLocalizations.of(context)!.settingsVerseinWolof,
            style: Theme.of(context).textTheme.subtitle1);
        switchValue = wolof!;
      } else if (script == 'arabic') {
        labelText = Text(AppLocalizations.of(context)!.settingsVerseinWolofal,
            style: Theme.of(context).textTheme.subtitle1);
        switchValue = wolofal!;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 210,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 80),
              child: Row(
                children: [
                  labelText,
                ],
              ),
            ),
          ),
          Expanded(
            child: Switch(
              value: switchValue,
              onChanged: (_) {
                if (script == 'arabic') {
                  setState(() {
                    userPrefs.savePref('wolofalVerseEnabled', !wolofal!);
                  });
                } else if (script == 'roman') {
                  setState(() {
                    userPrefs.savePref('wolofVerseEnabled', !wolof!);
                  });
                }
              },
            ),
          ),
        ],
      );
    }

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
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                // backgroundColor: Theme.of(context).primaryColor,

                onSelected: (bool selected) {
                  themeProvider.setLocale('fr_CH');
                },
              ),
              ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr' ? true : false,

                label: Text(
                  "Français",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                // backgroundColor: Theme.of(context).primaryColor,
                // selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr');
                  print(AppLocalizations.of(context)!.addHolidays);
                },
              ),
              ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 10),

                selected: userLocale.toString() == 'en' ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                // backgroundColor: Theme.of(context).primaryColor,
                // selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  themeProvider.setLocale('en');
                },
              ),
            ],
          ),
        ],
      );
    }

///////////////////////////////
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: Colors.white)),
      ),
      //If the width of the screen is greater or equal to 730 (whether or not _isPhone is true)
      //show the wide view
      body: MediaQuery.of(context).size.width >= 730
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ListView(
                children: [
                  settingRow(themeTitle(), themeSettings()),
                  const Divider(),
                  // settingRow(backgroundTitle(), backgroundSettings()),
                  // Divider(),
                  // settingRow(directionTitle(), directionSettings()),
                  // Divider(),
                  scriptPickerTitle(),
                  scriptPicker('arabic'),
                  scriptPicker('roman'),
                  const Divider(),
                  settingRow(languageTitle(), languageSetting()),
                ],
              ),
            )
          : ListView(
              children: [
                settingColumn(themeTitle(), themeSettings()),
                // settingColumn(backgroundTitle(), backgroundSettings()),
                // settingColumn(directionTitle(), directionSettings()),
                scriptPickerTitle(),
                scriptPicker('arabic'),
                scriptPicker('roman'),
                const Divider(),
                settingColumn(languageTitle(), languageSetting()),
              ],
            ),
      // ),
    );
  }
}
