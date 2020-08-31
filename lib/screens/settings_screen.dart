import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../locale/app_localization.dart';
// import '../providers/months.dart';
import '../providers/theme.dart';
import '../providers/user_prefs.dart';

import './about_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    final userThemeName =
        Provider.of<ThemeModel>(context, listen: false).userThemeName;
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    final userLang = Provider.of<ThemeModel>(context, listen: false).userLang;
    final userPrefs = Provider.of<UserPrefs>(context, listen: false);
    final _wolof = userPrefs.userPrefs.wolofVerseEnabled;
    final _wolofal = userPrefs.userPrefs.wolofalVerseEnabled;
    // final screenWidth = MediaQuery.of(context).size.width;
    print('in settings');

    //Widgets
    //Main template for all setting titles
    Widget settingTitle(String title, IconData icon, Function tapHandler) {
      return InkWell(
        onTap: tapHandler,
        child: Container(
            width: 300,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 27,
                      color: Theme.of(context).textTheme.headline6.color,
                    ),
                    SizedBox(width: 25),
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
          VerticalDivider(width: 10, color: Colors.white),
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
          Divider(),
        ],
      );
    }

    //Now individual implementations of it
    Widget themeTitle() {
      return settingTitle(AppLocalization.of(context).settingsTheme,
          Icons.settings_brightness, null);
    }

    Widget backgroundTitle() {
      return settingTitle(AppLocalization.of(context).settingsCardBackground,
          Icons.image, null);
    }

    Widget directionTitle() {
      return settingTitle(AppLocalization.of(context).settingsCardDirection,
          Icons.compare_arrows, null);
    }

    Widget scriptPickerTitle() {
      return settingTitle(AppLocalization.of(context).settingsVerseDisplay,
          Icons.format_quote, null);
    }

    Widget languageTitle() {
      return settingTitle(
          AppLocalization.of(context).settingsLanguage, Icons.translate, null);
    }

    Widget themeSettings() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RaisedButton(
            padding: EdgeInsets.all(0),
            child: userThemeName == 'lightTheme' ? Icon(Icons.check) : null,
            shape: CircleBorder(),
            color: Colors.white,
            onPressed: () {
              themeProvider.setLightTheme();
            },
          ),
          RaisedButton(
            padding: EdgeInsets.all(0),
            child: userThemeName == 'blueTheme' ? Icon(Icons.check) : null,
            shape: CircleBorder(),
            color: Colors.blue,
            onPressed: () {
              themeProvider.setBlueTheme();
            },
          ),
          RaisedButton(
              padding: EdgeInsets.all(0),
              child: userThemeName == 'tealTheme' ? Icon(Icons.check) : null,
              shape: CircleBorder(),
              color: Colors.teal,
              onPressed: () {
                themeProvider.setTealTheme();
              }),
          RaisedButton(
            padding: EdgeInsets.all(0),
            child: userThemeName == 'darkTheme' ? Icon(Icons.check) : null,
            shape: CircleBorder(),
            color: Colors.black,
            onPressed: () {
              setState(() {
                themeProvider.setDarkTheme();
              });
            },
          ),
        ],
      );
    }

    Widget backgroundSettings() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RaisedButton(
            child: userPrefs.userPrefs.imageEnabled
                ? null
                : Icon(
                    Icons.check,
                    color: Colors.black,
                  ),
            shape: CircleBorder(),
            color: Colors.white70,
            onPressed: () {
              setState(() {
                userPrefs.savePref('imageEnabled', false);
              });
            },
          ),
          Material(
            shape: CircleBorder(),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.black,
              onTap: () {
                setState(() {
                  userPrefs.savePref('imageEnabled', true);
                });
              },
              child: Container(
                child: userPrefs.userPrefs.imageEnabled
                    ? Icon(Icons.check, color: Colors.white)
                    : null,
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/7.jpg'),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget directionSettings() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            direction: Axis.horizontal,
            spacing: 15,
            children: [
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userPrefs.userPrefs.textDirection ? false : true,
                avatar: Icon(Icons.arrow_forward),
                label: Text(
                  "LTR",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    userPrefs.savePref('textDirection', false);
                  });
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userPrefs.userPrefs.textDirection ? true : false,
                avatar: Icon(Icons.arrow_back),
                label: Text(
                  "RTL",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    userPrefs.savePref('textDirection', true);
                  });
                },
              ),
            ],
          ),
        ],
      );
    }

    Widget asScriptPicker() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 80),
                  child: Row(children: [
                    // Expanded(child:
                    Text(AppLocalization.of(context).settingsVerseinWolofal,
                        style: Theme.of(context).textTheme.subtitle1),
                  ]))),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  value: _wolofal,
                  onChanged: (_) {
                    setState(() {
                      userPrefs.savePref('wolofalVerseEnabled', !_wolofal);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget rsScriptPicker() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 80),
                  child: Row(children: [
                    // Expanded(child:
                    Text(AppLocalization.of(context).settingsVerseinWolof,
                        style: Theme.of(context).textTheme.subtitle1),
                  ]))),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  value: _wolof,
                  onChanged: (_) {
                    setState(() {
                      userPrefs.savePref('wolofVerseEnabled', !_wolof);
                    });
                  },
                ),
              ],
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
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLang == 'wo' ? true : false,
                label: Text(
                  "Wolof",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLang('wo');
                  });
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLang == 'fr' ? true : false,
                label: Text(
                  "Français",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLang('fr');
                  });
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLang == 'en' ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLang('en');
                  });
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
        title: Text(
          AppLocalization.of(context).settingsTitle,
        ),
      ),
      //If the width of the screen is greater or equal to 500
      //show the wide view
      body: MediaQuery.of(context).size.width >= 500
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: ListView(
                children: [
                  settingRow(themeTitle(), themeSettings()),
                  Divider(),
                  settingRow(backgroundTitle(), backgroundSettings()),
                  Divider(),
                  settingRow(directionTitle(), directionSettings()),
                  Divider(),
                  scriptPickerTitle(),
                  asScriptPicker(),
                  rsScriptPicker(),
                  Divider(),
                  settingRow(languageTitle(), languageSetting()),
                ],
              ),
            )
          : ListView(
              children: [
                settingColumn(themeTitle(), themeSettings()),
                settingColumn(backgroundTitle(), backgroundSettings()),
                settingColumn(directionTitle(), directionSettings()),
                scriptPickerTitle(),
                asScriptPicker(),
                rsScriptPicker(),
                Divider(),
                settingColumn(languageTitle(), languageSetting()),
              ],
            ),
      // ),
    );
  }
}
