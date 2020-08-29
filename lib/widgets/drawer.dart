import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import '../locale/app_localization.dart';

import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Main template for all  titles
    Widget drawerTitle(String title, IconData icon, Function tapHandler) {
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
                      color: Theme.of(context).appBarTheme.iconTheme.color,
                    ),
                    SizedBox(width: 25),
                    Text(title,
                        style:
                            Theme.of(context).appBarTheme.textTheme.headline6),
                  ],
                ))),
      );
    }

    return Drawer(
      elevation: 5.0,
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        color: Theme.of(context).appBarTheme.color,
        child: ListView(
          children: [
            //Main title
            Container(
                child: Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 20, left: 20, right: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.blur_circular,
                          size: 27,
                          color: Theme.of(context).appBarTheme.iconTheme.color,
                        ),
                        SizedBox(width: 25),
                        Text("Arminaatu wolof",
                            style: Theme.of(context)
                                .appBarTheme
                                .textTheme
                                .headline6
                                .copyWith(
                                  fontSize: 24,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -0.5,
                                ))
                      ],
                    ))),
            Divider(
              thickness: 3,
            ),
            drawerTitle(
              "Settings TT",
              Icons.settings,
              () {
                Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
              },
            ),
            Divider(
              thickness: 1,
            ),
            drawerTitle(
              AppLocalization.of(context).settingsAbout,
              Icons.question_answer,
              () {
                Navigator.of(context).pushNamed(AboutScreen.routeName);
              },
            ),
            Divider(
              thickness: 1,
            ),
            drawerTitle(
              'Add holidays to\nGoogle Calendar TT',
              Icons.calendar_today,
              () async {
                const url = 'mailto:equipedevmbs@gmail.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),

            Divider(
              thickness: 1,
            ),
            drawerTitle(
              AppLocalization.of(context).settingsContactUs,
              Icons.email,
              () async {
                const url = 'mailto:equipedevmbs@gmail.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            Divider(
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}
