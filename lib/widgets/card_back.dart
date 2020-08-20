import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

import '../locale/app_localization.dart';

import '../providers/card_prefs.dart';
import '../providers/names.dart';
import '../providers/theme.dart';

import '../widgets/card_icon_bar.dart';

class CardBack extends StatelessWidget {
  final DivineName name;
  final BuildContext context;

  CardBack(
    this.name,
    this.context,
  );

  @override
  Widget build(BuildContext context) {
    final cardPrefs = Provider.of<CardPrefs>(context, listen: false).cardPrefs;
    final bool _isDark =
        Provider.of<ThemeModel>(context, listen: false).userThemeName ==
            'darkTheme';

    Color _fontColor = _isDark ? Colors.white : Colors.black;

    Widget textRS(input, double fontReduction) {
      return Text(
        input,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _fontColor,
          fontFamily: "Charis",
          fontSize: 30 - fontReduction,
          // fontWeight: FontWeight.bold,
        ),
      );
    }

    Widget textAS(input, double fontReduction) {
      return Text(
        input,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _fontColor,
          fontFamily: "Harmattan",
          fontSize: 40 - fontReduction,
        ),
      );
    }

    bool _isPhone = (MediaQuery.of(context).size.width +
            MediaQuery.of(context).size.height) <=
        1350;
    print(MediaQuery.of(context).size.width);

    //Card back does not have alternate layouts for portrait and landscape
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                Colors.black.withOpacity(.3),
                Colors.black.withOpacity(.0)
              ]),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _isDark
                      ? AssetImage("assets/images/black-bg-1.jpg")
                      : AssetImage("assets/images/white-bg-2.jpg")),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(.3),
                    Colors.black.withOpacity(.0)
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                // isLandscape ? EdgeInsets.all(50.0) : EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    Padding(
                      padding:
                          _isPhone ? EdgeInsets.all(10) : EdgeInsets.all(100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Name Header
                          Row(
                            children: [
                              Expanded(child: textRS(name.wolofName, 0)),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                thickness: 3,
                              ),
                              Expanded(
                                child: textAS(name.wolofalName, 0),
                              ),
                            ],
                          ),
                          //Wolofal verse section
                          cardPrefs.wolofalVerseEnabled
                              ? Column(
                                  children: [
                                    Divider(
                                      color: Theme.of(context).primaryColor,
                                      thickness: 3,
                                    ),
                                    textAS(name.wolofalVerse, 0.0),
                                    textAS(name.wolofalVerseRef, 10.0)
                                  ],
                                )
                              : SizedBox(width: 20),
                          //Wolof verse section
                          cardPrefs.wolofVerseEnabled
                              ? Column(
                                  children: [
                                    Divider(
                                      color: Theme.of(context).primaryColor,
                                      thickness: 3,
                                    ),
                                    textRS(name.wolofVerse, 0.0),
                                    SizedBox(height: 20),
                                    textRS(name.wolofVerseRef, 10.0),
                                  ],
                                )
                              : SizedBox(width: 20),
                          SizedBox(height: 60),
                          FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    AppLocalization.of(context)
                                        .clickHereToReadMore,
                                    style: TextStyle(color: _fontColor)),
                                Icon(Icons.arrow_forward, color: _fontColor),
                              ],
                            ),
                            onPressed: () async {
                              const url = 'https://sng.al/chrono';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                          SizedBox(
                            height: 70,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: CardIconBar(name, context)),
        ],
      ),
    );
  }
}
